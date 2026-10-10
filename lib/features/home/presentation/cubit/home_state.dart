
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';

enum HomeOrdersStatus {
  initial,
  loading,
  success,
  failure,
}

sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoadingState extends HomeState {}

final class HomeEmptyState extends HomeState {}

final class HomeFailureState extends HomeState {
  final String? errorMessage;

  HomeFailureState(this.errorMessage);
}

final class HomeSuccessState extends HomeState {
  final CurrentTripData trip;
  final HomeOrdersStatus ordersStatus;
  final List<TripOrderData> orders;
  final String? ordersError;

  HomeSuccessState(
      this.trip, {
        this.ordersStatus = HomeOrdersStatus.initial,
        this.orders = const [],
        this.ordersError,
      });

  int? get deliveredOrders {
    if (ordersStatus != HomeOrdersStatus.success) {
      return null;
    }

    const deliveredStatuses = {
      'DELIVERED',
      'COMPLETED',
      'FULLY_DELIVERED',
      'DELIVERED_FULLY',
    };

    return orders.where((order) {
      return deliveredStatuses.contains(
        order.deliveryStatus.trim().toUpperCase(),
      );
    }).length;
  }

  int? get remainingOrders {
    if (ordersStatus != HomeOrdersStatus.success) {
      return null;
    }

    const handledStatuses = {
      'DELIVERED',
      'COMPLETED',
      'FULLY_DELIVERED',
      'DELIVERED_FULLY',
      'PARTIAL',
      'PARTIALLY_DELIVERED',
      'PARTIAL_DELIVERED',
      'DELIVERED_PARTIALLY',
      'RESCHEDULED',
      'CANCELLED',
      'CANCELED',
    };

    final statuses = orders
        .map((order) => order.deliveryStatus.trim().toUpperCase())
        .toList();

    if (statuses.any(
          (status) =>
      status != 'PENDING' &&
          !handledStatuses.contains(status),
    )) {
      return null;
    }

    return statuses.where((status) => status == 'PENDING').length;
  }
}
