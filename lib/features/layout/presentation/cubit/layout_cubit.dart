import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_state.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/screen/trip_screen.dart';

class LayoutCubit extends Cubit<LayoutState> {
  LayoutCubit() : super(LayoutInitial());

  static LayoutCubit get(BuildContext context) => BlocProvider.of(context);

  Widget currentScreen = const TripScreen();
  List<Widget> screens = const [
    Scaffold(backgroundColor: Colors.red),
    TripScreen(),
    Scaffold(backgroundColor: Colors.blue),
    Scaffold(backgroundColor: Colors.pink),
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
