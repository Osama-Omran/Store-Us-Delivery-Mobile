import 'package:storeus_delivery/features/drawer_features/customers/data/models/trip_customers_response.dart';

enum TripCustomersStatus { initial, loading, success, failure }

class TripCustomersState {
  const TripCustomersState({
    this.status = TripCustomersStatus.initial,
    this.tripId,
    this.tripNumber = '',
    this.customers = const [],
    this.errorMessage,
  });

  final TripCustomersStatus status;
  final int? tripId;
  final String tripNumber;
  final List<TripCustomer> customers;
  final String? errorMessage;
}
