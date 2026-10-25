import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/models/direct_sale_models.dart';
import 'direct_sale_state.dart';
import '../utils/direct_sale_input.dart';

class DirectSaleCubit extends Cubit<DirectSaleState> {
  DirectSaleCubit({
    DirectSaleState initialState = const DirectSaleState(),
    Future<Position> Function()? locate,
  }) : _locate = locate ?? _currentPosition,
       super(initialState) {
    amountController.text = initialState.amountText;
  }

  static DirectSaleCubit get(BuildContext context) => BlocProvider.of(context);

  final Future<Position> Function() _locate;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final areaController = TextEditingController();
  final notesController = TextEditingController();
  final amountController = TextEditingController();

  void selectCashCustomer() {
    emit(state.copyWith(customer: const DirectSaleCustomer(name: '')));
  }

  void openNewCustomer() =>
      emit(state.copyWith(step: DirectSaleStep.newCustomer));
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
