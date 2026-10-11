import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_theme.dart';
import 'package:storeus_delivery/features/drawer_features/account/data/models/me_response.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/usecases/get_me_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/usecases/logout_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/data/models/stock_transfer_model.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/cubit/stock_transfer_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/screens/stock_transfer_screen.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/widgets/stock_transfer_card.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/widgets/stock_transfer_header.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/widgets/stock_transfer_status_badge.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/layout/presentation/screens/layout_screen.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/app_menu_drawer.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/app_menu_drawer_item.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/app_nav_bar.dart';
import 'package:storeus_delivery/features/notifications/data/models/notifications_response.dart';
import 'package:storeus_delivery/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:storeus_delivery/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_cubit.dart';

const _captureKey = ValueKey('stock-transfer-capture');
final _now = DateTime(2026, 10, 11, 10);

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

  setUp(
    () => getIt.registerFactory<StockTransferCubit>(
      () => StockTransferCubit(now: _now),
    ),
  );
  tearDown(() async => getIt.reset());

  test('filters use screenshot counts and group receipt discrepancies as completed', () async {
    final cubit = StockTransferCubit(now: _now);
    addTearDown(cubit.close);
    expect(cubit.state.filter, StockTransferFilter.awaitingReceipt);
    expect(StockTransferFilter.values.map(cubit.state.countFor), [2, 1, 1, 2]);
    expect(cubit.state.transfers.map((transfer) => transfer.totalQuantity), [
      90,
      50,
      40,
      30,
      20,
      15,
    ]);
    expect(cubit.state.transfers.map((transfer) => transfer.itemCount), [
      3,
      1,
      2,
      1,
      1,
      1,
    ]);

    const expectedNumbers = [
      ['TR-0102', 'TR-0103'],
      ['TR-0099'],
      ['TR-0095'],
      ['TR-0090', 'TR-0088'],
    ];
    for (final filter in StockTransferFilter.values) {
      cubit.selectFilter(filter);
      expect(
        cubit.state.filteredTransfers.map((transfer) => transfer.number),
        expectedNumbers[filter.index],
      );
      final state = cubit.state;
      cubit.selectFilter(filter);
      expect(identical(cubit.state, state), isTrue);
    }
    expect(
      cubit.state.filteredTransfers.last.status,
      StockTransferStatus.receiptDiscrepancy,
    );
  });

  test(
    'drawer feature restores every prior tab and supports switching features',
    () async {
      final layout = LayoutCubit();
      addTearDown(layout.close);
      for (final tab in [0, 1, 2]) {
        layout.selectTap(tab);
        layout.openStockTransfer();
        expect(layout.isStockTransfer, isTrue);
        expect(layout.currentScreen, isA<StockTransferScreen>());
        expect(layout.selectedTap, 3);
        layout.openTreasury();
        layout.openStockTransfer();
        layout.closeDrawerFeature();
        expect(layout.selectedTap, tab);
        expect(layout.currentScreen, same(layout.screens[tab]));
        expect(layout.drawerFeature, isNull);
      }
      layout.openStockTransfer();
      layout.selectTap(1);
      expect(layout.isDrawerFeatureOpen, isFalse);
    },
  );

  testWidgets(
    'all four filters show screenshot records, badges and time labels',
    (tester) async {
      var backPressed = false;
      await _pumpScreen(tester, onBack: () => backPressed = true);
      final headerTop = tester.getTopLeft(find.byType(StockTransferHeader));
      expect(find.text('في انتظار الاستلام (2)'), findsOneWidget);
      expect(find.text('معايا على العربية (1)'), findsOneWidget);
      expect(find.text('في انتظار استلام المخزن (1)'), findsOneWidget);
      expect(find.text('مكتملة (2)'), findsOneWidget);
      expect(_visibleNumbers(tester), ['TR-0102', 'TR-0103']);
      expect(find.text('أنشئ: اليوم 08:30 ص'), findsOneWidget);
      expect(find.text('الوصول المتوقع: اليوم 12:00 م'), findsOneWidget);
      await _capture(tester, 'awaitingReceipt');

      await _selectFilter(tester, StockTransferFilter.onVehicle);
      expect(_visibleNumbers(tester), ['TR-0099']);
      expect(find.text('أنشئ: اليوم 07:10 ص'), findsOneWidget);
      await _capture(tester, 'onVehicle');

      await _selectFilter(tester, StockTransferFilter.awaitingWarehouse);
      expect(_visibleNumbers(tester), ['TR-0095']);
      expect(find.text('الوصول المتوقع: أمس 05:00 م'), findsOneWidget);
      await _capture(tester, 'awaitingWarehouse');

      await _selectFilter(tester, StockTransferFilter.completed);
      expect(_visibleNumbers(tester), ['TR-0090', 'TR-0088']);
      expect(find.text('أنشئ: منذ يومين'), findsOneWidget);
      expect(find.text('يوجد فرق في الاستلام'), findsOneWidget);
      expect(
        tester
            .widgetList<StockTransferStatusBadge>(
              find.byType(StockTransferStatusBadge),
            )
            .map((badge) => badge.status),
        [StockTransferStatus.completed, StockTransferStatus.receiptDiscrepancy],
      );
      await _capture(tester, 'completed');
      expect(tester.getTopLeft(find.byType(StockTransferHeader)), headerTop);

      await tester.tap(find.byKey(const ValueKey('stock-transfer-back')));
      await tester.pumpAndSettle();
      expect(backPressed, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('empty data shows zero counts and an Arabic empty message', (
    tester,
  ) async {
    getIt.unregister<StockTransferCubit>();
    getIt.registerFactory<StockTransferCubit>(
      () => StockTransferCubit(transfers: [], now: _now),
    );
    await _pumpScreen(tester);
    for (final filter in StockTransferFilter.values) {
      await _selectFilter(tester, filter);
      expect(
        find.byKey(const ValueKey('stock-transfer-empty')),
        findsOneWidget,
      );
      expect(find.byType(StockTransferCard), findsNothing);
    }
    expect(find.text('مكتملة (0)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 390.0]) {
    for (final scale in [1.0, 1.5]) {
      testWidgets('all states fit width $width with text scale $scale', (
        tester,
      ) async {
        await _pumpScreen(tester, size: Size(width, 800), textScale: scale);
        for (final filter in StockTransferFilter.values) {
          await _selectFilter(tester, filter);
          final headerTop = tester.getTopLeft(find.byType(StockTransferHeader));
          await tester.drag(find.byType(ListView), const Offset(0, -300));
          await tester.pumpAndSettle();
          expect(
            tester.getTopLeft(find.byType(StockTransferHeader)),
            headerTop,
          );
          expect(tester.takeException(), isNull);
        }
      });
    }
  }

  testWidgets(
    'actual drawer entry highlights the feature and both back actions restore the tab',
    (tester) async {
      getIt.registerFactory<AccountCubit>(
        () => AccountCubit(_TestGetMe(), _TestLogout()),
      );
      getIt.registerFactory<NotificationsCubit>(
        () => NotificationsCubit(
          _TestGetNotifications(),
          _TestMarkNotification(),
        ),
      );
      final layout = LayoutCubit();
      addTearDown(layout.close);
      layout.screens = const [
        Center(child: Text('home-tab')),
        Center(child: Text('trip-tab')),
        Center(child: Text('notifications-tab')),
      ];
      layout.selectTap(0);
      await _pumpScreen(
        tester,
        home: BlocProvider.value(value: layout, child: const LayoutScreen()),
      );

      Future<void> openDrawer() async {
        await tester.tap(
          find.byWidgetPredicate(
            (widget) => widget is NavBarItem && widget.index == 3,
          ),
        );
        await tester.pumpAndSettle();
      }

      Finder transferEntry() => find.descendant(
        of: find.byType(AppMenuDrawer),
        matching: find.text('نقل مخزني'),
      );

      await openDrawer();
      await tester.tap(transferEntry());
      await tester.pumpAndSettle();
      expect(find.byType(StockTransferScreen), findsOneWidget);
      expect(layout.isStockTransfer, isTrue);

      await openDrawer();
      expect(
        tester
            .widget<AppMenuDrawer>(find.byType(AppMenuDrawer))
            .selectedSection,
        AppMenuSection.stockTransfer,
      );
      expect(
        tester
            .widget<AppMenuDrawerItem>(
              find.ancestor(
                of: transferEntry(),
                matching: find.byType(AppMenuDrawerItem),
              ),
            )
            .isSelected,
        isTrue,
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(layout.isStockTransfer, isTrue);
      await tester.tap(find.byKey(const ValueKey('stock-transfer-back')));
      await tester.pumpAndSettle();
      expect(find.text('home-tab'), findsOneWidget);
      expect(layout.selectedTap, 0);

      await openDrawer();
      await tester.tap(transferEntry());
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('home-tab'), findsOneWidget);

      await openDrawer();
      await tester.tap(transferEntry());
      await tester.pumpAndSettle();
      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is NavBarItem && widget.index == 1,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('trip-tab'), findsOneWidget);
      expect(layout.isDrawerFeatureOpen, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}

List<String> _visibleNumbers(WidgetTester tester) => tester
    .widgetList<StockTransferCard>(find.byType(StockTransferCard))
    .map((card) => card.transfer.number)
    .toList();

Future<void> _selectFilter(
  WidgetTester tester,
  StockTransferFilter filter,
) async {
  final finder = find.byKey(ValueKey('stock-transfer-filter-${filter.name}'));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  Size size = const Size(535, 885),
  double textScale = 1,
  VoidCallback? onBack,
  Widget? home,
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
      home:
          home ??
          RepaintBoundary(
            key: _captureKey,
            child: StockTransferScreen(onBack: onBack ?? () {}),
          ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('CAPTURE_STOCK_TRANSFER')) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_captureKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final directory = Directory('build/stock_transfer_previews');
    await directory.create(recursive: true);
    await File('${directory.path}/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
  });
}

class _TestGetMe implements GetMeUsecase {
  @override
  Future<ApiResult<MeResponse>> call() async =>
      const ApiResult.success(MeResponse(success: false));
}

class _TestLogout implements LogoutUsecase {
  @override
  Future<ApiResult<dynamic>> call() async => const ApiResult.success(null);
}

class _TestGetNotifications implements GetNotificationsUsecase {
  @override
  Future<ApiResult<NotificationsResponse>> call() async =>
      const ApiResult.success(
        NotificationsResponse(
          success: true,
          data: NotificationsData(unreadCount: 0, notifications: []),
        ),
      );
}

class _TestMarkNotification implements MarkNotificationAsReadUsecase {
  @override
  Future<ApiResult<dynamic>> call({required int notificationId}) async =>
      const ApiResult.success(null);
}
