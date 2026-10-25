import 'package:storeus_delivery/features/drawer_features/treasury/data/models/treasury_models.dart';

// ======= Local UI Preview Data ======= //
TreasuryData buildSampleTreasury() {
  const customers = [
    'سوبر ماركت الأمل',
    'ماركت النور',
    'بقالة أحمد',
    'ماركت المدينة',
    'سوبر ماركت السلام',
    'ماركت الوفاء',
    'سوبر ماركت الفتح',
  ];
  const orders = [
    'SO-00254',
    'SO-00255',
    'SO-00256',
    'SO-00258',
    'SO-00261',
    'SO-00263',
    'SO-00265',
  ];
  const amounts = [1450, 750, 1800, 1800, 2000, 1300, 3400];
  const methods = [
    TreasuryPaymentMethod.cash,
    TreasuryPaymentMethod.instaPay,
    TreasuryPaymentMethod.cash,
    TreasuryPaymentMethod.cash,
    TreasuryPaymentMethod.electronicWallet,
    TreasuryPaymentMethod.electronicWallet,
    TreasuryPaymentMethod.cash,
  ];
  final times = [
    DateTime(2026, 10, 10, 10, 35),
    DateTime(2026, 10, 10, 11, 10),
    DateTime(2026, 10, 10, 11, 52),
    DateTime(2026, 10, 10, 12, 20),
    DateTime(2026, 10, 10, 13, 5),
    DateTime(2026, 10, 10, 13, 40),
    DateTime(2026, 10, 10, 14, 30),
  ];
  var cashBalance = 0;
  final collections = <TreasuryCollection>[];

  for (var index = 0; index < customers.length; index++) {
    if (methods[index] == TreasuryPaymentMethod.cash) {
      cashBalance += amounts[index];
    }
    collections.add(
      TreasuryCollection(
        orderNumber: orders[index],
        customerName: customers[index],
        collectedAt: times[index],
        deliveredAmount: amounts[index],
        receivedAmount: amounts[index],
        paymentMethod: methods[index],
        cashBalanceAfter: cashBalance,
      ),
    );
  }

  return TreasuryData(
    tripNumber: 'TRIP-0025',
    vehicleName: 'سوزوكي فان - أ ب ج 1234',
    collections: collections,
    inventory: const [
      TreasuryInventoryItem(
        code: 'ITEM-001',
        name: 'كوكاكولا 330 مل',
        unit: 'كرتونة',
        loadedQuantity: 20,
        deliveredQuantity: 12,
        source: TreasuryItemSource.tripOrders,
      ),
      TreasuryInventoryItem(
        code: 'ITEM-012',
        name: 'شيبسي ملح 40 جم',
        unit: 'كرتونة',
        loadedQuantity: 20,
        deliveredQuantity: 9,
        source: TreasuryItemSource.tripOrders,
      ),
      TreasuryInventoryItem(
        code: 'ITEM-033',
        name: 'بسكويت أوريو',
        unit: 'علبة',
        loadedQuantity: 10,
        deliveredQuantity: 7,
        source: TreasuryItemSource.tripOrders,
      ),
      TreasuryInventoryItem(
        code: 'ITEM-054',
        name: 'عصير مانجو 1 لتر',
        unit: 'كرتونة',
        loadedQuantity: 6,
        deliveredQuantity: 2,
        source: TreasuryItemSource.extra,
      ),
      TreasuryInventoryItem(
        code: 'ITEM-061',
        name: 'شاي ليبتون 25 كيس',
        unit: 'علبة',
        loadedQuantity: 10,
        deliveredQuantity: 6,
        source: TreasuryItemSource.extra,
      ),
    ],
  );
}
