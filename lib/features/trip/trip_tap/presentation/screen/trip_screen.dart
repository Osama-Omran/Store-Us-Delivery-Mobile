import 'package:flutter/material.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/sample/sample_current_trip.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/screens/current_trip_screen.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/widgets/empty_trips.dart';

class TripScreen extends StatelessWidget {
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 6 == 6
          ? EmptyTrips()
          : CurrentTripScreen(
              trip: sampleCurrentTrip,
              orders: sampleTripOrders,
              onOpenMap: () {},
              onOpenOrder: (order) {},
              onShowDeliveryDetails: (order) {
                // TODO: Open delivery details
              },
              onCallCustomer: (order) {
                // TODO: Call order.phoneNumber
              },
              onOpenDirections: (order) {
                // TODO: Navigate to order.address
              },
            ),
    );
  }
}
