import 'package:flutter/material.dart';

import 'delivery_outcome_sheet.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_outcome_request_body.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_outcome_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_outcome_state.dart';

/// Available for PENDING orders, regardless of selected delivery quantities.
class DeliveryOutcomeActions extends StatelessWidget {
  const DeliveryOutcomeActions({
    super.key,
    required this.tripId,
    required this.orderId,
  });

  final int tripId;
  final int orderId;

  void _openSheet(BuildContext context, DeliveryOutcomeType outcome) {
    final cubit = context.read<DeliveryOutcomeCubit>();
    if (cubit.state is DeliveryOutcomeLoading ||
        cubit.state is DeliveryOutcomeSuccess) {
      return;
    }
    cubit.resetFailure();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      backgroundColor: AppColors.white0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: DeliveryOutcomeSheet(
          tripId: tripId,
          orderId: orderId,
          outcome: outcome,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.strings.delivery_outcome_actions_title,
            style: Styles.textStyle17.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.black1,
            ),
          ),
          const SizedBox(height: 12),
          BlocSelector<DeliveryOutcomeCubit, DeliveryOutcomeState, bool>(
            selector: (state) =>
                state is DeliveryOutcomeLoading ||
                state is DeliveryOutcomeSuccess,
            builder: (context, disabled) => Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: disabled
                        ? null
                        : () => _openSheet(
                            context,
                            DeliveryOutcomeType.rescheduled,
                          ),
                    icon: const Icon(Icons.event_repeat_rounded),
                    label: Text(context.strings.delivery_reschedule),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: disabled
                        ? null
                        : () => _openSheet(
                            context,
                            DeliveryOutcomeType.cancelled,
                          ),
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(context.strings.delivery_cancel),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red1,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
