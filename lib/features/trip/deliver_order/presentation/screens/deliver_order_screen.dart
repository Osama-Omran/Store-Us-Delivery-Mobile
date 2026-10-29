import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_cubit.dart';

import '../cubit/delivery_draft_cubit.dart';
import '../cubit/delivery_outcome_cubit.dart';
import '../widgets/deliver_order_body.dart';

class DeliverOrderScreen extends StatelessWidget {
  const DeliverOrderScreen({
    super.key,
    required this.tripId,
    required this.orderId,
  });

  final int tripId;
  final int orderId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ======= Real Order Data ======= //
        BlocProvider<OrderDetailsCubit>(
          create: (_) =>
              getIt<OrderDetailsCubit>()
                ..getOrderDetails(tripId: tripId, orderId: orderId),
        ),

        // ======= Local Delivery Draft ======= //
        BlocProvider<DeliveryDraftCubit>(create: (_) => DeliveryDraftCubit()),
        BlocProvider<DeliveryOutcomeCubit>(
          create: (_) => getIt<DeliveryOutcomeCubit>(),
        ),
      ],
      child: DeliverOrderBody(tripId: tripId, orderId: orderId),
    );
  }
}
