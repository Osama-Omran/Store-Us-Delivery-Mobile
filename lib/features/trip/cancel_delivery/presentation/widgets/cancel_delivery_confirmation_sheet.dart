
import 'package:flutter/material.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class CancelDeliveryConfirmationSheet extends StatelessWidget {
  const CancelDeliveryConfirmationSheet({
    super.key,
    required this.salesOrder,
    required this.reason,
  });

  final String salesOrder;
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              Text(
                context.strings.cancel_delivery_confirm_title,
                textAlign: TextAlign.center,
                style: Styles.textStyle22.copyWith(
                  color: AppColors.black1,
                  fontWeight: FontWeight.w800,
                ),
              ),

              Text(
                '${context.strings.cancel_delivery_confirm_description} '
                    '$salesOrder\n'
                    '${context.strings.cancel_delivery_reason_label}: $reason',
                textAlign: TextAlign.center,
                style: Styles.textStyle14.copyWith(
                  color: AppColors.grey4,
                ),
              ),

              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 62,
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.black1,
                          side: BorderSide(
                            color: AppColors.grey3,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(23),
                          ),
                        ),
                        child: Text(
                          context.strings.back,
                          style: Styles.textStyle16.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: SizedBox(
                      height: 62,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.red1,
                          foregroundColor: AppColors.white0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(23),
                          ),
                        ),
                        child: Text(
                          context.strings.cancel_delivery_yes,
                          textAlign: TextAlign.center,
                          style: Styles.textStyle16.copyWith(
                            color: AppColors.white0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
