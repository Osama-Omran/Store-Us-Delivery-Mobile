import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/screens/areas_screen.dart';
import 'package:storeus_delivery/features/drawer_features/customers/presentation/screens/trip_customers_screen.dart';
import 'package:storeus_delivery/features/home/presentation/screens/home_screen.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_state.dart';
import 'package:storeus_delivery/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/screens/top_rank_screen.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/screens/treasury_screen.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/screens/stock_transfer_screen.dart';
import 'package:storeus_delivery/features/drawer_features/reports/presentation/screens/reports_screen.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/screen/trip_screen.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/presentation/screens/contact_us_screen.dart';

enum LayoutDrawerFeature {
  topRank,
  treasury,
  stockTransfer,
  reports,
  contactUs,
  customers,
  areas,
}

class LayoutCubit extends Cubit<LayoutState> {
  LayoutCubit() : super(LayoutInitial());

  static LayoutCubit get(BuildContext context) => BlocProvider.of(context);

  Widget currentScreen = const TripScreen();
  List<Widget> screens = [
    const HomeScreen(),
    const TripScreen(),

    const NotificationsScreen(),
  ];

  // Select Tap
  int selectedTap = 1;
  int _previousTap = 1;

  LayoutDrawerFeature? drawerFeature;

  bool get isDrawerFeatureOpen => drawerFeature != null;
  bool get isTopRank => drawerFeature == LayoutDrawerFeature.topRank;
  bool get isTreasury => drawerFeature == LayoutDrawerFeature.treasury;
  bool get isStockTransfer =>
      drawerFeature == LayoutDrawerFeature.stockTransfer;
  bool get isReports => drawerFeature == LayoutDrawerFeature.reports;
  bool get isCustomers => drawerFeature == LayoutDrawerFeature.customers;
  bool get isAreas => drawerFeature == LayoutDrawerFeature.areas;

  void selectTap(int index) {
    if (index < 0 || index >= screens.length) return;
    if (selectedTap == index) return;
    selectedTap = index;
    drawerFeature = null;
    currentScreen = screens[index];
    emit(LayoutInitial());
  }

  // ======= Drawer Features ======= //
  void openTopRank() {
    _openDrawerFeature(LayoutDrawerFeature.topRank);
  }

  void openTreasury() {
    _openDrawerFeature(LayoutDrawerFeature.treasury);
  }

  void openStockTransfer() {
    _openDrawerFeature(LayoutDrawerFeature.stockTransfer);
  }

  void openReports() {
    _openDrawerFeature(LayoutDrawerFeature.reports);
  }

  void openCustomerScreen() {
    _openDrawerFeature(LayoutDrawerFeature.customers);
  }

  void openAreas() {
    _openDrawerFeature(LayoutDrawerFeature.areas);
  }

  void closeTopRank() {
    if (!isTopRank) return;
    closeDrawerFeature();
  }

  void closeDrawerFeature() {
    if (!isDrawerFeatureOpen) return;
    selectTap(_previousTap);
  }

  bool get isContactUs => drawerFeature == LayoutDrawerFeature.contactUs;

  void openContactUs() {
    _openDrawerFeature(LayoutDrawerFeature.contactUs);
  }

  void _openDrawerFeature(LayoutDrawerFeature feature) {
    if (drawerFeature == feature) return;
    if (!isDrawerFeatureOpen) _previousTap = selectedTap;
    drawerFeature = feature;
    selectedTap = 3;
    currentScreen = switch (feature) {
      LayoutDrawerFeature.topRank => TopRankScreen(onBack: closeTopRank),
      LayoutDrawerFeature.treasury => const TreasuryScreen(),
      LayoutDrawerFeature.stockTransfer => StockTransferScreen(
        onBack: closeDrawerFeature,
      ),
      LayoutDrawerFeature.reports => const ReportsScreen(),
      LayoutDrawerFeature.contactUs => const ContactUsScreen(),
      LayoutDrawerFeature.customers => TripCustomersScreen(
        onBack: closeDrawerFeature,
      ),
      LayoutDrawerFeature.areas => AreasScreen(onBack: closeDrawerFeature),
    };
    emit(LayoutInitial());
  }
}
