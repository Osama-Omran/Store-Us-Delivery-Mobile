// Screenshot examples are isolated to tests, never production inventory.
import 'package:geolocator/geolocator.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/data/models/direct_sale_models.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/presentation/cubit/direct_sale_state.dart';

const directSaleTestCustomer = DirectSaleCustomer(
  id: 'test-customer',
  name: 'أحمد محمود',
  phone: '01223322111',
);

const directSaleTestProducts = [
  DirectSaleProduct(
    code: 'ITEM-001',
    name: 'كوكاكولا 330 مل',
    unit: 'علبة',
    availableQuantity: 15,
    unitPriceMinor: 4500,
  ),
  DirectSaleProduct(
    code: 'ITEM-012',
    name: 'شيبسي ملح 40 جم',
    unit: 'كيس',
    availableQuantity: 7,
    unitPriceMinor: 5000,
  ),
  DirectSaleProduct(
    code: 'ITEM-020',
    name: 'مياه معدنية 600 مل',
    unit: 'زجاجة',
    availableQuantity: 12,
    unitPriceMinor: 2500,
  ),
  DirectSaleProduct(
    code: 'ITEM-033',
    name: 'بسكويت أوريو',
    unit: 'علبة',
    availableQuantity: 8,
    unitPriceMinor: 5000,
  ),
  DirectSaleProduct(
    code: 'ITEM-054',
    name: 'عصير مانجو 1 لتر',
    unit: 'كرتونة',
    availableQuantity: 6,
    unitPriceMinor: 10000,
  ),
];

DirectSaleState directSaleTestState(
  DirectSaleStep step, {
  String amount = '',
}) => DirectSaleState(
  step: step,
  customer: directSaleTestCustomer,
  products: directSaleTestProducts,
  inventoryAvailable: true,
  quantities: step == DirectSaleStep.payment
      ? const {'ITEM-001': 1, 'ITEM-012': 4, 'ITEM-054': 2}
      : const {},
  amountText: amount,
  availablePaymentMethods: DirectSalePaymentMethod.values,
  receipt: step == DirectSaleStep.success
      ? const DirectSaleReceipt(
          customerName: 'أحمد محمود',
          paidAmountMinor: 44500,
          paymentMethod: DirectSalePaymentMethod.instaPay,
        )
      : null,
);

final directSaleTestPosition = Position(
  latitude: 30.03332,
  longitude: 31.00698,
  timestamp: DateTime(2026, 10, 13),
  accuracy: 92,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);
