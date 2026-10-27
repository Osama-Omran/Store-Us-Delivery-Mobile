import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/drawer_features/account/data/models/me_response.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/widgets/account_personal_info_card.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/presentation/widgets/contact_action_button.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/presentation/widgets/contact_support_info_card.dart';
import 'package:storeus_delivery/features/drawer_features/customers/data/models/trip_customers_response.dart';
import 'package:storeus_delivery/features/drawer_features/customers/presentation/widgets/trip_customer_actions.dart';
import 'package:storeus_delivery/features/drawer_features/customers/presentation/widgets/trip_customer_card.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/data/models/direct_sale_models.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/domain/usecases/create_customer_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/presentation/cubit/direct_sale_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/presentation/cubit/direct_sale_state.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/presentation/widgets/direct_sale_checkout_summary.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/presentation/widgets/direct_sale_product_card.dart';
import 'package:storeus_delivery/features/drawer_features/reports/data/models/reports_models.dart';
import 'package:storeus_delivery/features/drawer_features/reports/domain/usecases/get_reports_overview_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/cubit/reports_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/cubit/reports_state.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_filters.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_list.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/widgets/top_rank_winner_card.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';

class _UnusedCreateCustomer extends Fake implements CreateCustomerUsecase {}

class _UnusedReports extends Fake implements GetReportsOverviewUsecase {}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double width = 320,
  double scale = 2,
}) async {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(fontFamily: 'cairo'),
      builder: (context, widget) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: widget!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    ),
  );
  await tester.pump();
}

const _product = DirectSaleProduct(
  code: 'PRODUCT-001',
  name: 'منتج باسم عربي طويل للتحقق من وضوح التفاصيل',
  unit: 'عبوة',
  availableQuantity: 3,
  unitPriceMinor: 1234567890,
);

void main() {
  testWidgets('support action wraps enlarged text and keeps its callback', (
    tester,
  ) async {
    var calls = 0;
    const title = 'التواصل مع خدمة دعم العملاء للمساعدة';
    await _pump(
      tester,
      ContactActionButton(
        title: title,
        icon: Icons.call_outlined,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white0,
        onPressed: () => calls++,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(ElevatedButton)).height, greaterThan(56));
    await tester.tap(find.text(title));
    expect(calls, 1);
  });

  testWidgets('support info keeps full phone text in LTR at enlarged text', (
    tester,
  ) async {
    const phone = '+20 100 123 4567';
    await _pump(
      tester,
      const ContactSupportInfoCard(
        phone: phone,
        workingHours: 'من التاسعة صباحًا حتى التاسعة مساءً',
      ),
    );
    expect(tester.takeException(), isNull);
    final phoneText = tester.widget<Text>(find.text(phone));
    expect(phoneText.textDirection, TextDirection.ltr);
    expect(phoneText.overflow, isNot(TextOverflow.ellipsis));
  });

  testWidgets('custom report dates stack and preserve the full date format', (
    tester,
  ) async {
    final cubit = ReportsCubit(_UnusedReports());
    addTearDown(cubit.close);
    await _pump(
      tester,
      BlocProvider.value(
        value: cubit,
        child: ReportsFilters(
          state: ReportsState(
            fromDate: DateTime(2026, 10, 1),
            toDate: DateTime(2026, 10, 27),
            period: ReportsPeriod.custom,
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('01/10/2026'), findsOneWidget);
    expect(find.text('27/10/2026'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('reports-to-date'))).dy,
      greaterThan(
        tester
            .getBottomLeft(find.byKey(const ValueKey('reports-from-date')))
            .dy,
      ),
    );
  });

  for (final layout in [(320.0, 2.0), (412.0, 1.0)]) {
    testWidgets('quantity controls preserve limits at $layout', (tester) async {
      final cubit = DirectSaleCubit(
        createCustomerUsecase: _UnusedCreateCustomer(),
        initialState: const DirectSaleState(
          products: [_product],
          inventoryAvailable: true,
        ),
      );
      addTearDown(cubit.close);
      await _pump(
        tester,
        BlocProvider.value(
          value: cubit,
          child: const DirectSaleProductCard(product: _product),
        ),
        width: layout.$1,
        scale: layout.$2,
      );
      expect(tester.takeException(), isNull);
      final decrease = find.widgetWithIcon(IconButton, Icons.remove);
      final increase = find.widgetWithIcon(IconButton, Icons.add);
      expect(tester.widget<IconButton>(decrease).onPressed, isNull);
      for (var i = 0; i < 3; i++) {
        await tester.tap(increase);
        await tester.pump();
      }
      expect(cubit.state.quantityFor(_product), 3);
      expect(tester.widget<IconButton>(increase).onPressed, isNull);
      await tester.tap(decrease);
      await tester.pump();
      expect(cubit.state.quantityFor(_product), 2);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('checkout displays full large monetary values at enlarged text', (
    tester,
  ) async {
    final cubit = DirectSaleCubit(
      createCustomerUsecase: _UnusedCreateCustomer(),
      initialState: const DirectSaleState(
        products: [_product],
        inventoryAvailable: true,
        quantities: {'PRODUCT-001': 3},
      ),
    );
    addTearDown(cubit.close);
    await _pump(
      tester,
      BlocProvider.value(
        value: cubit,
        child: const DirectSaleCheckoutSummary(),
      ),
    );
    final context = tester.element(find.byType(DirectSaleCheckoutSummary));
    final fullAmount = formatTripAmount(context, cubit.state.totalMinor / 100);
    expect(find.text(fullAmount), findsNWidgets(2));
    for (final text in tester.widgetList<Text>(find.text(fullAmount))) {
      expect(text.overflow, isNot(TextOverflow.ellipsis));
      expect(text.maxLines, isNull);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('customer actions wrap while preserving disabled actions', (
    tester,
  ) async {
    var openedOrders = 0;
    await _pump(
      tester,
      TripCustomerCard(
        customer: const TripCustomer(
          name: 'عميل باسم طويل لاختبار عرض بيانات العميل',
          phone: '',
          address: 'عنوان عربي طويل في مدينة القاهرة',
          ordersCount: 2,
          deliveryStatus: 'RESCHEDULED',
        ),
        onOrders: () => openedOrders++,
      ),
    );
    expect(tester.takeException(), isNull);
    final context = tester.element(find.byType(TripCustomerCard));
    final strings = AppLocalizations.of(context)!;
    final call = find.text(strings.trip_customers_call);
    final location = find.text(strings.trip_customers_location);
    expect(
      tester.getTopLeft(location).dy,
      greaterThan(tester.getTopLeft(call).dy),
    );
    final actions = tester
        .widgetList<InkWell>(
          find.descendant(
            of: find.byType(TripCustomerActions),
            matching: find.byType(InkWell),
          ),
        )
        .toList();
    expect(actions.length, 4);
    expect(actions.take(3).every((action) => action.onTap == null), isTrue);
    await tester.ensureVisible(find.text(strings.trip_customers_orders_button));
    await tester.tap(find.text(strings.trip_customers_orders_button));
    expect(openedOrders, 1);
  });

  testWidgets('rank winner and list accommodate provisional and no movement', (
    tester,
  ) async {
    var openedDetails = 0;
    const entry = TopRankEntry(
      id: 'rank-1',
      name: 'مندوب مبيعات باسم عربي طويل للاختبار',
      rank: 17,
      score: 98.5,
      movement: 0,
      provisional: true,
      breakdown: {
        'collection': TopRankMetric(
          key: 'collection',
          label: 'إجمالي المبالغ التي تم تحصيلها خلال الفترة',
          unit: 'جنيه مصري',
          value: 123456789,
        ),
      },
    );
    await _pump(
      tester,
      Column(
        children: [
          TopRankWinnerCard(
            entry: entry,
            role: TopRankRole.representatives,
            winnerLabel: 'أفضل مندوب مبيعات خلال الفترة',
            onDetails: () => openedDetails++,
          ),
          const SizedBox(height: 16),
          TopRankList(
            entries: const [entry],
            role: TopRankRole.representatives,
            onDetails: (_) => openedDetails++,
          ),
        ],
      ),
    );
    expect(tester.takeException(), isNull);
    final list = find.byType(TopRankList);
    await tester.ensureVisible(list);
    await tester.tap(find.descendant(of: list, matching: find.byType(InkWell)));
    expect(openedDetails, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('account info wraps full email and retains LTR values', (
    tester,
  ) async {
    const email = 'delivery.representative.long.email@example.com';
    await _pump(
      tester,
      const AccountPersonalInfoCard(
        user: AccountUser(
          id: 1,
          name: 'مندوب باسم عربي طويل للاختبار',
          employeeId: 'EMP-123456789',
          phone: '+20 100 123 4567',
          email: email,
          role: 'representative',
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final text = tester.widget<Text>(find.text(email));
    expect(text.textDirection, TextDirection.ltr);
    expect(text.maxLines, isNull);
    expect(text.overflow, isNot(TextOverflow.ellipsis));
  });
}
