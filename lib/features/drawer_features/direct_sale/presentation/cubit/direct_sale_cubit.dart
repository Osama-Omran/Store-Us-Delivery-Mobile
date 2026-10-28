import 'dart:math';

import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/data/models/submit_pos_request_body.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/domain/usecases/submit_pos_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/data/models/create_customer_request_body.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/domain/usecases/create_customer_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/domain/usecases/get_customer_options_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/domain/usecases/get_vehicle_stock_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/models/direct_sale_models.dart';
import 'direct_sale_state.dart';
import '../utils/direct_sale_input.dart';

class DirectSaleCubit extends Cubit<DirectSaleState> {
  DirectSaleCubit({
    required this._createCustomerUsecase,
    required this._getCustomerOptionsUsecase,
    required this._getVehicleStockUsecase,
    required this._submitPosUsecase,
    required this.tripId,
    DirectSaleState initialState = const DirectSaleState(),
    Future<Position> Function()? locate,
  }) : _locate = locate ?? _currentPosition,
       super(initialState) {
    amountController.text = initialState.amountText;
    // After an explicit server rejection, editing the form clears the stale
    // error without affecting any unresolved/possibly successful operation.
    for (final controller in [nameController, phoneController]) {
      controller.addListener(_clearRejectedCustomerErrorOnEdit);
    }
    if (initialState.step == DirectSaleStep.newCustomer) {
      loadCustomerOptions();
    }
    // POS options also supplies existing customers for the first screen.
    if (initialState.step == DirectSaleStep.customer ||
        initialState.step == DirectSaleStep.products) {
      loadVehicleStock(force: true);
    }
  }

  static DirectSaleCubit get(BuildContext context) => BlocProvider.of(context);

  final CreateCustomerUsecase _createCustomerUsecase;
  final GetCustomerOptionsUsecase _getCustomerOptionsUsecase;
  final GetVehicleStockUsecase _getVehicleStockUsecase;
  final SubmitPosUsecase _submitPosUsecase;

  /// Real trip identifier from the current trip / route, never an order ID.
  final int tripId;
  final Future<Position> Function() _locate;
  String? _createCustomerIdempotencyKey;
  CreateCustomerRequestBody? _unconfirmedCustomerRequest;
  SubmitPosRequestBody? _unconfirmedPosRequest;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final notesController = TextEditingController();
  final amountController = TextEditingController();

  Future<void> loadCustomerOptions({bool force = false}) async {
    if (isClosed ||
        state.loadingCustomerOptions ||
        (state.customerOptionsLoaded && !force)) {
      return;
    }

    final previousSelection = state.selectedTerritory;
    emit(
      state.copyWith(
        loadingCustomerOptions: true,
        customerOptionsLoaded: false,
        territories: const [],
        clearSelectedTerritory: true,
        clearCustomerOptionsError: true,
      ),
    );
    try {
      final result = await _getCustomerOptionsUsecase();
      if (isClosed) return;
      result.when(
        success: (territories) {
          if (territories.isEmpty) {
            emit(
              state.copyWith(
                loadingCustomerOptions: false,
                customerOptionsLoaded: false,
                customerOptionsError: 'empty',
              ),
            );
            return;
          }
          emit(
            state.copyWith(
              loadingCustomerOptions: false,
              customerOptionsLoaded: true,
              territories: territories,
              selectedTerritory: territories.contains(previousSelection)
                  ? previousSelection
                  : null,
              clearCustomerOptionsError: true,
            ),
          );
        },
        failure: (_) {
          emit(
            state.copyWith(
              loadingCustomerOptions: false,
              customerOptionsLoaded: false,
              customerOptionsError: 'failed',
            ),
          );
        },
      );
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            loadingCustomerOptions: false,
            customerOptionsLoaded: false,
            customerOptionsError: 'failed',
          ),
        );
      }
    }
  }

  void selectTerritory(String? territory) {
    if (isClosed ||
        state.creatingCustomer ||
        !state.customerOptionsLoaded ||
        (territory != null && !state.territories.contains(territory))) {
      return;
    }
    emit(
      state.copyWith(
        selectedTerritory: territory,
        clearSelectedTerritory: territory == null,
        clearCustomerCreateError: _unconfirmedCustomerRequest == null,
      ),
    );
  }

  // UUID v4, stable across retries of the same unsaved form.
  static String _uuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }

  Future<void> createCustomer() async {
    if (isClosed || state.creatingCustomer) {
      return;
    }
    if (formKey.currentState?.validate() != true) return;

    final customerName = nameController.text.trim();
    final phone = normalizeDirectSaleDigits(phoneController.text);
    final territory = state.selectedTerritory;
    if (customerName.isEmpty ||
        !isValidDirectSalePhone(phone) ||
        !state.customerOptionsLoaded ||
        territory == null ||
        !state.territories.contains(territory)) {
      emit(
        state.copyWith(
          customerCreateError: 'direct_sale_customer_invalid_fields',
        ),
      );
      return;
    }

    // If the last operation has an uncertain result, do NOT send a different
    // customer under the same idempotency key (or generate another key).
    // Retrying the EXACT previous payload with the original key is safe only
    // when the backend implements its documented idempotency contract.
    final unconfirmed = _unconfirmedCustomerRequest;
    if (unconfirmed != null &&
        (unconfirmed.customerName != customerName ||
            unconfirmed.phone != phone ||
            unconfirmed.territory != territory)) {
      emit(
        state.copyWith(
          creatingCustomer: false,
          clearCustomerCreateError: false,
          customerCreateError: 'direct_sale_customer_retry_same_data',
          retryOriginalCustomerRequest: true,
        ),
      );
      return;
    }

    _createCustomerIdempotencyKey ??= _uuidV4();
    final request =
        unconfirmed ??
        CreateCustomerRequestBody(
          idempotencyKey: _createCustomerIdempotencyKey!,
          customerName: customerName,
          phone: phone,
          customerType: 'Individual',
          customerGroup: 'Individual',
          territory: territory,
        );
    emit(
      state.copyWith(creatingCustomer: true, clearCustomerCreateError: true),
    );

    try {
      final result = await _createCustomerUsecase(request);
      if (isClosed) return;

      result.when(
        success: (response) {
          if (!response.success) {
            // Explicit business rejection: a corrected form is a new attempt.
            _createCustomerIdempotencyKey = null;
            _unconfirmedCustomerRequest = null;
            emit(
              state.copyWith(
                creatingCustomer: false,
                customerVerificationRequired: false,
                retryOriginalCustomerRequest: false,
                customerCreateError: response.message?.trim().isNotEmpty == true
                    ? response.message
                    : 'direct_sale_customer_create_failed',
              ),
            );
            return;
          }
          if (response.customerId == null) {
            // The server may have created the customer. Allow a manual retry
            // of the EXACT same operation; never allocate a new UUID here.
            _unconfirmedCustomerRequest = request;
            emit(
              state.copyWith(
                creatingCustomer: false,
                customerVerificationRequired: false,
                retryOriginalCustomerRequest: true,
                customerCreateError: 'direct_sale_customer_missing_id',
              ),
            );
            return;
          }
          final created = DirectSaleCustomer(
            id: response.customerId,
            name: response.customerName?.trim().isNotEmpty == true
                ? response.customerName!.trim()
                : customerName,
            phone: phone,
          );
          _createCustomerIdempotencyKey = null;
          _unconfirmedCustomerRequest = null;
          emit(
            state.copyWith(
              creatingCustomer: false,
              customerVerificationRequired: false,
              retryOriginalCustomerRequest: false,
              clearCustomerCreateError: true,
              customer: created,
              step: DirectSaleStep.customer,
            ),
          );
        },
        failure: (failure) {
          final message = failure.apiErrorModel.message.trim();
          // Enable an explicit retry. Reuse the same idempotency key AND
          // request body so a timeout or 5xx cannot create a second customer.
          _unconfirmedCustomerRequest = request;
          emit(
            state.copyWith(
              creatingCustomer: false,
              customerVerificationRequired: false,
              retryOriginalCustomerRequest: true,
              customerCreateError: message.isNotEmpty
                  ? message
                  : 'direct_sale_customer_verify_before_retry',
            ),
          );
        },
      );
    } catch (_) {
      if (!isClosed) {
        _unconfirmedCustomerRequest = request;
        emit(
          state.copyWith(
            creatingCustomer: false,
            customerVerificationRequired: false,
            retryOriginalCustomerRequest: true,
            customerCreateError: 'direct_sale_customer_verify_before_retry',
          ),
        );
      }
    }
  }

  void _clearRejectedCustomerErrorOnEdit() {
    if (isClosed ||
        state.creatingCustomer ||
        state.customerCreateError == null ||
        _unconfirmedCustomerRequest != null) {
      return;
    }
    emit(state.copyWith(clearCustomerCreateError: true));
  }

  // The documented POS contract supports existing customers only.
  // Never send customer_mode=existing with a blank/cash customer ID.
  void selectExistingCustomer(String? customerId) {
    if (isClosed ||
        state.submittingPos ||
        state.posRetryOriginal ||
        !state.vehicleStockLoaded) {
      return;
    }
    for (final customer in state.existingCustomers) {
      if (customer.id == customerId) {
        emit(state.copyWith(customer: customer));
        return;
      }
    }
  }

  void openNewCustomer() {
    if (state.creatingCustomer ||
        state.submittingPos ||
        state.posRetryOriginal) {
      return;
    }
    emit(state.copyWith(step: DirectSaleStep.newCustomer));
    loadCustomerOptions();
  }

  void changeCustomer() {
    if (state.submittingPos || state.posRetryOriginal) return;
    emit(state.copyWith(step: DirectSaleStep.customer));
  }

  void continueToProducts() {
    if (state.customer?.isSaved != true ||
        tripId <= 0 ||
        state.submittingPos ||
        state.posRetryOriginal) {
      return;
    }
    emit(state.copyWith(step: DirectSaleStep.products));
    // Load fresh prices/stock whenever entering the cart for a new sale.
    loadVehicleStock(force: true);
  }

  /// Refresh live remaining quantities; reset cart to prevent stale overselling.
  Future<void> loadVehicleStock({bool force = false}) async {
    if (isClosed ||
        state.submittingPos ||
        state.posRetryOriginal ||
        state.loadingVehicleStock ||
        (state.vehicleStockLoaded && !force)) {
      return;
    }

    emit(
      state.copyWith(
        loadingVehicleStock: true,
        vehicleStockLoaded: false,
        clearVehicleStockError: true,
        products: const [],
        quantities: const {},
        inventoryAvailable: false,
        clearPaymentMethod: true,
        vehicleWarehouse: '',
        vehicleTripStatus: '',
        amountText: '',
      ),
    );
    amountController.clear();
    try {
      final result = await _getVehicleStockUsecase(tripId);
      if (isClosed) return;
      result.when(
        success: (stock) {
          // The UI currently supports whole-unit quantities only; never
          // round fractional POS stock into a different sellable quantity.
          if (stock.sellableItems.any(
            (item) => item.available != item.available.toInt(),
          )) {
            emit(
              state.copyWith(
                loadingVehicleStock: false,
                vehicleStockError: 'fractional',
              ),
            );
            return;
          }
          // This feature formats money as EGP. Don't label another currency
          // incorrectly if backend options ever switch to another currency.
          if (stock.currency != 'EGP') {
            emit(
              state.copyWith(
                loadingVehicleStock: false,
                vehicleStockError: 'failed',
              ),
            );
            return;
          }
          final products = stock.sellableItems
              .map(
                (item) => DirectSaleProduct(
                  code: item.itemCode,
                  name: item.itemName,
                  unit: item.uom,
                  availableQuantity: item.available.toInt(),
                  // A rate of 0 is an explicit server rate, NOT a missing price.
                  unitPriceMinor: item.rateMinor,
                ),
              )
              .toList(growable: false);
          final existingCustomers = stock.customers
              .map(
                (item) => DirectSaleCustomer(
                  id: item.id,
                  name: item.displayName,
                  phone: item.mobileNo,
                ),
              )
              .toList(growable: false);
          emit(
            state.copyWith(
              existingCustomers: List.unmodifiable(existingCustomers),
              products: List.unmodifiable(products),
              quantities: const {},
              inventoryAvailable: products.isNotEmpty,
              vehicleStockLoaded: true,
              loadingVehicleStock: false,
              clearVehicleStockError: true,
            ),
          );
        },
        failure: (_) => emit(
          state.copyWith(
            loadingVehicleStock: false,
            vehicleStockError: 'failed',
          ),
        ),
      );
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            loadingVehicleStock: false,
            vehicleStockError: 'failed',
          ),
        );
      }
    }
  }

  void continueToPayment() {
    if (!state.vehicleStockLoaded ||
        !state.inventoryAvailable ||
        state.customer?.isSaved != true ||
        state.submittingPos ||
        state.posRetryOriginal ||
        state.itemCount == 0 ||
        !state.selectedProductsHavePrices) {
      return;
    }
    emit(state.copyWith(step: DirectSaleStep.payment));
  }

  void setQuantity(DirectSaleProduct product, int quantity) {
    if (state.submittingPos ||
        state.posRetryOriginal ||
        !state.inventoryAvailable ||
        !state.products.contains(product) ||
        product.availableQuantity < 0) {
      return;
    }
    final next = quantity.clamp(0, product.availableQuantity);
    if (next == state.quantityFor(product)) return;
    emit(
      state.copyWith(
        quantities: Map.unmodifiable({...state.quantities, product.code: next}),
        clearPaymentMethod: true,
      ),
    );
  }

  void changeAmount(String value) {
    if (state.submittingPos || state.posRetryOriginal) return;
    emit(
      state.copyWith(
        amountText: value,
        clearPaymentMethod: directSaleAmountMinor(value) != state.totalMinor,
        clearPosSubmitError: true,
      ),
    );
  }

  void selectPaymentMethod(DirectSalePaymentMethod method) {
    if (!state.amountMatches ||
        !state.availablePaymentMethods.contains(method)) {
      return;
    }
    emit(state.copyWith(paymentMethod: method));
  }

  // Returns false when the route itself should close.
  bool goBack() {
    if (state.creatingCustomer ||
        state.submittingPos ||
        state.posRetryOriginal) {
      return true;
    }
    final step = switch (state.step) {
      DirectSaleStep.customer || DirectSaleStep.success => null,
      DirectSaleStep.newCustomer ||
      DirectSaleStep.products => DirectSaleStep.customer,
      DirectSaleStep.payment => DirectSaleStep.products,
    };
    if (step == null) return false;
    emit(state.copyWith(step: step));
    return true;
  }

  void newSale() {
    if (state.submittingPos ||
        state.posRetryOriginal ||
        state.step != DirectSaleStep.success) {
      return;
    }
    for (final controller in _controllers) {
      controller.clear();
    }
    _createCustomerIdempotencyKey = null;
    _unconfirmedCustomerRequest = null;
    _unconfirmedPosRequest = null;
    emit(
      DirectSaleState(availablePaymentMethods: state.availablePaymentMethods),
    );
    loadVehicleStock(force: true); // refresh customers and stock for next sale
  }

  /// Confirm the sale only after verifying that the counted amount matches
  /// the total calculated from the server's rates and selected quantities.
  /// Any ambiguous retry reuses the *same immutable request and operation_id*.
  Future<void> submitSale() async {
    if (isClosed ||
        state.submittingPos ||
        state.step != DirectSaleStep.payment) {
      return;
    }
    final pending = _unconfirmedPosRequest;
    if (pending == null && !state.canSubmitPos) return;

    late final SubmitPosRequestBody request;
    try {
      request =
          pending ??
          SubmitPosRequestBody(
            operationId: _uuidV4(),
            customerId: state.customer!.id!,
            items: state.selectedProducts
                .map(
                  (product) => SubmitPosItem(
                    itemCode: product.code,
                    qty: state.quantityFor(product),
                    rateMinor: product.unitPriceMinor!,
                  ),
                )
                .toList(growable: false),
            amountMinor: state.totalMinor,
          );
    } catch (_) {
      emit(state.copyWith(posSubmitError: 'direct_sale_pos_invalid'));
      return;
    }
    // Persist before invoking the server, so timeouts never generate a new ID.
    _unconfirmedPosRequest = request;
    emit(state.copyWith(submittingPos: true, clearPosSubmitError: true));

    try {
      final result = await _submitPosUsecase(tripId, request);
      if (isClosed) return;
      result.when(
        success: (response) {
          if (!response.success) {
            // A definite rejection can be corrected; a new submission must
            // use a new operation_id after the user changes the order.
            _unconfirmedPosRequest = null;
            emit(
              state.copyWith(
                submittingPos: false,
                posRetryOriginal: false,
                posSubmitError: response.message?.trim().isNotEmpty == true
                    ? response.message
                    : 'direct_sale_pos_failed',
              ),
            );
            return;
          }
          _unconfirmedPosRequest = null;
          final customer = state.customer!;
          emit(
            state.copyWith(
              submittingPos: false,
              posRetryOriginal: false,
              clearPosSubmitError: true,
              receipt: DirectSaleReceipt(
                customerName: customer.name,
                paidAmountMinor: request.amountMinor,
                // The POS endpoint has no payment_method field.
                paymentMethod: null,
              ),
              step: DirectSaleStep.success,
            ),
          );
        },
        failure: (_) {
          // Network/server ambiguity: don't allow editing or discarding the
          // order; retry must use the original payload and operation_id.
          emit(
            state.copyWith(
              submittingPos: false,
              posRetryOriginal: true,
              posSubmitError: 'direct_sale_pos_verify_or_retry',
            ),
          );
        },
      );
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            submittingPos: false,
            posRetryOriginal: true,
            posSubmitError: 'direct_sale_pos_verify_or_retry',
          ),
        );
      }
    }
  }

  Future<void> captureLocation() async {
    if (state.locating) return;
    emit(state.copyWith(locating: true, clearLocationError: true));
    try {
      final position = await _locate();
      if (!isClosed) emit(state.copyWith(position: position, locating: false));
    } on DirectSaleLocationError catch (error) {
      if (!isClosed) {
        emit(state.copyWith(locating: false, locationError: error));
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            locating: false,
            locationError: DirectSaleLocationError.failed,
          ),
        );
      }
    }
  }

  static Future<Position> _currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw DirectSaleLocationError.disabled;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw DirectSaleLocationError.denied;
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 12),
      ),
    );
  }

  List<TextEditingController> get _controllers => [
    nameController,
    phoneController,
    addressController,
    notesController,
    amountController,
  ];

  @override
  Future<void> close() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    return super.close();
  }
}
