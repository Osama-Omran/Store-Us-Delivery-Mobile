import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_outcome_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_outcome_state.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_reasons_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_reasons_state.dart';

class RescheduleOrderSubmitButton extends StatelessWidget {
  const RescheduleOrderSubmitButton({
    super.key,
    required this.canSubmit,
    required this.onSubmit,
  });
  final ValueGetter<bool> canSubmit;
  final VoidCallback onSubmit;
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DeliveryReasonsCubit, DeliveryReasonsState>(
        bloc: DeliveryOutcomeCubit.get(context).reasonsCubit,
        builder: (context, _) =>
            BlocSelector<DeliveryOutcomeCubit, DeliveryOutcomeState, bool>(
              selector: (state) => state is DeliveryOutcomeLoading,
              builder: (context, isLoading) {
                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  decoration: BoxDecoration(
                    color: AppColors.white0,
                    border: Border(top: BorderSide(color: AppColors.grey3)),
                  ),
                  child: SizedBox(
                    height: 66,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canSubmit() && !isLoading ? onSubmit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.blue0,
                        foregroundColor: AppColors.white0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                        ),
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(color: AppColors.white0)
                          : Text(
                              context.strings.reschedule_confirm,
                              style: Styles.textStyle18.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
      );
}
