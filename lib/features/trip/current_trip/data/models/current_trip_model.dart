import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';

class CurrentTripModel {
  const CurrentTripModel({
    required this.id,
    required this.vehicleName,
    required this.plateNumber,
    required this.driverName,
    required this.warehouseName,
    required this.totalOrders,
    required this.handledOrders,
    required this.collectedAmount,
  });

  final String id;
  final String vehicleName;
  final String plateNumber;
  final String driverName;
  final String warehouseName;

  final int? totalOrders;
  final int? handledOrders;
  final num? collectedAmount;

  factory CurrentTripModel.fromApi(
    CurrentTripData trip, {
    List<TripOrderModel>? orders,
  }) {
    return CurrentTripModel(
      id: trip.number,
      vehicleName: _nameOrId(trip.vehicle?.name, trip.vehicle?.id),
      plateNumber: '',
      driverName: _nameOrId(trip.driver?.name, trip.driver?.id),
      warehouseName: _nameOrId(trip.warehouse?.name, trip.warehouse?.id),

      totalOrders: trip.ordersSummary?.total ?? orders?.length,

      handledOrders: orders?.where((order) => order.isHandled).length,

      // The orders API does not return collected amounts.
      collectedAmount: null,
    );
  }

  static String _nameOrId(String? name, String? id) {
    if (name != null && name.trim().isNotEmpty) {
      return name;
    }

    if (id != null && id.trim().isNotEmpty) {
      return id;
    }

    return '—';
  }

  int? get remainingOrders {
    if (totalOrders == null || handledOrders == null) {
      return null;
    }

    final remaining = totalOrders! - handledOrders!;
    return remaining < 0 ? 0 : remaining;
  }

  double? get progress {
    if (totalOrders == null || handledOrders == null) {
      return null;
    }

    if (totalOrders == 0) return 0;

    return (handledOrders! / totalOrders!).clamp(0.0, 1.0).toDouble();
  }

  int? get progressPercent {
    if (progress == null) return null;

    return (progress! * 100).round();
  }
}
