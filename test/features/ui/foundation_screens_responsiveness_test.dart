import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:storeus_delivery/core/theme/app_theme.dart';
import 'package:storeus_delivery/core/widgets/custom_button.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_state.dart';
import 'package:storeus_delivery/features/home/presentation/widgets/home_current_trip_card.dart';
import 'package:storeus_delivery/features/home/presentation/widgets/home_order_statistics.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/app_menu_drawer_item.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/app_nav_bar.dart';
import 'package:storeus_delivery/features/login/data/models/login_request_body.dart';
import 'package:storeus_delivery/features/login/data/models/login_response.dart';
import 'package:storeus_delivery/features/login/domain/usecases/login_usecase.dart';
import 'package:storeus_delivery/features/login/presentation/cubit/login_cubit.dart';
import 'package:storeus_delivery/features/login/presentation/cubit/login_state.dart';
import 'package:storeus_delivery/features/login/presentation/screens/login_screen.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_state.dart';

class _LoginUsecase extends Fake implements LoginUsecase {
  var calls = 0;

  @override
  Future<ApiResult<LoginResponse>> call({
    required LoginRequestBody body,
  }) async {
    calls++;
    throw StateError('Invalid form data must never reach the login use case.');
  }
}

class _NotificationsCubit extends Cubit<NotificationsState>
    implements NotificationsCubit {
  _NotificationsCubit()
    : super(
        NotificationsSuccessState(notifications: const [], unreadCount: 105),
      );

  var refreshes = 0;

  @override
  Future<void> getNotifications() async => refreshes++;

  @override
  Future<String?> markAsRead(int notificationId) async => null;

  void clearUnread() {
    emit(NotificationsSuccessState(notifications: const [], unreadCount: 0));
  }
}

class _TripTabCubit extends Cubit<TripTabState> implements TripTabCubit {
  _TripTabCubit()
    : super(
        TripTabSuccessState(
          const CurrentTripData(
            id: 7,
            number: 'TRIP-7',
            status: 'SHIPPED',
            acceptance: TripAcceptance(status: 'PENDING'),
          ),
        ),
      );

  @override
  Future<void> getCurrentTrip() async {}

  @override
  Future<void> getTripOrders() async {}

  void clearTrip() => emit(TripTabEmptyState());
}

Widget _app({required Widget home, double textScale = 1}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    locale: const Locale('ar'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: home,
  );
}

void _compactView(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(320, 740);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetViewInsets);
}

Future<void> _savePreview(
  WidgetTester tester,
  GlobalKey key,
  String name,
) async {
  if (!const bool.fromEnvironment('UI_POLISH_PREVIEW')) return;
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('build/ui_polish_preview_$name.png')
        .writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final cairo = FontLoader('cairo')
      ..addFont(
        rootBundle.load('assets/fonts/cairo/Cairo-VariableFont_slnt,wght.ttf'),
      );
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await Future.wait([cairo.load(), icons.load()]);
  });

  testWidgets(
    'Login preserves validation and password visibility with keyboard',
    (tester) async {
      _compactView(tester);
      PackageInfo.setMockInitialValues(
        appName: 'Store Us Delivery',
        packageName: 'com.storeus.delivery',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );
      final usecase = _LoginUsecase();
      final cubit = LoginCubit(usecase);
      addTearDown(cubit.close);
      final previewKey = GlobalKey();

      await tester.pumpWidget(
        BlocProvider<LoginCubit>.value(
          value: cubit,
          child: _app(
            textScale: 1.3,
            home: RepaintBoundary(key: previewKey, child: const LoginScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await _savePreview(tester, previewKey, 'login');
      final strings = AppLocalizations.of(
        tester.element(find.byType(LoginScreen)),
      )!;

      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      final passwordField = find.byType(TextFormField).last;
      await tester.ensureVisible(passwordField);
      await tester.tap(passwordField);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField).last).obscureText,
        isTrue,
      );
      await tester.ensureVisible(find.byTooltip(strings.show_password));
      await tester.tap(find.byTooltip(strings.show_password));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField).last).obscureText,
        isFalse,
      );
      await tester.tap(find.byTooltip(strings.hide_password));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField).last).obscureText,
        isTrue,
      );

      await tester.ensureVisible(find.byType(CustomButton));
      await tester.tap(find.byType(CustomButton));
      await tester.pumpAndSettle();
      expect(find.text(strings.email_is_required), findsOneWidget);
      expect(find.text(strings.password_is_required), findsOneWidget);
      expect(usecase.calls, 0);
      expect(cubit.state, isA<LoginInitial>());

      final emailField = find.byType(TextFormField).first;
      await tester.ensureVisible(emailField);
      await tester.enterText(emailField, 'invalid-email');
      await tester.ensureVisible(find.byType(CustomButton));
      await tester.tap(find.byType(CustomButton));
      await tester.pumpAndSettle();
      expect(find.text(strings.please_enter_a_valid_email), findsOneWidget);
      expect(find.text(strings.password_is_required), findsOneWidget);
      expect(usecase.calls, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Nav selection, drawer opening and badges work with enlarged RTL',
    (tester) async {
      _compactView(tester);
      final layout = LayoutCubit();
      final notifications = _NotificationsCubit();
      final trip = _TripTabCubit();
      addTearDown(layout.close);
      addTearDown(notifications.close);
      addTearDown(trip.close);
      final scaffoldKey = GlobalKey<ScaffoldState>();

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<LayoutCubit>.value(value: layout),
            BlocProvider<NotificationsCubit>.value(value: notifications),
            BlocProvider<TripTabCubit>.value(value: trip),
          ],
          child: _app(
            textScale: 2,
            home: Scaffold(
              key: scaffoldKey,
              drawer: const Drawer(child: Center(child: Text('drawer-open'))),
              body: const Align(
                alignment: Alignment.bottomCenter,
                child: AppNavBar(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      Finder tab(int index) => find.byWidgetPredicate(
        (widget) => widget is NavBarItem && widget.index == index,
      );
      final menuBadge = find.descendant(of: tab(3), matching: find.text('1'));
      expect(find.text('99+'), findsOneWidget);
      expect(menuBadge, findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(tab(0));
      await tester.pumpAndSettle();
      expect(layout.selectedTap, 0);
      await tester.tap(tab(1));
      await tester.pumpAndSettle();
      expect(layout.selectedTap, 1);
      await tester.tap(tab(2));
      await tester.pumpAndSettle();
      expect(layout.selectedTap, 2);
      expect(notifications.refreshes, 1);
      await tester.tap(tab(2));
      await tester.pumpAndSettle();
      expect(notifications.refreshes, 1);

      notifications.clearUnread();
      trip.clearTrip();
      await tester.pumpAndSettle();
      expect(find.text('99+'), findsNothing);
      expect(menuBadge, findsNothing);
      await tester.tap(tab(3));
      await tester.pumpAndSettle();
      expect(scaffoldKey.currentState!.isDrawerOpen, isTrue);
      expect(find.text('drawer-open'), findsOneWidget);
      expect(layout.selectedTap, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Drawer labels wrap without losing badges or taps at 200 percent',
    (tester) async {
      _compactView(tester);
      var taps = 0;
      await tester.pumpWidget(
        _app(
          textScale: 2,
          home: Scaffold(
            body: Center(
              child: AppMenuDrawerItem(
                title: 'استلام السيارة والبضائع الخاصة بالرحلة',
                icon: Icons.local_shipping_outlined,
                badgeCount: 12,
                onTap: () => taps++,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('12'), findsOneWidget);
      expect(
        tester.getSize(find.byType(AppMenuDrawerItem)).height,
        greaterThan(64),
      );
      await tester.tap(find.byType(AppMenuDrawerItem));
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(tester.takeException(), isNull);
    },
  );

  for (final textScale in [1.5, 2.0]) {
    testWidgets(
      'Home statistics keep complete one-line counts and equal heights at $textScale scale',
      (tester) async {
        _compactView(tester);
        await tester.pumpWidget(
          _app(
            textScale: textScale,
            home: const Scaffold(
              body: Center(
                child: SizedBox(
                  width: 248,
                  child: HomeOrderStatistics(
                    total: 120,
                    delivered: 12,
                    remaining: 108,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final heights = <double>[];
        for (final count in ['120', '12', '108']) {
          final number = find.text(count);
          final paragraph = tester.renderObject<RenderParagraph>(
            find.descendant(of: number, matching: find.byType(RichText)),
          );
          final boxes = paragraph.getBoxesForSelection(
            TextSelection(baseOffset: 0, extentOffset: count.length),
          );
          expect(boxes, hasLength(1));
          expect(paragraph.didExceedMaxLines, isFalse);
          final tile = find
              .ancestor(of: number, matching: find.byType(Container))
              .first;
          heights.add(tester.getSize(tile).height);
        }
        expect(heights[1], closeTo(heights[0], 0.01));
        expect(heights[2], closeTo(heights[0], 0.01));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Home card handles long trip details and continues the same trip',
    (tester) async {
      _compactView(tester);
      final layout = LayoutCubit()..selectTap(0);
      addTearDown(layout.close);
      const trip = CurrentTripData(
        id: 7,
        number: 'TRIP-2026-123456789012345678901234567890',
        status: 'SHIPPED',
        warehouse: TripWarehouse(
          name: 'المخزن المركزي الرئيسي لتوزيع منتجات القاهرة والجيزة',
        ),
        vehicle: TripVehicle(name: 'سيارة التوزيع الرئيسية رقم ١٢٣٤٥'),
        driver: TripDriver(name: 'أحمد محمد عبد الرحمن'),
        acceptance: TripAcceptance(status: 'ACCEPTED'),
        ordersSummary: TripOrdersSummary(total: 120),
      );
      final previewKey = GlobalKey();
      await tester.pumpWidget(
        BlocProvider<LayoutCubit>.value(
          value: layout,
          child: _app(
            textScale: 1.5,
            home: RepaintBoundary(
              key: previewKey,
              child: Scaffold(
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: HomeCurrentTripCard(
                    state: HomeSuccessState(
                      trip,
                      ordersStatus: HomeOrdersStatus.success,
                    ),
                    onRetryOrders: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('#${trip.number}'), findsOneWidget);
      expect(find.text(trip.warehouse!.name!), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _savePreview(tester, previewKey, 'home');
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(layout.selectedTap, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
