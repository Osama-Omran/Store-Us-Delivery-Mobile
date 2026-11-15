import 'package:flutter_test/flutter_test.dart';
import 'package:storeus_delivery/core/helpers/functions/collection_amount.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/presentation/utils/direct_sale_input.dart';

void main() {
  test('reads manually entered amounts exactly in piasters', () {
    for (final input in ['150.75', '١٥٠٫٧٥', '۱۵۰٫۷۵', '150,75', ' 150.75 ']) {
      expect(parseCollectionAmountMinor(input), 15075, reason: input);
      expect(directSaleAmountMinor(input), 15075, reason: input);
    }
    expect(parseCollectionAmountMinor('150'), 15000);
    expect(parseCollectionAmountMinor('150.7'), 15070);
    expect(parseCollectionAmountMinor('0.01'), 1);
  });

  test('rejects missing, nonpositive, malformed, or imprecise amounts', () {
    for (final input in [
      '',
      ' ',
      '0',
      '٠٫٠٠',
      '-150.75',
      '+150.75',
      '150.751',
      '150.',
      '.75',
      '1e3',
      'NaN',
      'Infinity',
      '150abc',
      '1,000.00',
      '1000000000000000000000000',
      '100000000000000.00',
    ]) {
      expect(parseCollectionAmountMinor(input), isNull, reason: input);
      expect(directSaleAmountMinor(input), isNull, reason: input);
    }
  });

  test('matches only the full total, at currency precision', () {
    expect(collectionAmountMatches(15075, 150.75), isTrue);
    expect(collectionAmountMatches(30, 0.1 + 0.2), isTrue);
    for (final entered in <int?>[null, 0, -1, 15074, 15076]) {
      expect(collectionAmountMatches(entered, 150.75), isFalse);
    }
    for (final expected in <num?>[null, 0, -1, double.nan, double.infinity]) {
      expect(collectionAmountMatches(15075, expected), isFalse);
    }
  });
}
