import 'package:geolocator/geolocator.dart';

import '../../data/models/direct_sale_models.dart';
import '../utils/direct_sale_input.dart';

enum DirectSaleLocationError { disabled, denied, failed }

class DirectSaleState {
  const DirectSaleState({
    this.step = DirectSaleStep.customer,
    this.customer,
    this.products = const [],
    this.inventoryAvailable = false,
    this.quantities = const {},
    this.amountText = '',
    this.paymentMethod,
    this.availablePaymentMethods = const [],
    this.position,
    this.locating = false,
    this.locationError,
    this.receipt,
  });

  final DirectSaleStep step;
  final DirectSaleCustomer? customer;
  final List<DirectSaleProduct> products;
  final bool inventoryAvailable;
  final Map<String, int> quantities;
  final String amountText;
  final DirectSalePaymentMethod? paymentMethod;
  final List<DirectSalePaymentMethod> availablePaymentMethods;
  final Position? position;
  final bool locating;
  final DirectSaleLocationError? locationError;
  final DirectSaleReceipt? receipt;

  int quantityFor(DirectSaleProduct product) => quantities[product.code] ?? 0;
  List<DirectSaleProduct> get selectedProducts =>
      products.where((product) => quantityFor(product) > 0).toList();
  int get itemCount => selectedProducts.fold(
    0,
    (total, product) => total + quantityFor(product),
  );
  int get totalMinor => selectedProducts.fold(
    0,
    (total, product) => total + product.unitPriceMinor * quantityFor(product),
  );
  int? get enteredAmountMinor => directSaleAmountMinor(amountText);
  bool get amountMatches => totalMinor > 0 && enteredAmountMinor == totalMinor;
  bool get showAmountMismatch => amountText.trim().isNotEmpty && !amountMatches;

  DirectSaleState copyWith({
    DirectSaleStep? step,
    DirectSaleCustomer? customer,
    Map<String, int>? quantities,
    String? amountText,
    DirectSalePaymentMethod? paymentMethod,
    bool clearPaymentMethod = false,
    Position? position,
    bool? locating,
    DirectSaleLocationError? locationError,
    bool clearLocationError = false,
  }) => DirectSaleState(
    step: step ?? this.step,
    customer: customer ?? this.customer,
    products: products,
    inventoryAvailable: inventoryAvailable,
    quantities: quantities ?? this.quantities,
    amountText: amountText ?? this.amountText,
    paymentMethod: clearPaymentMethod
        ? null
        : paymentMethod ?? this.paymentMethod,
    availablePaymentMethods: availablePaymentMethods,
    position: position ?? this.position,
    locating: locating ?? this.locating,
    locationError: clearLocationError
        ? null
        : locationError ?? this.locationError,
    receipt: receipt,
  );
}
