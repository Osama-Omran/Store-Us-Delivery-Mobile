import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_cubit.dart';

import '../../data/models/delivery_outcome_request_body.dart';

class DeliveryError extends StatelessWidget {
  const DeliveryError({
    super.key,
    required this.message,
    required this.tripId,
    required this.orderId,
  });

  final String message;
  final int tripId;
  final int orderId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Icon(Icons.error_outline_rounded, size: 44, color: AppColors.red1),

            Text(
              context.localizedErrorMessage(message),
              textAlign: TextAlign.center,
            ),

            OutlinedButton.icon(
              onPressed: () {
                context.read<OrderDetailsCubit>().getOrderDetails(
                  tripId: tripId,
                  orderId: orderId,
                );
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.strings.current_trip_retry),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// Not Pending
// =====================================================

class DeliveryUnavailable extends StatelessWidget {
  const DeliveryUnavailable({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 18,
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: AppColors.primary,
              size: 44,
            ),

            Text(
              context.strings.delivery_order_not_pending,
              textAlign: TextAlign.center,
              style: Styles.base.copyWith(
                color: AppColors.black1,
                fontWeight: FontWeight.w700,
              ),
            ),

            Text(status, style: Styles.base.copyWith(color: AppColors.grey4)),

            OutlinedButton(
              onPressed: () => context.pop(),
              child: Text(context.strings.delivery_back_to_edit),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// Server-confirmed outcome
// =====================================================
class DeliveryOutcomeCompleted extends StatelessWidget {
  const DeliveryOutcomeCompleted({super.key, required this.outcome});

  final DeliveryOutcomeType outcome;

  @override
  Widget build(BuildContext context) {
    final cancelled = outcome == DeliveryOutcomeType.cancelled;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              cancelled ? Icons.cancel_outlined : Icons.event_available_rounded,
              size: 70,
              color: cancelled ? AppColors.red1 : AppColors.green0,
            ),
            const SizedBox(height: 16),
            Text(
              cancelled
                  ? context.strings.delivery_cancel_success
                  : context.strings.delivery_reschedule_success,
              textAlign: TextAlign.center,
              style: Styles.textStyle20.copyWith(
                color: AppColors.black1,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop(true);
                } else {
                  context.goNamed(RoutesNames.layout);
                }
              },
              child: Text(context.strings.delivery_outcome_back),
            ),
          ],
        ),
      ),
    );
  }
}
