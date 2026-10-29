import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_outcome_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_outcome_state.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_reasons_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_reasons_state.dart';

class CancelDeliverySubmitButton extends StatelessWidget {
  const CancelDeliverySubmitButton({
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
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  decoration: BoxDecoration(
                    color: AppColors.white0,
                    border: Border(top: BorderSide(color: AppColors.grey3)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 68,
                    child: ElevatedButton(
                      onPressed: isLoading || !canSubmit() ? null : onSubmit,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.red1,
                        disabledBackgroundColor: AppColors.red1.withValues(
                          alpha: 0.4,
                        ),
                        foregroundColor: AppColors.white0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                color: AppColors.white0,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              context.strings.cancel_delivery_confirm_button,
                              style: Styles.textStyle18.copyWith(
                                color: AppColors.white0,
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
