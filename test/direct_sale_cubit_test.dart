import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/data/models/direct_sale_models.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/presentation/cubit/direct_sale_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/presentation/cubit/direct_sale_state.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/presentation/utils/direct_sale_input.dart';

import 'direct_sale_fixtures.dart';

void main() {
  test(
    'production starts without simulated customers, stock or payment support',
    () async {
      final cubit = DirectSaleCubit();
      addTearDown(cubit.close);
      expect(cubit.state.customer, isNull);
      expect(cubit.state.products, isEmpty);
      expect(cubit.state.inventoryAvailable, isFalse);
      expect(cubit.state.availablePaymentMethods, isEmpty);
      cubit.continueToProducts();
      expect(cubit.state.step, DirectSaleStep.customer);
      cubit.selectCashCustomer();
      cubit.continueToProducts();
      cubit.continueToPayment();
      expect(cubit.state.step, DirectSaleStep.products);
      expect(cubit.state.receipt, isNull);
    },
  );

  test(
    'quantities respect stock and totals use exact supplied prices',
    () async {
      final cubit = DirectSaleCubit(
        initialState: directSaleTestState(DirectSaleStep.products),
      );
      addTearDown(cubit.close);
      final cola = directSaleTestProducts.first;
      cubit.setQuantity(cola, 999);
      expect(cubit.state.quantityFor(cola), 15);
      cubit.setQuantity(cola, -1);
      expect(cubit.state.quantityFor(cola), 0);
      cubit.setQuantity(cola, 1);
      cubit.setQuantity(directSaleTestProducts[1], 4);
      cubit.setQuantity(directSaleTestProducts[4], 2);
      expect(cubit.state.itemCount, 7);
      expect(cubit.state.totalMinor, 44500);
      cubit.continueToPayment();
      expect(cubit.state.step, DirectSaleStep.payment);
    },
  );

  test('amount validation gates supported methods and invalidates changed selections', () async {
    final cubit = DirectSaleCubit(
      initialState: directSaleTestState(DirectSaleStep.payment),
    );
    addTearDown(cubit.close);
    for (final invalid in ['13312', '-445', '445.001', 'abc', '']) {
      cubit.changeAmount(invalid);
      cubit.selectPaymentMethod(DirectSalePaymentMethod.cash);
      expect(cubit.state.amountMatches, isFalse);
      expect(cubit.state.paymentMethod, isNull);
    }
    cubit.changeAmount('٤٤٥٫٠٠');
    cubit.selectPaymentMethod(DirectSalePaymentMethod.instaPay);
    expect(cubit.state.paymentMethod, DirectSalePaymentMethod.instaPay);
    cubit.changeAmount('444');
    expect(cubit.state.paymentMethod, isNull);
    cubit.changeAmount('۴۴۵٫۰۰');
    expect(cubit.state.amountMatches, isTrue);
    expect(cubit.state.receipt, isNull);
  });

  test(
    'back and customer changes preserve quantities and entered drafts',
    () async {
      final cubit = DirectSaleCubit(
        initialState: directSaleTestState(DirectSaleStep.payment),
      );
      addTearDown(cubit.close);
      cubit.nameController.text = 'مسودة عميل';
      cubit.amountController.text = '445';
      cubit.changeAmount('445');
      expect(cubit.goBack(), isTrue);
      cubit.changeCustomer();
      cubit.openNewCustomer();
      expect(cubit.goBack(), isTrue);
      expect(cubit.nameController.text, 'مسودة عميل');
      expect(cubit.amountController.text, '445');
      expect(cubit.state.itemCount, 7);
      expect(cubit.goBack(), isFalse);
    },
  );

  test('phone validation accepts normalized digits and enforces 01 plus eleven digits', () {
    for (final phone in ['01223322111', '٠١٢٢٣٣٢٢١١١', '۰۱۲۲۳۳۲۲۱۱۱']) {
      expect(isValidDirectSalePhone(phone), isTrue);
    }
    for (final phone in ['', '11223322111', '0122', '012233221111']) {
      expect(isValidDirectSalePhone(phone), isFalse);
    }
    expect(directSaleAmountMinor('0.10'), 10);
    expect(directSaleAmountMinor('445,5'), 44550);
  });

  test(
    'location requests do not duplicate and ignore completion after closing',
    () async {
      final result = Completer<Position>();
      var calls = 0;
      final cubit = DirectSaleCubit(
        locate: () {
          calls++;
          return result.future;
        },
      );
      final pending = cubit.captureLocation();
      await cubit.captureLocation();
      expect(calls, 1);
      await cubit.close();
      result.complete(directSaleTestPosition);
      await pending;
    },
  );

  for (final error in DirectSaleLocationError.values) {
    test('location $error leaves the form usable', () async {
      final cubit = DirectSaleCubit(locate: () async => throw error);
      addTearDown(cubit.close);
      cubit.nameController.text = 'أحمد';
      await cubit.captureLocation();
      expect(cubit.state.locationError, error);
      expect(cubit.state.locating, isFalse);
      expect(cubit.nameController.text, 'أحمد');
    });
  }

  test('new sale clears the receipt and draft without discarding supplied inventory', () async {
    final cubit = DirectSaleCubit(
      initialState: directSaleTestState(DirectSaleStep.success),
    );
    addTearDown(cubit.close);
    cubit.phoneController.text = '01223322111';
    cubit.newSale();
    expect(cubit.state.step, DirectSaleStep.customer);
    expect(cubit.state.receipt, isNull);
    expect(cubit.state.customer, isNull);
    expect(cubit.state.quantities, isEmpty);
    expect(cubit.phoneController.text, isEmpty);
    expect(cubit.state.products, directSaleTestProducts);
  });
}
