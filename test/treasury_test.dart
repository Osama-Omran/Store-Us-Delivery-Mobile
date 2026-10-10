import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_theme.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/data/models/treasury_models.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/cubit/treasury_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/screens/treasury_screen.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/widgets/treasury_header.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/widgets/treasury_inventory_widgets.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/widgets/treasury_wallet_cards.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';

const _captureKey = ValueKey('treasury-test-capture');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final cairo = FontLoader('cairo')
      ..addFont(
        rootBundle.load('assets/fonts/cairo/Cairo-VariableFont_slnt,wght.ttf'),
      );
    await cairo.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  setUp(() => getIt.registerFactory<TreasuryCubit>(() => TreasuryCubit()));
  tearDown(() async => getIt.reset());

  test(
    'receipt totals, cash-only impacts, and running balances match the design',
    () async {
      final cubit = TreasuryCubit();
      final state = cubit.state;
      expect(state.tab, TreasuryTab.wallet);
      expect(state.preview, TreasuryPreview.activeTrip);
      expect(state.data.deliveredTotal, 12500);
      expect(state.data.collectedTotal, 12500);
      expect(state.custodyBalance, 8450);
      expect(state.collections, hasLength(7));
      expect(state.collections.map((entry) => entry.custodyImpact), [
        1450,
        0,
        1800,
        1800,
        0,
        0,
        3400,
      ]);
      expect(state.collections.map((entry) => entry.cashBalanceAfter), [
        1450,
        1450,
        3250,
        5050,
        5050,
        5050,
        8450,
      ]);
      expect(state.remainingUnits, 30);
      expect(state.inventory.map((item) => item.remainingQuantity), [
        8,
        11,
        3,
        4,
        4,
      ]);
      await cubit.close();
    },
  );

  test(
    'settlement retains historical receipts and clears custody and goods',
    () async {
      final cubit = TreasuryCubit();
      final original = cubit.state;
      cubit.selectPreview(TreasuryPreview.settled);
      expect(cubit.state.hasTrip, isTrue);
      expect(cubit.state.custodyBalance, 0);
      expect(cubit.state.collections, hasLength(7));
      expect(cubit.state.collections.last.cashBalanceAfter, 8450);
      expect(cubit.state.inventory, isEmpty);
      expect(cubit.state.remainingUnits, 0);
      cubit.selectPreview(TreasuryPreview.noTrip);
      expect(cubit.state.hasTrip, isFalse);
      expect(cubit.state.custodyBalance, 0);
      expect(cubit.state.collections, isEmpty);
      expect(cubit.state.inventory, isEmpty);
      expect(original.custodyBalance, 8450);
      cubit.selectPreview(TreasuryPreview.activeTrip);
      expect(cubit.state.remainingUnits, 30);
      await cubit.close();
    },
  );

  test('search trims input, ignores code case, and preserves totals and selections', () async {
    final cubit = TreasuryCubit();
    cubit.selectTab(TreasuryTab.vehicleGoods);
    cubit.searchInventory('  item-033  ');
    expect(cubit.state.filteredInventory.single.name, 'بسكويت أوريو');
    expect(cubit.state.remainingUnits, 30);
    cubit.selectTab(TreasuryTab.wallet);
    cubit.selectTab(TreasuryTab.vehicleGoods);
    expect(cubit.state.searchQuery, '  item-033  ');
    cubit.searchInventory('مانجو');
    expect(cubit.state.filteredInventory.single.code, 'ITEM-054');
    cubit.searchInventory('غير موجود');
    expect(cubit.state.filteredInventory, isEmpty);
    cubit.searchInventory('   ');
    expect(cubit.state.filteredInventory, hasLength(5));
    cubit.selectPreview(TreasuryPreview.settled);
    cubit.selectTab(TreasuryTab.wallet);
    expect(cubit.state.preview, TreasuryPreview.settled);
    await cubit.close();
  });

  test(
    'switching drawer features restores the last main tab instead of menu',
    () async {
      final layout = LayoutCubit();
      for (var index = 0; index < 3; index++) {
        layout.selectTap(index);
        layout.openTreasury();
        expect(layout.isTreasury, isTrue);
        expect(layout.isTopRank, isFalse);
        expect(layout.selectedTap, 3);
        layout.openTopRank();
        expect(layout.isTreasury, isFalse);
        layout.openTreasury();
        layout.closeDrawerFeature();
        expect(layout.isDrawerFeatureOpen, isFalse);
        expect(layout.selectedTap, index);
        expect(layout.currentScreen, same(layout.screens[index]));
      }
      layout.openTreasury();
      layout.selectTap(1);
      expect(layout.drawerFeature, isNull);
      await layout.close();
    },
  );

  testWidgets(
    'wallet shows cash and electronic receipts and pending settlement',
    (tester) async {
      await _pumpScreen(tester);
      expect(
        tester
            .widget<TreasuryBalanceCard>(find.byType(TreasuryBalanceCard))
            .balance,
        8450,
      );
      await _reveal(
        tester,
        find.byKey(const ValueKey('treasury-collection-SO-00255')),
      );
      final card = find.byKey(const ValueKey('treasury-collection-SO-00255'));
      expect(
        find.descendant(of: card, matching: find.text('InstaPay')),
        findsOneWidget,
      );
      await _reveal(tester, find.byType(TreasurySettlementNotice));
      expect(
        find.text('حالة التسوية: في انتظار الرجوع للمخزن'),
        findsOneWidget,
      );
      await _capture(tester, 'treasury-wallet-collections');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'preview controls show settlement history and no-trip empty states',
    (tester) async {
      await _pumpScreen(tester);
      await tester.tap(find.byKey(const ValueKey('treasury-preview-settled')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TreasuryBalanceCard>(find.byType(TreasuryBalanceCard))
            .balance,
        0,
      );
      await _reveal(tester, find.byType(TreasurySettlementNotice));
      expect(find.text('تمت التسوية وتأكيد استلام المخزن'), findsOneWidget);
      expect(_cubit(tester).state.collections, hasLength(7));
      await _top(tester);
      await _capture(tester, 'treasury-settled');
      await tester.tap(find.byKey(const ValueKey('treasury-tab-vehicleGoods')));
      await tester.pumpAndSettle();
      expect(find.byType(TreasuryEmptyInventory), findsOneWidget);
      expect(find.byType(TreasuryInventorySearch), findsNothing);
      await tester.tap(find.byKey(const ValueKey('treasury-tab-wallet')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('treasury-preview-noTrip')));
      await tester.pumpAndSettle();
      expect(find.byType(TreasuryEmptyWallet), findsOneWidget);
      expect(find.byType(TreasuryCollectionCard), findsNothing);
      await _capture(tester, 'treasury-no-trip');
      await tester.tap(find.byKey(const ValueKey('treasury-tab-vehicleGoods')));
      await tester.pumpAndSettle();
      expect(find.byType(TreasuryEmptyInventory), findsOneWidget);
      expect(find.byType(TreasuryInventorySummary), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'product search filters by code and name, survives tab changes, and clears',
    (tester) async {
      await _pumpScreen(tester);
      await tester.tap(find.byKey(const ValueKey('treasury-tab-vehicleGoods')));
      await tester.pumpAndSettle();
      final search = find.byKey(const ValueKey('treasury-product-search'));
      await _reveal(tester, search);
      await tester.enterText(search, '  item-033  ');
      await tester.pumpAndSettle();
      expect(
        _cubit(tester).state.filteredInventory.single.name,
        'بسكويت أوريو',
      );
      await _top(tester);
      await tester.tap(find.byKey(const ValueKey('treasury-tab-wallet')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('treasury-tab-vehicleGoods')));
      await tester.pumpAndSettle();
      await _reveal(tester, search);
      expect(tester.widget<TextField>(search).controller!.text, '  item-033  ');
      await tester.enterText(search, 'مانجو');
      await tester.pumpAndSettle();
      expect(_cubit(tester).state.filteredInventory.single.code, 'ITEM-054');
      await tester.enterText(search, 'غير موجود');
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('treasury-no-search-results')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('treasury-clear-search')));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(search).controller!.text, '');
      expect(_cubit(tester).state.filteredInventory, hasLength(5));
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [531.0, 320.0]) {
    testWidgets('wallet and goods fit width $width', (tester) async {
      await _pumpScreen(tester, size: Size(width, 882));
      await _capture(tester, 'treasury-${width.toInt()}-wallet');
      await _reveal(tester, find.byType(TreasurySettlementNotice));
      expect(tester.takeException(), isNull);
      await _top(tester);
      await tester.tap(find.byKey(const ValueKey('treasury-tab-vehicleGoods')));
      await tester.pumpAndSettle();
      await _capture(tester, 'treasury-${width.toInt()}-goods');
      await _reveal(
        tester,
        find.byKey(const ValueKey('treasury-item-ITEM-061')),
      );
      await _capture(tester, 'treasury-${width.toInt()}-goods-bottom');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('both tabs support larger text on a narrow phone', (
    tester,
  ) async {
    await _pumpScreen(tester, size: const Size(320, 740), textScale: 1.5);
    await _reveal(tester, find.byType(TreasurySettlementNotice));
    expect(tester.takeException(), isNull);
    await _top(tester);
    await tester.tap(find.byKey(const ValueKey('treasury-tab-vehicleGoods')));
    await tester.pumpAndSettle();
    await _reveal(tester, find.byKey(const ValueKey('treasury-item-ITEM-061')));
    expect(tester.takeException(), isNull);
  });
}

TreasuryCubit _cubit(WidgetTester tester) =>
    tester.element(find.byType(TreasuryHeader)).read<TreasuryCubit>();

Finder _scrollable() => find
    .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
    .first;

Future<void> _top(WidgetTester tester) async {
  tester.state<ScrollableState>(_scrollable()).position.jumpTo(0);
  await tester.pumpAndSettle();
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 250, scrollable: _scrollable());
  await tester.pumpAndSettle();
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  Size size = const Size(531, 882),
  double textScale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: const RepaintBoundary(key: _captureKey, child: TreasuryScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('CAPTURE_TREASURY')) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_captureKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    await File('${Directory.systemTemp.path}/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
  });
}
