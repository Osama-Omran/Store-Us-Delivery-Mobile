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
    const HomeScreen(),
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
