import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import '../cubit/confirm_delivery_cubit.dart';
import '../cubit/confirm_delivery_state.dart';

class DeliveryPaymentSubmitButton extends StatelessWidget {
  const DeliveryPaymentSubmitButton({
    super.key,
    required this.isPickingReceipt,
    required this.canConfirm,
    required this.onReview,
  });
  final bool isPickingReceipt;
  final bool canConfirm;
  final VoidCallback onReview;
  @override
  Widget build(BuildContext context) =>
      BlocSelector<ConfirmDeliveryCubit, ConfirmDeliveryState, bool>(
        selector: (state) => state is ConfirmDeliveryLoading,
        builder: (context, isLoading) {
          return SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(20),
              color: AppColors.white0,
              child: SizedBox(
                height: 68,
                child: ElevatedButton(
                  onPressed: isLoading || isPickingReceipt || !canConfirm
                      ? null
                      : onReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green0,
                    foregroundColor: AppColors.white0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: AppColors.white0)
                      : Text(
                          context.strings.delivery_confirm_button,
                          style: Styles.textStyle19.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      );
}
