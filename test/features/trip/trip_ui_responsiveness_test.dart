import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:storeus_delivery/core/theme/app_theme.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/presentation/widgets/cancel_delivery_confirmation_sheet.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_flow_data.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_draft_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_draft_state.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_financial_result_card.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_flow_header.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_order_header.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_order_item_card.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_payment_confirmation_sheet.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_summary_bar.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_customer_actions.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_details_financial_card.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_details_header.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_details_items_card.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/receiving_photo_placeholder.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/trip_receiving_confirmation_sheet.dart';
import 'package:storeus_delivery/features/trip/trip_map/presentation/widgets/trip_map_toolbar.dart';
import 'package:storeus_delivery/features/trip/trip_map/data/models/trip_map_stop.dart';
import 'package:storeus_delivery/features/trip/trip_map/data/models/trip_route_result.dart';
import 'package:storeus_delivery/features/trip/trip_map/presentation/widgets/trip_map_stop_sheet.dart';

const _item = OrderDetailsItem(
  itemCode: 'PRODUCT-1234567890',
  itemName: 'منتج باسم طويل لاختبار عرض بيانات المنتجات والكميات',
  uom: 'وحدة تعبئة كبيرة',
  orderedQty: 123456,
  vehicleAvailableQty: 123456,
  maxDeliverableQty: 123456,
  rate: 123456.75,
);

const _order = OrderDetailsData(
  salesOrder: 'SO-12345678901234567890',
  originalTotal: 9876543210.25,
  items: [_item],
  deliveryStatus: 'PENDING',
);

const _flow = DeliveryFlowData(
  tripId: 7,
  orderId: 1,
  salesOrder: 'SO-12345678901234567890',
  customerName: 'متجر العميل باسم طويل لاختبار ملخص التأكيد قبل التسليم',
  items: [],
);

Future<void> _pumpCompactApp(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('ar'),
  double textScale = 2,
  Size size = const Size(320, 640),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: app!,
      ),
      home: Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final locale in [const Locale('ar'), const Locale('en')]) {
    testWidgets(
      'headers preserve back action and fit large ${locale.languageCode} text',
      (tester) async {
        var backs = 0;
        await _pumpCompactApp(
          tester,
          ListView(
            children: [
              OrderDetailsHeader(
                subtitle: _order.salesOrder,
                onBack: () => backs++,
              ),
              const DeliveryFlowHeader(
                title: 'مراجعة تسليم الطلب',
                subtitle: 'SO-1234567890 • متجر العميل صاحب الاسم الطويل',
              ),
              DeliveryOrderHeader(salesOrder: _order.salesOrder),
            ],
          ),
          locale: locale,
        );

        expect(tester.takeException(), isNull);
        final header = find.byType(OrderDetailsHeader);
        await tester.tap(
          find.descendant(of: header, matching: find.byType(InkWell)),
        );
        expect(backs, 1);
        expect(
          find.descendant(of: header, matching: find.byType(BackButtonIcon)),
          findsOneWidget,
        );
      },
    );
  }

  testWidgets('customer actions remain tappable with scaled RTL labels', (
    tester,
  ) async {
    final calls = <String>[];
    await _pumpCompactApp(
      tester,
      ListView(
        padding: const EdgeInsets.all(20),
        children: [
          OrderCustomerActions(
            onCall: () => calls.add('call'),
            onOpenLocation: () => calls.add('location'),
            onNavigate: () => calls.add('navigate'),
            onEdit: () => calls.add('edit'),
          ),
        ],
      ),
    );
    expect(tester.takeException(), isNull);
    for (final icon in [
      Icons.phone_outlined,
      Icons.location_on_outlined,
      Icons.navigation_outlined,
      Icons.sync_rounded,
    ]) {
      await tester.tap(find.byIcon(icon));
    }
    expect(calls, ['call', 'location', 'navigate', 'edit']);
  });

  testWidgets(
    'large money values and long quantity units remain fully present',
    (tester) async {
      await _pumpCompactApp(
        tester,
        ListView(
          children: const [
            OrderDetailsFinancialCard(order: _order),
            OrderDetailsItemsCard(items: [_item]),
            DeliveryFinancialResultCard(
              original: 9876543210.25,
              estimated: 1234567890.75,
            ),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text('123456 وحدة تعبئة كبيرة'),
        200,
      );
      await tester.pumpAndSettle();
      expect(find.text('123456 وحدة تعبئة كبيرة'), findsOneWidget);
      for (final text in tester.widgetList<Text>(find.byType(Text))) {
        expect(text.overflow, isNot(TextOverflow.ellipsis));
      }
    },
  );

  testWidgets(
    'compact delivery quantity controls preserve bounds and updates',
    (tester) async {
      final cubit = DeliveryDraftCubit()..initialize(_order);
      addTearDown(cubit.close);
      await _pumpCompactApp(
        tester,
        BlocProvider.value(
          value: cubit,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: const [DeliveryOrderItemCard(item: _item, index: 0)],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final decrement = find.byIcon(Icons.remove);
      await tester.ensureVisible(decrement);
      await tester.pumpAndSettle();
      await tester.tap(decrement);
      await tester.pumpAndSettle();
      expect((cubit.state as DeliveryDraftReady).qtyFor(0), 123455);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect((cubit.state as DeliveryDraftReady).qtyFor(0), 123456);
      expect(tester.takeException(), isNull);
    },
  );

  for (final kind in ['receiving', 'cancel', 'payment']) {
    testWidgets('$kind confirmation scrolls to its original approval action', (
      tester,
    ) async {
      bool? approved;
      late String approvalLabel;
      await _pumpCompactApp(
        tester,
        Builder(
          builder: (context) {
            final strings = AppLocalizations.of(context)!;
            approvalLabel = switch (kind) {
              'receiving' => strings.yes_confirm_receiving,
              'cancel' => strings.cancel_delivery_yes,
              _ => strings.delivery_confirm_button,
            };
            return TextButton(
              onPressed: () async {
                if (kind == 'receiving') {
                  approved = await showTripReceivingConfirmationSheet(
                    context: context,
                    tripNumber: _order.salesOrder,
                  );
                } else {
                  approved = await showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: kind == 'payment',
                    useSafeArea: true,
                    builder: (_) => kind == 'cancel'
                        ? CancelDeliveryConfirmationSheet(
                            salesOrder: _order.salesOrder,
                            reason: List.filled(
                              12,
                              'العميل طلب إلغاء الطلب',
                            ).join(' '),
                          )
                        : DeliveryPaymentConfirmationSheet(
                            flow: _flow,
                            strings: strings,
                            expectedAmountText: '9,876,543,210.25 جنيه',
                            enteredAmountText: '9,876,543,210.25 جنيه',
                          ),
                  );
                }
              },
              child: const Text('open'),
            );
          },
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final approval = find.widgetWithText(ElevatedButton, approvalLabel);
      await tester.ensureVisible(approval);
      await tester.pumpAndSettle();
      await tester.tap(approval);
      await tester.pumpAndSettle();
      expect(approved, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('map toolbar title stays between its existing controls', (
    tester,
  ) async {
    var backs = 0;
    var refreshes = 0;
    await _pumpCompactApp(
      tester,
      TripMapToolbar(
        tripId: 'TRIP-123456789012345678901234567890',
        onBack: () => backs++,
        onRefreshLocation: () => refreshes++,
        isRefreshing: false,
      ),
    );
    expect(tester.takeException(), isNull);
    final title = tester.getRect(find.byType(Text));
    for (final button in find.byType(IconButton).evaluate()) {
      final bounds = tester.getRect(find.byWidget(button.widget));
      expect(title.overlaps(bounds), isFalse);
    }
    await tester.tap(find.byIcon(Icons.my_location_rounded));
    await tester.tap(find.byType(BackButtonIcon));
    expect(refreshes, 1);
    expect(backs, 1);
  });

  testWidgets(
    'map stop estimates wrap and retain the supplied scroll controller',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      var navigations = 0;
      var orders = 0;
      await _pumpCompactApp(
        tester,
        TripMapStopSheet(
          scrollController: controller,
          stop: const TripMapStop(
            order: TripOrderModel(
              id: 'SO-1',
              stopNumber: 1,
              customerName: 'اسم المتجر',
              address: 'عنوان المتجر',
              phoneNumber: '',
              orderAmount: 150,
              status: TripOrderStatus.pending,
            ),
            location: LatLng(30, 31),
          ),
          totalStops: 100,
          isNextStop: true,
          locationAvailable: true,
          isLoadingRoute: false,
          routeError: false,
          route: const TripRouteResult(
            points: [],
            distanceMeters: 12345678,
            durationSeconds: 1234567,
          ),
          onNavigate: () => navigations++,
          onShowOrder: () => orders++,
          tripApiId: 7,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(controller.hasClients, isTrue);
      await tester.scrollUntilVisible(find.byType(ElevatedButton), 200);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.tap(find.byType(OutlinedButton));
      expect(navigations, 1);
      expect(orders, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('delivery summary accommodates scaled text on compact screens', (
    tester,
  ) async {
    final cubit = DeliveryDraftCubit()
      ..initialize(
        const OrderDetailsData(
          salesOrder: 'SO-1',
          originalTotal: 150.25,
          items: [
            OrderDetailsItem(
              itemCode: '1',
              itemName: 'منتج',
              uom: 'وحدة',
              orderedQty: 1,
              vehicleAvailableQty: 1,
              maxDeliverableQty: 1,
              rate: 150.25,
            ),
          ],
          deliveryStatus: 'PENDING',
        ),
      );
    addTearDown(cubit.close);
    await _pumpCompactApp(
      tester,
      BlocProvider.value(
        value: cubit,
        child: const Scaffold(
          bottomNavigationBar: DeliverySummaryBar(tripId: 7, orderId: 1),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final continueButton = find.byType(ElevatedButton);
    final bounds = tester.getRect(continueButton);
    expect(bounds.top, greaterThanOrEqualTo(0));
    expect(bounds.bottom, lessThanOrEqualTo(640));
    expect(tester.widget<ElevatedButton>(continueButton).onPressed, isNotNull);
  });

  testWidgets(
    'camera prompt expands for large text and preserves capture tap',
    (tester) async {
      var captures = 0;
      await _pumpCompactApp(
        tester,
        ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ReceivingPhotoPlaceholder(
              isBusy: false,
              onCapturePhoto: () => captures++,
            ),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.byIcon(Icons.photo_camera_outlined));
      expect(captures, 1);
    },
  );
}
