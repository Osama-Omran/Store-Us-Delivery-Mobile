enum DirectSaleStep { customer, newCustomer, products, payment, success }

enum DirectSalePaymentMethod { cash, instaPay, wallet }

class DirectSaleCustomer {
  const DirectSaleCustomer({this.id, required this.name, this.phone});

  final String? id;
  final String name;
  final String? phone;

  bool get isSaved => id?.trim().isNotEmpty == true;
}

// Presentation data supplied by a verified inventory/pricing source.
// Loaded trip quantities are not current sellable stock.
class DirectSaleProduct {
  const DirectSaleProduct({
    required this.code,
    required this.name,
    required this.unit,
    required this.availableQuantity,
    required this.unitPriceMinor,
  });

  final String code;
  final String name;
  final String unit;
  final int availableQuantity;
  final int unitPriceMinor;
}

// Only a confirmed sale receipt may populate the success view.
class DirectSaleReceipt {
  const DirectSaleReceipt({
    required this.customerName,
    required this.paidAmountMinor,
    required this.paymentMethod,
  });

  final String customerName;
  final int paidAmountMinor;
  final DirectSalePaymentMethod paymentMethod;
}
