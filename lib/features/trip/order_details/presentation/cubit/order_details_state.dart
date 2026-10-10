
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';

sealed class OrderDetailsState {}

final class OrderDetailsInitial extends OrderDetailsState {}

final class OrderDetailsLoadingState extends OrderDetailsState {}

final class OrderDetailsFailureState extends OrderDetailsState {
  final String? errorMessage;

  OrderDetailsFailureState(this.errorMessage);
}

final class OrderDetailsSuccessState extends OrderDetailsState {
  final OrderDetailsData order;
  final TripOrderData? tripOrder;

  final bool isSavingLocation;
  final bool locationUpdated;

  OrderDetailsSuccessState(
      this.order, {
        this.tripOrder,
        this.isSavingLocation = false,
        this.locationUpdated = false,
      });

  OrderDetailsSuccessState copyWith({
    bool? isSavingLocation,
    bool? locationUpdated,
  }) {
    return OrderDetailsSuccessState(
      order,
      tripOrder: tripOrder,
      isSavingLocation:
      isSavingLocation ?? this.isSavingLocation,
      locationUpdated:
      locationUpdated ?? this.locationUpdated,
    );
  }
}

class UpdateOrderDeliveryLocationLoadingState extends OrderDetailsState {}

class UpdateOrderDeliveryLocationSuccessState extends OrderDetailsState {
  final dynamic response;

  UpdateOrderDeliveryLocationSuccessState(this.response);
}

class UpdateOrderDeliveryLocationFailureState extends OrderDetailsState {
  final String error;

  UpdateOrderDeliveryLocationFailureState(this.error);
}
