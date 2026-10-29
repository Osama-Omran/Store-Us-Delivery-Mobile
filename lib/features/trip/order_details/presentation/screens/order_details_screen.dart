import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_outcome_cubit.dart';

import '../cubit/order_details_cubit.dart';
import '../widgets/order_details_body.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({
    super.key,
    required this.tripId,
    required this.orderId,
  });

  final int tripId;
  final int orderId;

  void _goBack(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.goNamed(RoutesNames.layout);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: GoRouter.of(context).canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goBack(context);
      },
      child: MultiBlocProvider(
        key: ValueKey((tripId, orderId)),
        providers: [
          BlocProvider<OrderDetailsCubit>(
            create: (_) =>
                getIt<OrderDetailsCubit>()
                  ..getOrderDetails(tripId: tripId, orderId: orderId),
          ),
          BlocProvider<DeliveryOutcomeCubit>(
            create: (_) => getIt<DeliveryOutcomeCubit>(),
          ),
        ],
        child: OrderDetailsBody(
          tripId: tripId,
          orderId: orderId,
          onBack: () => _goBack(context),
        ),
      ),
    );
  }
}
