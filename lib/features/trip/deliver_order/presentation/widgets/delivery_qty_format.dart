
String formatDeliveryQty(num? quantity) {
  if (quantity == null) return '—';

  if (quantity == quantity.roundToDouble()) {
    return quantity.toInt().toString();
  }

  return quantity.toString();
}
