import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_error_model.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:storeus_delivery/core/helpers/offline_sync/offline_sync_interceptor.dart';
import 'package:storeus_delivery/core/helpers/offline_sync/offline_sync_notifications.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/data/models/stock_transfer_model.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/widgets/stock_transfer_status_badge.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_metrics.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/widgets/trip_order_card.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_collection_status_card.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_delivery_status_card.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/cubit/receive_trip_state.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/loaded_items_section.dart';

Future<void> pumpLocalized(WidgetTester tester, WidgetBuilder builder) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: SingleChildScrollView(child: Builder(builder: builder)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Arabic catalog has unique keys and valid placeholder metadata', () {
    final source = File('lib/core/helpers/localization/intl_ar.arb')
        .readAsStringSync();
    final catalog = jsonDecode(source) as Map<String, dynamic>;
    final keys = RegExp(
      r'^ {0,2}"([^"\n]+)"\s*:',
      multiLine: true,
    ).allMatches(source).map((match) => match[1]).toList();
    expect(keys.toSet().length, keys.length);
    for (final entry in catalog.entries.where(
      (entry) => entry.key.startsWith('@'),
    )) {
      final message = catalog[entry.key.substring(1)] as String;
      final metadata = entry.value as Map<String, dynamic>;
      final placeholders =
          metadata['placeholders'] as Map<String, dynamic>? ?? {};
      for (final placeholder in placeholders.entries) {
        expect(message, contains('{${placeholder.key}'));
        expect(
          (placeholder.value as Map)['type'],
          isIn(['String', 'int', 'num', 'double', 'DateTime']),
        );
      }
    }
    expect(AppLocalizations.supportedLocales, [const Locale('ar')]);
  });

  test(
    'Arabic ICU messages cover zero, singular, dual, few, many and other',
    () async {
      final strings = await AppLocalizations.delegate.load(const Locale('ar'));
      final orders = <int, String>{
        0: 'لا توجد طلبات',
        1: 'طلب واحد',
        2: 'طلبان',
        3: '3 طلبات',
        11: '11 طلبًا',
        102: '102 طلب',
      };
      for (final entry in orders.entries) {
        expect(strings.orders_count(entry.key), entry.value);
      }
      expect(strings.notification_minutes_ago_count(2), 'منذ دقيقتين');
      expect(strings.notification_hours_ago_count(3), 'منذ 3 ساعات');
      expect(strings.trip_customers_count(2), 'عميلان في الرحلة');
      expect(strings.notifications_unread_count(1), 'إشعار واحد غير مقروء');
      expect(strings.trip_map_arrival_minutes(11), 'الوصول خلال 11 دقيقة');
      expect(
        strings.trip_handled_orders_summary(2, 3),
        '2 من 3 طلبات تم التعامل معها',
      );
      expect(strings.order_number_label('SO-123'), 'الطلب: SO-123');
      expect(strings.amount_egp('١٢٫٥'), '١٢٫٥ ج.م');
    },
  );

  test('background notifications load the generated Arabic catalog without context', () async {
    for (final saved in ['ar', 'fr', null]) {
      SharedPreferences.setMockInitialValues(
        saved == null ? {} : {'locale': saved},
      );
      final strings = await OfflineSyncNotifications.loadStrings();
      expect(strings.localeName, 'ar');
      expect(
        strings.offline_notifications_sending_body('طلب SO-1'),
        'جاري إرسال: طلب SO-1',
      );
      expect(
        strings.offline_notifications_error_body('طلب SO-1'),
        'تعذر إكمال طلب SO-1. راجع التطبيق.',
      );
      expect(strings.offline_notifications_waiting, 'عمليات محفوظة');
    }
  });

  test(
    'API failures retain structured errors without requiring a navigator',
    () {
      final options = RequestOptions(path: '/test');
      final queued = ErrorHandler.handle(
        DioException(
          requestOptions: options,
          error: const OfflineQueuedException('operation-1'),
        ),
      );
      expect(queued.apiErrorModel.message, 'offline_operation_queued');
      expect(queued.apiErrorModel.getAllErrors(), ['offline_operation_queued']);
      final server = ErrorHandler.handle(
        DioException(
          requestOptions: options,
          response: Response(requestOptions: options, statusCode: 503),
        ),
      );
      expect(server.apiErrorModel.message, 'api_server_error');
      expect(server.apiErrorModel.errorCode, 503);
      expect(ApiErrorModel.fromJson({}).message, 'api_unknown_error');
    },
  );

  testWidgets(
    'presentation localizes internal errors and preserves backend prose',
    (tester) async {
      await pumpLocalized(tester, (context) {
        for (final code in [
          'order_collection_in_progress',
          'order_collection_invalid_details',
          'order_collection_connection_uncertain',
          'offline_operation_queued',
          'top_rank_category_empty',
          'reports_load_failed',
          'api_unknown_error',
          'api_server_error',
          'api_no_internet',
          'badRequestError',
          'unauthorizedError',
          'trip_customers_load_failed',
          'direct_sale_customer_verify_before_retry',
        ]) {
          expect(context.localizedErrorMessage(code), isNot(code));
        }
        expect(
          context.localizedErrorMessage(null),
          context.strings.an_error_occurred_try_again_later,
        );
        expect(
          context.localizedErrorMessage(
            '',
            fallback: context.strings.order_collection_not_ready,
          ),
          context.strings.order_collection_not_ready,
        );
        const backend = '  Please contact warehouse 17  ';
        expect(context.localizedErrorMessage(backend), backend);
        expect(
          context.localizedTripAcceptanceStatus(' pending '),
          context.strings.trip_acceptance_pending,
        );
        expect(
          context.localizedTripAcceptanceStatus('NEW_CODE'),
          context.strings.trip_tab_unknown_status,
        );
        expect(
          context.localizedUserRole('Delivery Representative'),
          context.strings.account_delivery_representative,
        );
        expect(
          context.localizedUserRole('NEW_ROLE'),
          context.strings.account_role_unknown,
        );
        return const SizedBox.shrink();
      });
    },
  );

  testWidgets('collection cards localize known aliases and unknown statuses', (
    tester,
  ) async {
    final strings = await AppLocalizations.delegate.load(const Locale('ar'));
    final labels = <String, String>{
      'NOT_STARTED': strings.order_collection_not_started,
      ' PAID ': strings.order_collection_completed,
      'FULLY_COLLECTED': strings.order_collection_completed,
      'PARTIALLY_PAID': strings.order_collection_incomplete,
      'PARTIAL_PAYMENT': strings.order_collection_incomplete,
      'UNPAID': strings.delivery_not_collected,
      'NOT_COLLECTED': strings.delivery_not_collected,
      'PAYMENT_FAILED': strings.order_collection_failed,
      'NEW_BACKEND_STATUS': strings.order_collection_status_unknown,
      '': strings.order_collection_status_unknown,
    };
    for (final entry in labels.entries) {
      await pumpLocalized(
        tester,
        (_) => OrderCollectionStatusCard(
          order: TripOrderData(
            id: 1,
            salesOrder: 'SO-1',
            stopOrder: 1,
            deliveryStatus: 'DELIVERED',
            paymentStatus: entry.key,
          ),
        ),
      );
      expect(find.text(entry.value), findsOneWidget);
      if (entry.key.isNotEmpty) expect(find.text(entry.key), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('order cards never expose unknown delivery or payment codes', (
    tester,
  ) async {
    await pumpLocalized(
      tester,
      (_) => const TripOrderCard(
        tripID: 1,
        order: TripOrderModel(
          id: 'SO-1',
          stopNumber: 1,
          customerName: 'عميل تجريبي',
          address: '',
          phoneNumber: '',
          orderAmount: 25,
          status: TripOrderStatus.unknown,
          rawDeliveryStatus: 'FUTURE_DELIVERY',
          paymentStatus: 'FUTURE_PAYMENT',
        ),
      ),
    );
    expect(find.text('FUTURE_DELIVERY'), findsNothing);
    expect(find.text('FUTURE_PAYMENT'), findsNothing);
    expect(find.text('عميل تجريبي'), findsOneWidget);
    final strings = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.text(strings.trip_customers_unknown_status), findsOneWidget);
    expect(find.text(strings.order_collection_status_unknown), findsOneWidget);
  });

  testWidgets('order details use localized unknown delivery fallback', (
    tester,
  ) async {
    await pumpLocalized(
      tester,
      (_) => const OrderDeliveryStatusCard(
        order: OrderDetailsData(
          salesOrder: 'SO-1',
          items: [],
          deliveryStatus: 'FUTURE_DELIVERY',
        ),
      ),
    );
    expect(find.text('FUTURE_DELIVERY'), findsNothing);
    final strings = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.text(strings.trip_customers_unknown_status), findsOneWidget);
  });

  testWidgets(
    'stock transfers localize unknown statuses instead of API labels',
    (tester) async {
      await pumpLocalized(
        tester,
        (_) => const StockTransferStatusBadge(
          transfer: StockTransferModel(
            number: 'TRANSFER-1',
            sourceWarehouse: 'A',
            destinationWarehouse: 'B',
            vehicle: 'V',
            representative: 'R',
            itemCount: 0,
            totalQuantity: 0,
            createdAt: null,
            status: StockTransferStatus.other,
            statusCode: 'FUTURE_STATUS',
            statusLabel: 'FUTURE_STATUS',
          ),
        ),
      );
      expect(find.text('FUTURE_STATUS'), findsNothing);
      final strings = await AppLocalizations.delegate.load(const Locale('ar'));
      expect(find.text(strings.trip_tab_unknown_status), findsOneWidget);
    },
  );

  testWidgets(
    'ranking metrics preserve backend labels and hide fallback keys',
    (tester) async {
      await pumpLocalized(tester, (context) {
        expect(
          rankMetricLabel(
            context,
            TopRankMetric.fromJson('technical_score', {}),
          ),
          context.strings.top_rank_metric_unknown,
        );
        expect(
          rankMetricLabel(
            context,
            TopRankMetric.fromJson('technical_score', {'label': 'دقة التسليم'}),
          ),
          'دقة التسليم',
        );
        return const SizedBox.shrink();
      });
    },
  );

  testWidgets('loaded goods failures resolve internal network error codes', (
    tester,
  ) async {
    await pumpLocalized(
      tester,
      (_) => LoadedItemsSection(
        state: ReceiveTripSuccessState(
          const CurrentTripData(id: 1, number: 'TRIP-1', status: 'SHIPPED'),
          loadedItemsStatus: LoadedItemsStatus.failure,
          loadedItemsError: 'api_no_internet',
        ),
      ),
    );
    final strings = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.text(strings.no_internet_please_try_again), findsOneWidget);
    expect(find.text('api_no_internet'), findsNothing);
  });
}
