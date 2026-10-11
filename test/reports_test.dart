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
import 'package:storeus_delivery/features/drawer_features/reports/data/models/reports_models.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/cubit/reports_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/screens/reports_screen.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_distribution_card.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_filters.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_header.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_summary_card.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_trip_performance_card.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/layout/presentation/screens/layout_screen.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/app_menu_drawer.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/app_nav_bar.dart';
import 'package:storeus_delivery/features/notifications/data/models/notifications_response.dart';
import 'package:storeus_delivery/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:storeus_delivery/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_cubit.dart';

const _captureKey = ValueKey('reports-capture');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;

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
  setUp(() => getIt.registerFactory<ReportsCubit>(() => ReportsCubit()));
  tearDown(() async => getIt.reset());

  test(
    'Reports restores the previous main tab across other drawer features',
    () async {
      final layout = LayoutCubit();
      addTearDown(layout.close);
      for (final tab in [0, 1, 2]) {
        layout.selectTap(tab);
        layout.openReports();
        expect(layout.isReports, isTrue);
        expect(layout.currentScreen, isA<ReportsScreen>());
        layout.openStockTransfer();
        layout.openReports();
        layout.closeDrawerFeature();
        expect(layout.selectedTap, tab);
        expect(layout.currentScreen, same(layout.screens[tab]));
      }
    },
  );

  testWidgets(
    'today summary, distribution proportions and trip labels match the design',
    (tester) async {
      await _pumpScreen(tester);
      final summary = tester
          .widget<ReportsSummaryCard>(find.byType(ReportsSummaryCard))
          .summary;
      expect(summary.totalOrders, 22);
      expect(summary.collectedAmount, 14650);
      expect(find.text('82%'), findsOneWidget);
      expect(find.text('١٤,٦٥٠ ج.م'), findsOneWidget);
      expect(_ring(tester).value, 0.82);
      expect(find.byKey(const ValueKey('reports-from-date')), findsNothing);
      await _capture(tester, 'today');
      await _reveal(tester, find.byType(ReportsDistributionCard));
      final delivered = tester
          .getSize(find.byKey(const ValueKey('reports-distribution-delivered')))
          .width;
      final partial = tester
          .getSize(find.byKey(const ValueKey('reports-distribution-partial')))
          .width;
      final undelivered = tester
          .getSize(
            find.byKey(const ValueKey('reports-distribution-undelivered')),
          )
          .width;
      expect(delivered / partial, closeTo(9, 0.001));
      expect(partial, closeTo(undelivered, 0.001));
      await _bottom(tester);
      for (final value in [
        '88%',
        '95%',
        '90%',
        '100%',
        '92%',
        '0021',
        '0022',
        '0023',
        '0024',
        '0025',
      ]) {
        expect(find.text(value), findsOneWidget);
      }
      await _capture(tester, 'trip-performance');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('trip dropdown updates the report and can return to all trips', (
    tester,
  ) async {
    await _pumpScreen(tester);
    await tester.tap(find.byKey(const ValueKey('reports-trip')));
    await tester.pumpAndSettle();
    for (final trip in reportTripNumbers) {
      expect(find.text(trip), findsOneWidget);
    }
    await _capture(tester, 'trip-dropdown');
    await tester.tap(find.text('TRIP-0023').last);
    await tester.pumpAndSettle();
    expect(_cubit(tester).state.tripNumber, 'TRIP-0023');
    expect(_cubit(tester).state.data.summary.totalOrders, lessThan(22));
    expect(
      _cubit(tester).state.data.tripPerformance.single.tripNumber,
      'TRIP-0023',
    );
    await tester.tap(find.byKey(const ValueKey('reports-trip')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('كل الرحلات').last);
    await tester.pumpAndSettle();
    expect(_cubit(tester).state.data.summary.totalOrders, 22);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'custom dates match the reference and date pickers preserve or update the range',
    (tester) async {
      await _pumpScreen(tester);
      await _selectPeriod(tester, ReportsPeriod.custom);
      expect(find.text('01/09/2026'), findsOneWidget);
      expect(find.text('04/10/2026'), findsOneWidget);
      expect(find.text('91%'), findsOneWidget);
      expect(_cubit(tester).state.data.summary.collectedAmount, 42100);
      await _capture(tester, 'custom');

      await tester.tap(find.byKey(const ValueKey('reports-from-date')));
      await tester.pumpAndSettle();
      var picker = tester.widget<CalendarDatePicker>(
        find.byType(CalendarDatePicker),
      );
      expect(picker.lastDate, DateTime(2026, 10, 4));
      var localizations = MaterialLocalizations.of(
        tester.element(find.byType(DatePickerDialog)),
      );
      await tester.tap(find.text(localizations.cancelButtonLabel));
      await tester.pumpAndSettle();
      expect(_cubit(tester).state.fromDate, DateTime(2026, 9, 1));

      await tester.tap(find.byKey(const ValueKey('reports-from-date')));
      await tester.pumpAndSettle();
      localizations = MaterialLocalizations.of(
        tester.element(find.byType(DatePickerDialog)),
      );
      await tester.tap(find.byTooltip(localizations.inputDateModeButtonLabel));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField),
        localizations.formatCompactDate(DateTime(2026, 9, 15)),
      );
      await tester.tap(find.text(localizations.okButtonLabel));
      await tester.pumpAndSettle();
      expect(_cubit(tester).state.fromDate, DateTime(2026, 9, 15));
      expect(_cubit(tester).state.data.summary.totalOrders, lessThan(64));

      await tester.tap(find.byKey(const ValueKey('reports-to-date')));
      await tester.pumpAndSettle();
      picker = tester.widget<CalendarDatePicker>(
        find.byType(CalendarDatePicker),
      );
      expect(picker.firstDate, DateTime(2026, 9, 15));
      localizations = MaterialLocalizations.of(
        tester.element(find.byType(DatePickerDialog)),
      );
      await tester.tap(find.text(localizations.cancelButtonLabel));
      await tester.pumpAndSettle();
      await _selectPeriod(tester, ReportsPeriod.week);
      expect(find.byKey(const ValueKey('reports-from-date')), findsNothing);
      await _selectPeriod(tester, ReportsPeriod.custom);
      expect(find.text('15/09/2026'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('empty custom reports show zero rate and localized empty state', (
    tester,
  ) async {
    await _pumpScreen(tester);
    final cubit = _cubit(tester);
    cubit.selectPeriod(ReportsPeriod.custom);
    cubit.selectDateRange(
      fromDate: DateTime(2025, 1, 1),
      toDate: DateTime(2025, 2, 1),
    );
    await tester.pumpAndSettle();
    expect(find.text('0%'), findsOneWidget);
    expect(_ring(tester).value, 0);
    expect(
      find.byKey(const ValueKey('reports-distribution-delivered')),
      findsNothing,
    );
    await _bottom(tester);
    expect(find.text('لا توجد بيانات تقارير لهذه الفترة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 390.0]) {
    for (final scale in [1.0, 1.5]) {
      testWidgets(
        'reports fit width $width with text scale $scale and keep the header fixed',
        (tester) async {
          await _pumpScreen(tester, size: Size(width, 800), textScale: scale);
          final headerTop = tester.getTopLeft(find.byType(ReportsHeader));
          for (final period in ReportsPeriod.values) {
            await _top(tester);
            await _selectPeriod(tester, period);
            await _bottom(tester);
            expect(tester.getTopLeft(find.byType(ReportsHeader)), headerTop);
            expect(tester.takeException(), isNull);
          }
        },
      );
    }
  }

  testWidgets(
    'drawer entry, highlight, system back and main tabs work and content clears navigation',
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

      Future<void> openReports() async {
        await openDrawer();
        final entry = find.descendant(
          of: find.byType(AppMenuDrawer),
          matching: find.text('التقارير'),
        );
        await tester.ensureVisible(entry);
        await tester.tap(entry);
        await tester.pumpAndSettle();
      }

      await openReports();
      expect(find.byType(ReportsScreen), findsOneWidget);
      expect(layout.isReports, isTrue);
      await _bottom(tester);
      expect(
        tester.getBottomLeft(find.byType(ReportsTripPerformanceCard)).dy,
        lessThan(tester.getTopLeft(find.byType(AppNavBar)).dy),
      );
      await openDrawer();
      expect(
        tester
            .widget<AppMenuDrawer>(find.byType(AppMenuDrawer))
            .selectedSection,
        AppMenuSection.reports,
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(layout.isReports, isTrue);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('home-tab'), findsOneWidget);
      await openReports();
      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is NavBarItem && widget.index == 1,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('trip-tab'), findsOneWidget);
      expect(layout.isDrawerFeatureOpen, isFalse);
      await openReports();
      expect(_cubit(tester).state.period, ReportsPeriod.today);
      expect(_cubit(tester).state.tripNumber, allReportTrips);
      expect(tester.takeException(), isNull);
    },
  );
}

ReportsCubit _cubit(WidgetTester tester) =>
    tester.element(find.byType(ReportsFilters)).read<ReportsCubit>();
CircularProgressIndicator _ring(WidgetTester tester) =>
    tester.widget<CircularProgressIndicator>(
      find.byKey(const ValueKey('reports-delivery-ring')),
    );
Finder _scrollable() => find
    .descendant(
      of: find.byKey(const ValueKey('reports-scroll')),
      matching: find.byType(Scrollable),
    )
    .first;

Future<void> _top(WidgetTester tester) async {
  tester.state<ScrollableState>(_scrollable()).position.jumpTo(0);
  await tester.pumpAndSettle();
}

Future<void> _bottom(WidgetTester tester) async {
  await _reveal(tester, find.byType(ReportsTripPerformanceCard));
  final position = tester.state<ScrollableState>(_scrollable()).position;
  position.jumpTo(position.maxScrollExtent);
  await tester.pumpAndSettle();
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 250, scrollable: _scrollable());
  await tester.pumpAndSettle();
}

Future<void> _selectPeriod(WidgetTester tester, ReportsPeriod period) async {
  final finder = find.byKey(ValueKey('reports-period-${period.name}'));
  await Scrollable.of(
    tester.element(finder),
    axis: Axis.horizontal,
  ).position.ensureVisible(tester.renderObject(finder), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
  expect(_cubit(tester).state.period, period);
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  Size size = const Size(553, 901),
  double textScale = 1,
  Widget? home,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: home ?? const ReportsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('CAPTURE_REPORTS')) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_captureKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final directory = Directory('build/reports_previews');
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
