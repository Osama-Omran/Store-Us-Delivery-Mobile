import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import '../cubit/order_details_cubit.dart';
import '../cubit/order_details_state.dart';
import 'order_details_shimmer.dart';
import 'order_details_loaded_content.dart';

class OrderDetailsContent extends StatelessWidget {
  const OrderDetailsContent({
    super.key,
    required this.tripId,
    required this.orderId,
  });
  final int tripId;
  final int orderId;
  Future<void> _reload(BuildContext context) =>
      OrderDetailsCubit.get(context)
          .getOrderDetails(tripId: tripId, orderId: orderId);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
        buildWhen: (previous, current) =>
            previous is! OrderDetailsSuccessState ||
            current is! OrderDetailsSuccessState ||
            previous.order != current.order ||
            previous.tripOrder != current.tripOrder ||
            previous.locationUpdated != current.locationUpdated,
        builder: (context, state) => switch (state) {
          OrderDetailsInitial() ||
          OrderDetailsLoadingState() => const OrderDetailsShimmer(),
          OrderDetailsFailureState() => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 44,
                    color: AppColors.red1,
                  ),

                  Text(
                    state.errorMessage?.isNotEmpty == true
                        ? context.localizedErrorMessage(state.errorMessage)
                        : context.strings.order_details_load_failed,
                    textAlign: TextAlign.center,
                  ),

                  OutlinedButton(
                    onPressed: () => _reload(context),
                    child: Text(context.strings.current_trip_retry),
                  ),
                ],
              ),
            ),
          ),
          OrderDetailsSuccessState() => OrderDetailsLoadedContent(
            tripId: tripId,
            orderId: orderId,
          ),
          _ => const SizedBox.shrink(),
        },
      );
}
