
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';

enum TripOrdersStatus {
  initial,
  loading,
  success,
  failure,
}

sealed class TripTabState {}

final class TripTabInitial extends TripTabState {}

final class TripTabLoadingState extends TripTabState {}

final class TripTabSuccessState extends TripTabState {
  final CurrentTripData trip;

  final TripOrdersStatus ordersStatus;
  final List<TripOrderModel> orders;
  final String? ordersError;

  TripTabSuccessState(
      this.trip, {
        this.ordersStatus = TripOrdersStatus.initial,
        this.orders = const [],
        this.ordersError,
      });
}

final class TripTabEmptyState extends TripTabState {}

final class TripTabFailureState extends TripTabState {
  final String? errorMessage;

  TripTabFailureState(this.errorMessage);
}
