String normalizeDirectSaleDigits(String value) {
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  for (var i = 0; i < 10; i++) {
    value = value.replaceAll(arabic[i], '$i').replaceAll(persian[i], '$i');
  }
  return value.trim();
}

bool isValidDirectSalePhone(String value) =>
    RegExp(r'^01\d{9}$').hasMatch(normalizeDirectSaleDigits(value));

int? directSaleAmountMinor(String value) {
  final normalized = normalizeDirectSaleDigits(value)
      .replaceAll('٫', '.')
      .replaceAll(',', '.');
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(normalized)) return null;
  final parts = normalized.split('.');
  final whole = int.tryParse(parts.first);
  if (whole == null) return null;
  final decimal = parts.length == 1
      ? 0
      : int.parse(parts.last.padRight(2, '0'));
  return whole * 100 + decimal;
}
