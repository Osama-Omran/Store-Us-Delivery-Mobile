import 'package:geolocator/geolocator.dart';

import '../../data/models/direct_sale_models.dart';
import '../utils/direct_sale_input.dart';

enum DirectSaleLocationError { disabled, denied, failed }

class DirectSaleState {
  const DirectSaleState({
    this.step = DirectSaleStep.customer,
    this.customer,
    this.existingCustomers = const [],
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
    this.submittingPos = false,
    this.posSubmitError,
    this.posRetryOriginal = false,
    this.creatingCustomer = false,
    this.customerCreateError,
    this.customerVerificationRequired = false,
    this.retryOriginalCustomerRequest = false,
    this.territories = const [],
    this.selectedTerritory,
    this.loadingCustomerOptions = false,
    this.customerOptionsLoaded = false,
    this.customerOptionsError,
    this.loadingVehicleStock = false,
    this.vehicleStockLoaded = false,
    this.vehicleStockError,
    this.vehicleWarehouse = '',
    this.vehicleTripStatus = '',
  });

  final DirectSaleStep step;
  final DirectSaleCustomer? customer;
  final List<DirectSaleCustomer> existingCustomers;
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
  final bool submittingPos;
  final String? posSubmitError;
  /// True when submission may have reached the server; retry SAME payload.
  final bool posRetryOriginal;
  final bool creatingCustomer;
  final String? customerCreateError;
  final bool customerVerificationRequired;
  // An earlier request may already have reached the server.
  // Retry only with the same UUID and exact original payload.
  final bool retryOriginalCustomerRequest;
  final List<String> territories;
  final String? selectedTerritory;
  final bool loadingCustomerOptions;
  final bool customerOptionsLoaded;
  final String? customerOptionsError;
  final bool loadingVehicleStock;
  final bool vehicleStockLoaded;
  final String? vehicleStockError;
  final String vehicleWarehouse;
  final String vehicleTripStatus;

  int quantityFor(DirectSaleProduct product) => quantities[product.code] ?? 0;
  List<DirectSaleProduct> get selectedProducts =>
      products.where((product) => quantityFor(product) > 0).toList();
  int get itemCount => selectedProducts.fold(
    0,
    (total, product) => total + quantityFor(product),
  );
  bool get selectedProductsHavePrices => selectedProducts.isNotEmpty &&
      selectedProducts.every((product) => product.unitPriceMinor != null &&
          product.unitPriceMinor! >= 0);

  /// Never present an unpriced stock list as a zero-value sale.
  int? get pricedTotalMinor => !selectedProductsHavePrices
      ? null
      : selectedProducts.fold<int>(
          0,
          (total, product) =>
              total + product.unitPriceMinor! * quantityFor(product),
        );

  // Keep the old field available for existing payment-state consumers.
  // UI should use pricedTotalMinor when displaying money.
  int get totalMinor => pricedTotalMinor ?? 0;
  int? get enteredAmountMinor => directSaleAmountMinor(amountText);
  bool get amountMatches =>
      pricedTotalMinor != null && totalMinor > 0 && enteredAmountMinor == totalMinor;
  bool get canSubmitPos =>
      step == DirectSaleStep.payment &&
      customer?.isSaved == true &&
      vehicleStockLoaded &&
      inventoryAvailable &&
      selectedProductsHavePrices &&
      itemCount > 0 &&
      amountMatches &&
      !submittingPos &&
      !posRetryOriginal;

  bool get showAmountMismatch => amountText.trim().isNotEmpty && !amountMatches;

  DirectSaleState copyWith({
    DirectSaleStep? step,
    DirectSaleReceipt? receipt,
    bool? submittingPos,
    String? posSubmitError,
    bool clearPosSubmitError = false,
    bool? posRetryOriginal,
    DirectSaleCustomer? customer,
    List<DirectSaleCustomer>? existingCustomers,
    List<DirectSaleProduct>? products,
    bool? inventoryAvailable,
    Map<String, int>? quantities,
    String? amountText,
    DirectSalePaymentMethod? paymentMethod,
    bool clearPaymentMethod = false,
    Position? position,
    bool? locating,
    DirectSaleLocationError? locationError,
    bool clearLocationError = false,
    bool? creatingCustomer,
    String? customerCreateError,
    bool clearCustomerCreateError = false,
    bool? customerVerificationRequired,
    bool? retryOriginalCustomerRequest,
    List<String>? territories,
    String? selectedTerritory,
    bool clearSelectedTerritory = false,
    bool? loadingCustomerOptions,
    bool? customerOptionsLoaded,
    String? customerOptionsError,
    bool clearCustomerOptionsError = false,
    bool? loadingVehicleStock,
    bool? vehicleStockLoaded,
    String? vehicleStockError,
    bool clearVehicleStockError = false,
    String? vehicleWarehouse,
    String? vehicleTripStatus,
  }) => DirectSaleState(
    step: step ?? this.step,
    customer: customer ?? this.customer,
    existingCustomers: existingCustomers ?? this.existingCustomers,
    products: products ?? this.products,
    inventoryAvailable: inventoryAvailable ?? this.inventoryAvailable,
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
    receipt: receipt ?? this.receipt,
    submittingPos: submittingPos ?? this.submittingPos,
    posSubmitError: clearPosSubmitError
        ? null
        : posSubmitError ?? this.posSubmitError,
    posRetryOriginal: posRetryOriginal ?? this.posRetryOriginal,
    creatingCustomer: creatingCustomer ?? this.creatingCustomer,
    customerCreateError: clearCustomerCreateError
        ? null
        : customerCreateError ?? this.customerCreateError,
    customerVerificationRequired: customerVerificationRequired ?? this.customerVerificationRequired,
    retryOriginalCustomerRequest:
        retryOriginalCustomerRequest ?? this.retryOriginalCustomerRequest,
    territories: territories ?? this.territories,
    selectedTerritory: clearSelectedTerritory
        ? null
        : selectedTerritory ?? this.selectedTerritory,
    loadingCustomerOptions:
        loadingCustomerOptions ?? this.loadingCustomerOptions,
    customerOptionsLoaded:
        customerOptionsLoaded ?? this.customerOptionsLoaded,
    customerOptionsError: clearCustomerOptionsError
        ? null
        : customerOptionsError ?? this.customerOptionsError,
    loadingVehicleStock: loadingVehicleStock ?? this.loadingVehicleStock,
    vehicleStockLoaded: vehicleStockLoaded ?? this.vehicleStockLoaded,
    vehicleStockError: clearVehicleStockError
        ? null
        : vehicleStockError ?? this.vehicleStockError,
    vehicleWarehouse: vehicleWarehouse ?? this.vehicleWarehouse,
    vehicleTripStatus: vehicleTripStatus ?? this.vehicleTripStatus,
  );
}
