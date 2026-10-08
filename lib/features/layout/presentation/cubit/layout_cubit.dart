import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/features/home/presentation/screens/home_screen.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_state.dart';
import 'package:storeus_delivery/features/notifications/data/models/app_notification_model.dart';
import 'package:storeus_delivery/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/screen/trip_screen.dart';

class LayoutCubit extends Cubit<LayoutState> {
  LayoutCubit() : super(LayoutInitial());

  static LayoutCubit get(BuildContext context) => BlocProvider.of(context);

  Widget currentScreen = const TripScreen();
  List<Widget> screens = [
    HomeScreen(
      userName: 'أحمد محمد',
      unreadNotifications: 2,
      currentTrip: HomeCurrentTrip(
        id: 'TRIP-0025',
        vehicleName: 'سوزوكي فان - أ ب ج 1234',
        driverName: 'محمد أحمد',
        warehouseName: 'مخزن الجيزة الرئيسي',
        startedAt: DateTime(2026, 10, 8, 9, 15),
        totalOrders: 12,
        deliveredOrders: 7,
        remainingOrders: 5,
        collectedAmount: 8450,
      ),
      previousTrip: HomePreviousTrip(
        id: 'TRIP-0024',
        totalOrders: 10,
        completedAt: DateTime(2026, 10, 8, 16, 30),
        isSettled: true,
      ),
      onNotificationsTap: () {
        // TODO: Navigate to notifications
      },
      onContinueTrip: () {
        // TODO: Navigate to active trip orders
      },
      onPreviousTripTap: () {
        // TODO: Open previous trip details
      },
    ),
    const TripScreen(),

    NotificationsScreen(
      onNotificationTap: (notification) {
        switch (notification.type) {
          case AppNotificationType.tripAssigned:
          case AppNotificationType.tripReordered:
          // Navigate to trip details
            break;

          case AppNotificationType.orderUpdated:
          // Navigate to order details
            break;

          case AppNotificationType.paymentReceived:
          // Navigate to wallet / settlement
            break;

          case AppNotificationType.tripCompleted:
          // Navigate to completed trip details
            break;
        }
      },
    ),
    const Scaffold(backgroundColor: Colors.pink),
  ];

  // Select Tap
  int selectedTap = 1;
  void selectTap(int index) {
    if (selectedTap == index) return;
    selectedTap = index;
    currentScreen = screens[index];
    emit(LayoutInitial());
  }
}
