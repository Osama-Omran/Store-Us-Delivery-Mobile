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
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/app_theme.dart';
import 'package:storeus_delivery/features/drawer_features/account/data/models/me_response.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/repo/account_repo_interface.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/usecases/get_me_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/usecases/logout_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/layout/presentation/screens/layout_screen.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/app_menu_drawer.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/app_nav_bar.dart';
import 'package:storeus_delivery/features/notifications/data/models/notifications_response.dart';
import 'package:storeus_delivery/features/notifications/domain/repo/notifications_repo_interface.dart';
import 'package:storeus_delivery/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:storeus_delivery/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/cubit/top_rank_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/screens/top_rank_screen.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_filters.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/data/models/treasury_models.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/cubit/treasury_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/widgets/treasury_selectors.dart';

const _captureKey = ValueKey('top-rank-test-capture');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final loader = FontLoader('cairo')
      ..addFont(
        rootBundle.load('assets/fonts/cairo/Cairo-VariableFont_slnt,wght.ttf'),
      );
    await loader.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  setUp(() {
    getIt.registerFactory<TopRankCubit>(() => TopRankCubit());
    getIt.registerFactory<TreasuryCubit>(() => TreasuryCubit());
    final account = _AccountRepo();
    final notifications = _NotificationsRepo();
    getIt.registerFactory<AccountCubit>(
      () => AccountCubit(GetMeUsecase(account), LogoutUsecase(account)),
    );
    getIt.registerFactory<NotificationsCubit>(
      () => NotificationsCubit(
        GetNotificationsUsecase(notifications),
        MarkNotificationAsReadUsecase(notifications),
      ),
    );
  });

  tearDown(() async => getIt.reset());

  test(
    'Top Rank restores every previous tab and supports normal tab switching',
    () async {
      final cubit = LayoutCubit();
      for (var index = 0; index < 3; index++) {
        cubit.selectTap(index);
        cubit.openTopRank();
        expect(cubit.selectedTap, 3);
        expect(cubit.currentScreen, isA<TopRankScreen>());
        cubit.openTopRank();
        cubit.closeTopRank();
        expect(cubit.selectedTap, index);
        expect(cubit.currentScreen, same(cubit.screens[index]));
      }
      cubit.openTopRank();
      cubit.selectTap(0);
      expect(cubit.isTopRank, isFalse);
      expect(cubit.currentScreen, same(cubit.screens[0]));
      cubit.selectTap(3);
      expect(cubit.selectedTap, 0);
      await cubit.close();
    },
  );

  testWidgets('filter controls update the selected preview', (tester) async {
    await _pumpScreen(tester);
    await tester.tap(find.byKey(const ValueKey('top-rank-period-week')));
    await tester.pumpAndSettle();
    final cubit = tester
        .element(find.byType(TopRankFilters))
        .read<TopRankCubit>();
    expect(cubit.state.period, TopRankPeriod.week);

    await tester.tap(find.byKey(const ValueKey('top-rank-warehouse')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مخزن مدينة نصر (تجريبي)').last);
    await tester.pumpAndSettle();
    expect(cubit.state.warehouse, TopRankWarehouse.nasrCity);

    await tester.ensureVisible(
      find.byKey(const ValueKey('top-rank-role-drivers')),
    );
    await tester.tap(find.byKey(const ValueKey('top-rank-role-drivers')));
    await tester.pumpAndSettle();
    expect(cubit.state.role, TopRankRole.drivers);
    expect(
      cubit.state.entries.every((entry) => entry.id.startsWith('drivers-')),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('winner and ranking rows open details for the selected person', (
    tester,
  ) async {
    await _pumpScreen(tester);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('top-rank-winner-details')),
      160,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('top-rank-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.byKey(const ValueKey('top-rank-winner-details')));
    await tester.pumpAndSettle();
    final sheet = find.byKey(const ValueKey('top-rank-details-sheet'));
    expect(
      find.descendant(of: sheet, matching: find.text('أحمد محمد')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('96%')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('99%')),
      findsOneWidget,
    );
    await tester.tap(
      find.descendant(of: sheet, matching: find.byIcon(Icons.close_rounded)),
    );
    await tester.pumpAndSettle();

    final row = find.byKey(const ValueKey('top-rank-entry-representatives-1'));
    await tester.scrollUntilVisible(
      row,
      160,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('top-rank-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: sheet, matching: find.text('محمود علي')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('94%')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('unqualified row details show unavailable metrics', (
    tester,
  ) async {
    await _pumpScreen(tester);
    final row = find.byKey(const ValueKey('top-rank-entry-representatives-5'));
    await tester.scrollUntilVisible(
      row,
      250,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('top-rank-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();
    final sheet = find.byKey(const ValueKey('top-rank-details-sheet'));
    expect(
      find.descendant(of: sheet, matching: find.text('حسام فتحي')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('غير مؤهل للترتيب بعد')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('—')),
      findsNWidgets(3),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'drawer entry, menu highlight, header back, system back and reopen',
    (tester) async {
      final layout = await _pumpLayout(tester);
      await _openFromDrawer(tester);
      expect(find.byType(TopRankScreen), findsOneWidget);
      final menuLabel = find.descendant(
        of: find.widgetWithText(NavBarItem, 'القائمة'),
        matching: find.byType(Text),
      );
      expect(tester.widget<Text>(menuLabel).style!.color, AppColors.primary);
      await tester.tap(find.byKey(const ValueKey('top-rank-back')));
      await tester.pumpAndSettle();
      expect(layout.selectedTap, 1);
      expect(find.text('tab-1'), findsOneWidget);

      await _openFromDrawer(tester);
      await tester.tap(find.byKey(const ValueKey('top-rank-period-week')));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(layout.isTopRank, isFalse);

      await _openFromDrawer(tester);
      final filters = tester.widget<TopRankFilters>(
        find.byType(TopRankFilters),
      );
      expect(filters.period, TopRankPeriod.thisMonth);

      await tester.tap(find.widgetWithText(NavBarItem, 'القائمة'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<AppMenuDrawer>(find.byType(AppMenuDrawer))
            .selectedSection,
        AppMenuSection.topRank,
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(layout.isTopRank, isTrue);
      expect(find.byType(AppMenuDrawer), findsNothing);

      await tester.tap(find.widgetWithText(NavBarItem, 'الرئيسية'));
      await tester.pumpAndSettle();
      expect(layout.selectedTap, 0);
      await _openFromDrawer(tester);
      await tester.tap(find.widgetWithText(NavBarItem, 'الإشعارات'));
      await tester.pumpAndSettle();
      expect(layout.selectedTap, 2);
      await _openFromDrawer(tester);
      await tester.tap(find.widgetWithText(NavBarItem, 'الرحلة'));
      await tester.pumpAndSettle();
      expect(layout.selectedTap, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Treasury drawer navigation, back, main tabs and reopening defaults',
    (tester) async {
      final layout = await _pumpLayout(tester);
      await tester.tap(find.widgetWithText(NavBarItem, 'القائمة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('الخزينة'));
      await tester.pumpAndSettle();
      expect(layout.isTreasury, isTrue);
      final menuLabel = find.descendant(
        of: find.widgetWithText(NavBarItem, 'القائمة'),
        matching: find.byType(Text),
      );
      expect(tester.widget<Text>(menuLabel).style!.color, AppColors.primary);
      await tester.tap(find.byKey(const ValueKey('treasury-preview-noTrip')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(NavBarItem, 'القائمة'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<AppMenuDrawer>(find.byType(AppMenuDrawer))
            .selectedSection,
        AppMenuSection.treasury,
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(layout.isTreasury, isTrue);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(layout.selectedTap, 1);
      layout.openTreasury();
      await tester.pumpAndSettle();
      final treasury = tester
          .element(find.byType(TreasuryTabs))
          .read<TreasuryCubit>();
      expect(treasury.state.tab, TreasuryTab.wallet);
      expect(treasury.state.preview, TreasuryPreview.activeTrip);
      expect(treasury.state.searchQuery, '');
      await _openFromDrawer(tester);
      expect(layout.isTopRank, isTrue);
      await tester.tap(find.widgetWithText(NavBarItem, 'القائمة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('الخزينة'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(layout.selectedTap, 1);
      for (final entry in [(0, 'الرئيسية'), (2, 'الإشعارات'), (1, 'الرحلة')]) {
        layout.openTreasury();
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(NavBarItem, entry.$2));
        await tester.pumpAndSettle();
        expect(layout.selectedTap, entry.$1);
        expect(layout.isDrawerFeatureOpen, isFalse);
      }
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [531.0, 320.0]) {
    testWidgets('Treasury content clears the navbar at width $width', (
      tester,
    ) async {
      final layout = await _pumpLayout(tester, size: Size(width, 882));
      layout.openTreasury();
      await tester.pumpAndSettle();
      await _capture(tester, 'treasury-${width.toInt()}-layout-wallet');
      final walletScroll = find
          .descendant(
            of: find.byKey(const ValueKey('treasury-scroll-wallet')),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('treasury-settlement-notice')),
        300,
        scrollable: walletScroll,
      );
      await tester.pumpAndSettle();
      tester
          .state<ScrollableState>(walletScroll)
          .position
          .jumpTo(
            tester
                .state<ScrollableState>(walletScroll)
                .position
                .maxScrollExtent,
          );
      await tester.pumpAndSettle();
      expect(
        tester
            .getRect(find.byKey(const ValueKey('treasury-settlement-notice')))
            .bottom,
        lessThan(tester.getRect(find.byType(AppNavBar)).top),
      );
      await _capture(tester, 'treasury-${width.toInt()}-layout-collections');
      tester.state<ScrollableState>(walletScroll).position.jumpTo(0);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('treasury-tab-vehicleGoods')));
      await tester.pumpAndSettle();
      await _capture(tester, 'treasury-${width.toInt()}-layout-goods');
      final goodsScroll = find
          .descendant(
            of: find.byKey(const ValueKey('treasury-scroll-vehicleGoods')),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.drag(goodsScroll, const Offset(0, -1800));
      await tester.pumpAndSettle();
      expect(
        tester
            .getRect(find.text('للعرض فقط — لا يمكن تعديل المخزون من هنا'))
            .bottom,
        lessThan(tester.getRect(find.byType(AppNavBar)).top),
      );
      await _capture(tester, 'treasury-${width.toInt()}-layout-goods-bottom');
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'layout has no overflow at width $width and list clears the navbar',
      (tester) async {
        await _pumpLayout(tester, size: Size(width, 882), openTopRank: true);
        await _capture(tester, 'top-rank-${width.toInt()}-initial');
        final scrollable = find
            .descendant(
              of: find.byKey(const ValueKey('top-rank-scroll')),
              matching: find.byType(Scrollable),
            )
            .first;
        await tester.drag(scrollable, const Offset(0, -1600));
        await tester.pumpAndSettle();
        final lastRow = find.byKey(
          const ValueKey('top-rank-entry-representatives-5'),
        );
        expect(
          tester.getRect(lastRow).bottom,
          lessThan(tester.getRect(find.byType(AppNavBar)).top),
        );
        await _capture(tester, 'top-rank-${width.toInt()}-list');
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('screen and details support larger text on a narrow phone', (
    tester,
  ) async {
    await _pumpScreen(tester, size: const Size(320, 740), textScale: 1.5);
    final row = find.byKey(const ValueKey('top-rank-entry-representatives-5'));
    await tester.scrollUntilVisible(
      row,
      250,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('top-rank-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('top-rank-details-sheet')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

Widget _app(Widget child, {double textScale = 1}) {
  return MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: AppTheme.lightTheme,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: RepaintBoundary(key: _captureKey, child: child),
  );
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    _app(TopRankScreen(onBack: () {}), textScale: textScale),
  );
  await tester.pumpAndSettle();
}

Future<LayoutCubit> _pumpLayout(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  bool openTopRank = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final layout = LayoutCubit();
  layout.screens = List.generate(
    3,
    (index) => Scaffold(body: Center(child: Text('tab-$index'))),
  );
  layout.currentScreen = layout.screens[1];
  if (openTopRank) layout.openTopRank();
  addTearDown(layout.close);
  await tester.pumpWidget(
    _app(BlocProvider.value(value: layout, child: const LayoutScreen())),
  );
  await tester.pumpAndSettle();
  return layout;
}

Future<void> _openFromDrawer(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(NavBarItem, 'القائمة'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('لوحة الترتيب · Top Rank'));
  await tester.pumpAndSettle();
}

Future<void> _capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('CAPTURE_TOP_RANK') &&
      !const bool.fromEnvironment('CAPTURE_TREASURY')) {
    return;
  }
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_captureKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final file = File('${Directory.systemTemp.path}/$name.png');
    await file.writeAsBytes(data!.buffer.asUint8List());
  });
}

class _AccountRepo implements AccountRepoInterface {
  @override
  Future<ApiResult<MeResponse>> getMe() async => const ApiResult.success(
    MeResponse(
      success: true,
      data: AccountUser(
        id: 1,
        name: 'مستخدم تجريبي',
        employeeId: '1',
        email: 'test@example.com',
        role: 'Delivery Representative',
      ),
    ),
  );

  @override
  Future<ApiResult<dynamic>> logout() async => const ApiResult.success(null);
}

class _NotificationsRepo implements NotificationsRepoInterface {
  @override
  Future<ApiResult<NotificationsResponse>> getNotifications() async =>
      const ApiResult.success(
        NotificationsResponse(
          success: true,
          data: NotificationsData(unreadCount: 0, notifications: []),
        ),
      );

  @override
  Future<ApiResult<dynamic>> markAsRead({required int notificationId}) async =>
      const ApiResult.success(null);
}
