const _maxExactMinorAmount = 9007199254740991;

/// Parses a manually entered, positive EGP amount into integer piasters.
int? parseCollectionAmountMinor(String value) {
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  for (var i = 0; i < 10; i++) {
    value = value.replaceAll(arabic[i], '$i').replaceAll(persian[i], '$i');
  }
  value = value.trim().replaceAll('٫', '.').replaceAll(',', '.');
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) return null;
  final parts = value.split('.');
  final fraction = parts.length == 1 ? '00' : parts.last.padRight(2, '0');
  final minor = int.tryParse('${parts.first}$fraction');
  if (minor == null || minor <= 0 || minor > _maxExactMinorAmount) return null;
  return minor;
}

/// Compare the counted amount with the expected total at currency precision.
bool collectionAmountMatches(int? enteredMinor, num? expected) {
  if (enteredMinor == null ||
      enteredMinor <= 0 ||
      expected == null ||
      !expected.isFinite ||
      expected <= 0) {
    return false;
  }
  final expectedMinor = expected * 100;
  return expectedMinor.isFinite &&
      expectedMinor <= _maxExactMinorAmount &&
      enteredMinor == expectedMinor.round();
}
