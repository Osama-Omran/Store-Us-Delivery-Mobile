import 'package:flutter/material.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/widgets/empty_trips.dart';

class TripScreen extends StatelessWidget {
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: EmptyTrips());
  }
}
