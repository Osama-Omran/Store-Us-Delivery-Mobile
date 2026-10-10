import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/features/home/presentation/screens/home_screen.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_state.dart';
import 'package:storeus_delivery/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/screens/top_rank_screen.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/screens/treasury_screen.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/screen/trip_screen.dart';

enum LayoutDrawerFeature { topRank, treasury }

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

  void closeTopRank() {
    if (!isTopRank) return;
    closeDrawerFeature();
  }

  void closeDrawerFeature() {
    if (!isDrawerFeatureOpen) return;
    selectTap(_previousTap);
  }

  void _openDrawerFeature(LayoutDrawerFeature feature) {
    if (drawerFeature == feature) return;
    if (!isDrawerFeatureOpen) _previousTap = selectedTap;
    drawerFeature = feature;
    selectedTap = 3;
    currentScreen = switch (feature) {
      LayoutDrawerFeature.topRank => TopRankScreen(onBack: closeTopRank),
      LayoutDrawerFeature.treasury => const TreasuryScreen(),
    };
    emit(LayoutInitial());
  }
}
