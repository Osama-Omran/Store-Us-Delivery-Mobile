import 'package:storeus_delivery/core/helpers/functions/collection_amount.dart';

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

int? directSaleAmountMinor(String value) => parseCollectionAmountMinor(value);
