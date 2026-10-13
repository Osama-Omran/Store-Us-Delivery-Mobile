
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_state.dart';

typedef TripBadgeCounts = ({
int? deliveries,
int receiveVehicle,
});

TripBadgeCounts getTripBadgeCounts(TripTabState state) {
  if (state is! TripTabSuccessState) {
    return (deliveries: null, receiveVehicle: 0);
  }

  final tripStatus = state.trip.status.trim().toUpperCase();
  final acceptance = state.trip.acceptance?.status.trim().toUpperCase();

  final isAccepted =
      acceptance == 'ACCEPTED' || acceptance == 'OVERRIDDEN';

  final canReceiveVehicle =
      tripStatus == 'SHIPPED' && acceptance == 'PENDING';

  return (
  deliveries: isAccepted &&
      state.ordersStatus == TripOrdersStatus.success
      ? state.orders.where((order) => order.isPending).length
      : null,
  receiveVehicle: canReceiveVehicle ? 1 : 0,
  );
}
