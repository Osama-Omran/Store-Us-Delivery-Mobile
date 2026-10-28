import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:storeus_delivery/core/theme/app_theme.dart';
import 'package:storeus_delivery/core/widgets/custom_app_bar.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/models/areas_route_data.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/widgets/areas_route_overview.dart';
import 'package:storeus_delivery/features/drawer_features/reports/data/models/reports_models.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/widgets/reports_financial_card.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/data/models/stock_transfer_model.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/widgets/stock_transfer_card.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/data/models/treasury_models.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/data/models/treasury_wallet_response.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/cubit/treasury_state.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/widgets/treasury_wallet_live.dart';
import 'package:storeus_delivery/features/home/data/models/trip_history_response.dart';
import 'package:storeus_delivery/features/home/domain/repo/trip_history_repo_interface.dart';
import 'package:storeus_delivery/features/home/domain/usecases/get_trip_history_usecase.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_history_cubit.dart';
import 'package:storeus_delivery/features/home/presentation/widgets/home_previous_trips_section.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_customer_actions.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/loaded_items_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/loaded_goods_details.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/receiving_photo_actions.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/van_products.dart';

const _longName = 'اسم العميل والمستودع الرئيسي للتوزيع في المنطقة الشرقية';

void main() {
  setUpAll(() async {
    final cairo = FontLoader('cairo')
      ..addFont(
        rootBundle.load('assets/fonts/cairo/Cairo-VariableFont_slnt,wght.ttf'),
      );
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await Future.wait([cairo.load(), icons.load()]);
  });

  for (final width in [320.0, 390.0, 600.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'RTL cards retain content without overflow at $width px / $scale text',
        (tester) async {
          _setView(tester, width);
          final history = HomeHistoryCubit(
            GetTripHistoryUsecase(_HistoryRepo()),
          );
          addTearDown(history.close);
          await history.getTripHistory();
          await tester.pumpWidget(
            BlocProvider.value(
              value: history,
              child: _app(
                scale,
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 20,
                      children: [
                        const HomePreviousTripsSection(),
                        StockTransferCard(
                          referenceDate: DateTime(2026, 10, 28),
                          transfer: StockTransferModel(
                            number: 'TRANSFER-2026-12345678901234567890',
                            sourceWarehouse: _longName,
                            destinationWarehouse:
                                'المستودع المركزي في القاهرة الجديدة',
                            vehicle: 'DELIVERY-VEHICLE-1234567890',
                            representative: _longName,
                            itemCount: 123456789,
                            totalQuantity: 987654321,
                            createdAt: DateTime(2026, 10, 28),
                            expectedArrival: DateTime(2026, 10, 29),
                            status: StockTransferStatus.awaitingReceipt,
                          ),
                        ),
                        const ReportsFinancialCard(
                          summary: ReportsSummary(
                            totalOrders: 99999,
                            deliveredOrders: 12345,
                            partialOrders: 123,
                            deliveryPercentage: 50,
                            collectedAmount: 1234567890.25,
                            invoicedAmount: 9876543210.75,
                            outstandingAmount: 1234567890.25,
                            receivedByWarehouse: 987654321.75,
                            custodyBalance: 123456789.25,
                          ),
                        ),
                        _wallet(),
                        const ProductWidget(
                          product: LoadedTripItem(
                            itemCode: 'PRODUCT-12345678901234567890',
                            itemName: _longName,
                            uom: 'كرتونة',
                            loadedQty: 1234567890123,
                            source: 'sales_orders',
                          ),
                        ),
                        const LoadedGoodsDetails(
                          totals: LoadedItemsTotals(
                            items: 987654321,
                            qty: 1234567890123,
                          ),
                        ),
                        ReceivingPhotoActions(
                          isApproved: false,
                          isCapturing: false,
                          onCapturePhoto: () {},
                          onApprovePhoto: () {},
                        ),
                        OrderCustomerFullAction(
                          title: _longName,
                          icon: Icons.phone_outlined,
                          background: Colors.white,
                          foreground: Colors.blue,
                          onTap: () {},
                        ),
                        AreasRouteOverview(
                          route: AreasRouteData(
                            trip: const CurrentTripData(
                              id: 7,
                              status: 'IN_PROGRESS',
                              number: 'TRIP-2026-12345678901234567890',
                            ),
                            orders: const [
                              TripOrderModel(
                                id: 'SO-42',
                                stopNumber: 1,
                                customerName: _longName,
                                address: _longName,
                                phoneNumber: '',
                                orderAmount: 0,
                                status: TripOrderStatus.pending,
                              ),
                            ],
                          ),
                          onMap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.byType(StockTransferCard), findsOneWidget);
          expect(find.text('1234567890123'), findsNWidgets(2));
          expect(
            Directionality.of(
              tester.element(find.byType(ReportsFinancialCard)),
            ),
            TextDirection.rtl,
          );
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }

  testWidgets(
    'wrapped photo and customer actions keep their original callbacks and disabled states',
    (tester) async {
      _setView(tester, 320);
      var capture = 0;
      var approve = 0;
      var customer = 0;
      await tester.pumpWidget(
        _app(
          2,
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReceivingPhotoActions(
                    isApproved: false,
                    isCapturing: false,
                    onCapturePhoto: () => capture++,
                    onApprovePhoto: () => approve++,
                  ),
                  OrderCustomerFullAction(
                    title: _longName,
                    icon: Icons.phone_outlined,
                    background: Colors.white,
                    foreground: Colors.blue,
                    onTap: () => customer++,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OutlinedButton));
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.tap(find.byType(ElevatedButton).last);
      expect([capture, approve, customer], [1, 1, 1]);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        _app(
          2,
          ReceivingPhotoActions(
            isApproved: false,
            isCapturing: true,
            onCapturePhoto: () => capture++,
            onApprovePhoto: () => approve++,
          ),
        ),
      );
      expect(
        tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
        isNull,
      );
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull,
      );
    },
  );

  testWidgets('shared app bar keeps long RTL title inside the safe toolbar', (
    tester,
  ) async {
    _setView(tester, 320);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 900),
            padding: EdgeInsets.only(top: 24),
            textScaler: TextScaler.linear(2),
          ),
          child: const Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(appBar: CustomAppBar(title: _longName)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text(_longName)).dy,
      greaterThanOrEqualTo(24),
    );
    expect(tester.takeException(), isNull);
  });

  for (final scenario in [(390.0, 1.0), (320.0, 2.0)]) {
    testWidgets(
      'financial visual review ${scenario.$1} px / ${scenario.$2} text',
      (tester) async {
        _setView(tester, scenario.$1);
        final boundary = GlobalKey();
        await tester.pumpWidget(
          _app(
            scenario.$2,
            SingleChildScrollView(
              child: RepaintBoundary(
                key: boundary,
                child: ColoredBox(
                  color: AppTheme.lightTheme.scaffoldBackgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _wallet(),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final render =
              boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final screenshot = await render.toImage();
          final bytes = await screenshot.toByteData(
            format: ui.ImageByteFormat.png,
          );
          final directory = Directory('build/ui_polish_review')
            ..createSync(recursive: true);
          File(
            '${directory.path}/wallet-${scenario.$1.toInt()}-${scenario.$2.toInt()}x.png',
          ).writeAsBytesSync(bytes!.buffer.asUint8List());
          screenshot.dispose();
        });
      },
    );
  }
}

Widget _wallet() => TreasuryWalletLive(
  state: TreasuryState(
    data: TreasuryData(
      tripNumber: 'TRIP-7',
      vehicleName: _longName,
      collections: [],
      inventory: [],
    ),
    wallet: const TripWalletData(
      trip: 'TRIP-2026-12345678901234567890',
      custodyBalance: 1234567890.25,
      balanceSource: 'server',
      settlementStatus: 'PENDING',
      totalCollected: 9876543210.75,
      totalReceivedByWarehouse: 1234567890.25,
      transactions: [],
      cashReceipts: [],
    ),
  ),
  onRefresh: () async {},
);

Widget _app(double scale, Widget child) => MaterialApp(
  theme: AppTheme.lightTheme,
  locale: const Locale('ar'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, page) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: page!,
  ),
  home: Scaffold(body: SafeArea(child: child)),
);

void _setView(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _HistoryRepo implements TripHistoryRepoInterface {
  @override
  Future<ApiResult<TripHistoryResponse>> getTripHistory() async =>
      ApiResult.success(
        TripHistoryResponse(
          success: true,
          data: [
            TripHistoryItem(
              id: 1,
              number: 'TRIP-2026-12345678901234567890',
              status: 'COMPLETED',
              tripDate: DateTime.now(),
              completedAt: DateTime.now(),
              totalOrders: 987654321,
            ),
          ],
        ),
      );
}
