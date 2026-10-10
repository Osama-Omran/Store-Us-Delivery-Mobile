
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';

sealed class OrderDetailsState {}

final class OrderDetailsInitial extends OrderDetailsState {}

final class OrderDetailsLoadingState extends OrderDetailsState {}

final class OrderDetailsSuccessState extends OrderDetailsState {
  final OrderDetailsData order;

  OrderDetailsSuccessState(this.order);
}

final class OrderDetailsFailureState extends OrderDetailsState {
  final String? errorMessage;

  OrderDetailsFailureState(this.errorMessage);
}
