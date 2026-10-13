import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/routing/app_router.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_theme.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/data/models/direct_sale_models.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/presentation/cubit/direct_sale_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/presentation/screens/direct_sale_screen.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/app_menu_drawer.dart';

import 'direct_sale_fixtures.dart';

const _captureKey = ValueKey('direct-sale-capture');

void main() {
  setUpAll(() async {
    final loader = FontLoader('cairo')
      ..addFont(rootBundle.load('assets/fonts/cairo/Cairo-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/cairo/Cairo-Bold.ttf'));
    await loader.load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  testWidgets(
    'cash selection opens unavailable stock without creating a fake sale',
    (tester) async {
      final cubit = DirectSaleCubit();
      addTearDown(cubit.close);
      await _pump(tester, cubit);
      final strings = _strings(tester);
      expect(
        _footer(tester, strings.direct_sale_continue_products).onPressed,
        isNull,
      );
      await _capture(tester, 'customer-unselected');
      await tester.tap(find.text(strings.direct_sale_cash_customer));
      await tester.pumpAndSettle();
      expect(
        _footer(tester, strings.direct_sale_continue_products).onPressed,
        isNotNull,
      );
      await _capture(tester, 'customer-cash-selected');
      await tester.tap(find.text(strings.direct_sale_continue_products));
      await tester.pumpAndSettle();
      expect(
        find.text(strings.direct_sale_inventory_unavailable),
        findsOneWidget,
      );
      expect(cubit.state.receipt, isNull);
      await tester.tap(find.byKey(const ValueKey('direct-sale-back')));
      await tester.pumpAndSettle();
      expect(cubit.state.step, DirectSaleStep.customer);
      await _unmount(tester);
    },
  );

  testWidgets(
    'customer form keeps input and real location through back navigation',
    (tester) async {
      final cubit = DirectSaleCubit(locate: () async => directSaleTestPosition);
      addTearDown(cubit.close);
      cubit.openNewCustomer();
      await _pump(tester, cubit);
      final strings = _strings(tester);
      await _capture(tester, 'customer-form-empty');
      final name = _formField(cubit.nameController);
      final phone = _formField(cubit.phoneController);
      await tester.enterText(name, 'أحمد محمود');
      await tester.enterText(phone, '11223322111');
      await tester.pumpAndSettle();
      expect(find.text(strings.direct_sale_phone_invalid), findsOneWidget);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.text(strings.direct_sale_current_location),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.direct_sale_current_location));
      await tester.pumpAndSettle();
      expect(find.text('30.03332'), findsOneWidget);
      expect(find.text('31.00698'), findsOneWidget);
      expect(
        _footer(tester, strings.direct_sale_save_customer).onPressed,
        isNull,
      );
      await _capture(tester, 'customer-form-invalid-location');
      await tester.ensureVisible(phone);
      await tester.enterText(phone, '٠١٢٢٣٣٢٢١١١');
      await tester.pumpAndSettle();
      expect(find.text(strings.direct_sale_phone_invalid), findsNothing);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.account_cancel));
      await tester.pumpAndSettle();
      cubit.openNewCustomer();
      await tester.pumpAndSettle();
      expect(cubit.nameController.text, 'أحمد محمود');
      expect(cubit.phoneController.text, '٠١٢٢٣٣٢٢١١١');
      expect(cubit.state.position, directSaleTestPosition);
      await _unmount(tester);
    },
  );

  testWidgets(
    'product selection, payment mismatch and method state survive going back',
    (tester) async {
      final cubit = DirectSaleCubit(
        initialState: directSaleTestState(DirectSaleStep.products),
      );
      addTearDown(cubit.close);
      await _pump(tester, cubit);
      final strings = _strings(tester);
      await _capture(tester, 'products-empty-basket');
      await tester.tap(find.byTooltip(strings.direct_sale_increase).first);
      await tester.pumpAndSettle();
      expect(cubit.state.totalMinor, 4500);
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();
      expect(cubit.state.step, DirectSaleStep.payment);
      final amount = find.byKey(const ValueKey('direct-sale-amount'));
      await tester.ensureVisible(amount);
      await tester.enterText(amount, '13312');
      await tester.pumpAndSettle();
      expect(cubit.state.showAmountMismatch, isTrue);
      expect(_footer(tester, strings.direct_sale_confirm).onPressed, isNull);
      await tester.enterText(amount, '٤٥٫٠٠');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(find.text(strings.direct_sale_amount_matches), findsOneWidget);
      await tester.ensureVisible(find.text(strings.direct_sale_insta_pay));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.direct_sale_insta_pay));
      await tester.pumpAndSettle();
      expect(cubit.state.paymentMethod, DirectSalePaymentMethod.instaPay);
      expect(_footer(tester, strings.direct_sale_confirm).onPressed, isNull);
      await tester.tap(find.byKey(const ValueKey('direct-sale-back')));
      await tester.pumpAndSettle();
      expect(cubit.state.quantityFor(directSaleTestProducts.first), 1);
      cubit.continueToPayment();
      await tester.pumpAndSettle();
      expect(cubit.amountController.text, '٤٥٫٠٠');
      await _unmount(tester);
    },
  );

  testWidgets(
    'success only renders from a receipt and new sale resets the flow',
    (tester) async {
      final cubit = DirectSaleCubit(
        initialState: directSaleTestState(DirectSaleStep.success),
      );
      addTearDown(cubit.close);
      await _pump(tester, cubit);
      final strings = _strings(tester);
      expect(find.text(strings.direct_sale_success), findsOneWidget);
      await _capture(tester, 'success');
      await tester.tap(find.text(strings.direct_sale_new_transaction));
      await tester.pumpAndSettle();
      expect(cubit.state.step, DirectSaleStep.customer);
      expect(cubit.state.receipt, isNull);
      await _unmount(tester);
    },
  );

  for (final amount in ['', '13312', '445']) {
    testWidgets('checkout screenshot amount "$amount"', (tester) async {
      final cubit = DirectSaleCubit(
        initialState: directSaleTestState(
          DirectSaleStep.payment,
          amount: amount,
        ),
      );
      addTearDown(cubit.close);
      await _pump(tester, cubit);
      await _capture(tester, 'checkout-${amount.isEmpty ? 'empty' : amount}');
      await _unmount(tester);
    });
  }

  for (final width in [320.0, 360.0, 390.0]) {
    for (final scale in [1.0, 1.5]) {
      testWidgets('all screens fit width $width and text scale $scale', (
        tester,
      ) async {
        for (final step in DirectSaleStep.values) {
          final cubit = DirectSaleCubit(
            initialState: directSaleTestState(step),
          );
          await _pump(tester, cubit, width: width, scale: scale);
          await tester.drag(find.byType(ListView).first, const Offset(0, -400));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await _unmount(tester);
          await cubit.close();
        }
      });
    }
  }

  testWidgets(
    'drawer pushes the real direct sale route and back restores the prior page',
    (tester) async {
      getIt.registerFactory<DirectSaleCubit>(() => DirectSaleCubit());
      addTearDown(() => getIt.unregister<DirectSaleCubit>());
      final saleRoute = AppRouter.routes.configuration.routes
          .whereType<GoRoute>()
          .singleWhere((route) => route.name == RoutesNames.directSale);
      final scaffoldKey = GlobalKey<ScaffoldState>();
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              key: scaffoldKey,
              drawer: AppMenuDrawer(
                userName: 'أحمد',
                userRole: 'مندوب توصيل',
                onDirectSaleTap: () =>
                    context.pushNamed(RoutesNames.directSale),
              ),
              body: const SizedBox(),
            ),
          ),
          saleRoute,
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: router,
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();
      scaffoldKey.currentState!.openDrawer();
      await tester.pumpAndSettle();
      final strings = AppLocalizations.of(
        tester.element(find.byType(AppMenuDrawer)),
      )!;
      await tester.scrollUntilVisible(
        find.text(strings.direct_sale),
        150,
        scrollable: find.descendant(
          of: find.byType(AppMenuDrawer),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.direct_sale));
      await tester.pumpAndSettle();
      expect(find.byType(DirectSaleScreen), findsOneWidget);
      await tester.tap(find.text(strings.direct_sale_cash_customer));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.direct_sale_continue_products));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(DirectSaleScreen), findsOneWidget);
      expect(find.text(strings.direct_sale_choose_customer), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('direct-sale-back')));
      await tester.pumpAndSettle();
      expect(find.byType(DirectSaleScreen), findsNothing);
      expect(scaffoldKey.currentState!.isDrawerOpen, isFalse);
      await _unmount(tester);
    },
  );
}

Future<void> _pump(
  WidgetTester tester,
  DirectSaleCubit cubit, {
  double width = 390,
  double scale = 1,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: BlocProvider.value(value: cubit, child: const DirectSaleScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

AppLocalizations _strings(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(DirectSaleScreen)))!;

Finder _formField(TextEditingController controller) => find.byWidgetPredicate(
  (widget) => widget is TextFormField && widget.controller == controller,
);

ElevatedButton _footer(WidgetTester tester, String label) =>
    tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, label));

Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> _capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('DIRECT_SALE_CAPTURE')) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_captureKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final output = File('build/direct_sale_ui/$name.png');
    await output.parent.create(recursive: true);
    await output.writeAsBytes(data!.buffer.asUint8List());
  });
}
