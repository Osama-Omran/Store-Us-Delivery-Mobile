/// A sellable vehicle-stock item, priced using the trip POS options response.
///
/// This is an estimate for the delivery UI. The delivery backend must validate
/// stock and apply its own authoritative price when confirming extra_items.
class DeliveryExtraProduct {
  const DeliveryExtraProduct({
    required this.itemCode,
    required this.itemName,
    required this.uom,
    required this.availableQuantity,
    required this.rateMinor,
  });

  final String itemCode;
  final String itemName;
  final String uom;
  final int availableQuantity;
  final int rateMinor;

  num get rate => rateMinor / 100;
}
