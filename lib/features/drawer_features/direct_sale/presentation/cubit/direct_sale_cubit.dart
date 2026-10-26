import 'dart:math';

import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/data/models/create_customer_request_body.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/domain/usecases/create_customer_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/models/direct_sale_models.dart';
import 'direct_sale_state.dart';
import '../utils/direct_sale_input.dart';

class DirectSaleCubit extends Cubit<DirectSaleState> {
  DirectSaleCubit({
    required this._createCustomerUsecase,
    DirectSaleState initialState = const DirectSaleState(),
    Future<Position> Function()? locate,
  }) : _locate = locate ?? _currentPosition,
       super(initialState) {
    amountController.text = initialState.amountText;
  }

  static DirectSaleCubit get(BuildContext context) => BlocProvider.of(context);

  final CreateCustomerUsecase _createCustomerUsecase;
  final Future<Position> Function() _locate;
  String? _createCustomerIdempotencyKey;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final areaController = TextEditingController();
  final notesController = TextEditingController();
  final amountController = TextEditingController();

  // UUID v4, stable across retries of the same unsaved form.
  static String _uuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }

  Future<void> createCustomer() async {
    if (isClosed || state.creatingCustomer || state.customerVerificationRequired) {
      return;
    }
    if (formKey.currentState?.validate() != true) return;

    final customerName = nameController.text.trim();
    final phone = normalizeDirectSaleDigits(phoneController.text);
    final territory = areaController.text.trim();
    if (customerName.isEmpty || !isValidDirectSalePhone(phone) || territory.isEmpty) {
      emit(state.copyWith(customerCreateError: 'direct_sale_customer_invalid_fields'));
      return;
    }

    _createCustomerIdempotencyKey ??= _uuidV4();
    final request = CreateCustomerRequestBody(
      idempotencyKey: _createCustomerIdempotencyKey!,
      customerName: customerName,
      phone: phone,
      customerType: 'Individual',
      customerGroup: 'ratail',
      territory: territory,
    );
    emit(state.copyWith(creatingCustomer: true, clearCustomerCreateError: true));

    try {
      final result = await _createCustomerUsecase(request);
      if (isClosed) return;

      result.when(
        success: (response) {
          if (!response.success) {
            // Explicit business rejection: a corrected form is a new attempt.
            _createCustomerIdempotencyKey = null;
            emit(state.copyWith(
              creatingCustomer: false,
              customerCreateError: response.message?.trim().isNotEmpty == true
                  ? response.message
                  : 'direct_sale_customer_create_failed',
            ));
            return;
          }
          if (response.customerId == null) {
            emit(state.copyWith(
              creatingCustomer: false,
              customerVerificationRequired: true,
              customerCreateError: 'direct_sale_customer_missing_id',
            ));
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
          emit(state.copyWith(
            creatingCustomer: false,
            customerVerificationRequired: false,
            clearCustomerCreateError: true,
            customer: created,
            step: DirectSaleStep.customer,
          ));
        },
        failure: (failure) {
          final message = failure.apiErrorModel.message.trim();
          // A failed response can be ambiguous. Do not send another POST blindly.
          emit(state.copyWith(
            creatingCustomer: false,
            customerVerificationRequired: true,
            customerCreateError: message.isNotEmpty
                ? message
                : 'direct_sale_customer_verify_before_retry',
          ));
        },
      );
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(
          creatingCustomer: false,
          customerVerificationRequired: true,
          customerCreateError: 'direct_sale_customer_verify_before_retry',
        ));
      }
    }
  }

  void selectCashCustomer() {
    emit(state.copyWith(customer: const DirectSaleCustomer(name: '')));
  }

  void openNewCustomer() {
    if (state.creatingCustomer) return;
    emit(state.copyWith(step: DirectSaleStep.newCustomer));
  }
  void changeCustomer() => emit(state.copyWith(step: DirectSaleStep.customer));

  void continueToProducts() {
    if (state.customer == null) return;
    emit(state.copyWith(step: DirectSaleStep.products));
  }

  void continueToPayment() {
    if (!state.inventoryAvailable || state.itemCount == 0) return;
    emit(state.copyWith(step: DirectSaleStep.payment));
  }

  void setQuantity(DirectSaleProduct product, int quantity) {
    if (!state.inventoryAvailable ||
        !state.products.contains(product) ||
        product.availableQuantity < 0 ||
        product.unitPriceMinor < 0) {
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

  void changeAmount(String value) => emit(
    state.copyWith(
      amountText: value,
      clearPaymentMethod: directSaleAmountMinor(value) != state.totalMinor,
    ),
  );

  void selectPaymentMethod(DirectSalePaymentMethod method) {
    if (!state.amountMatches ||
        !state.availablePaymentMethods.contains(method)) {
      return;
    }
    emit(state.copyWith(paymentMethod: method));
  }

  // Returns false when the route itself should close.
  bool goBack() {
    if (state.creatingCustomer) return true;
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
    for (final controller in _controllers) {
      controller.clear();
    }
    _createCustomerIdempotencyKey = null;
    emit(
      DirectSaleState(
        products: state.products,
        inventoryAvailable: state.inventoryAvailable,
        availablePaymentMethods: state.availablePaymentMethods,
      ),
    );
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
    areaController,
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
