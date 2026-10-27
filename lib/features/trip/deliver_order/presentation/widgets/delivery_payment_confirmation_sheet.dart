import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_flow_data.dart';

import 'delivery_payment_summary_card.dart';

import 'package:storeus_delivery/core/theme/text_styles.dart';

class DeliveryPaymentConfirmationSheet extends StatelessWidget {
  const DeliveryPaymentConfirmationSheet({
    super.key,
    required this.flow,
    required this.strings,
    required this.expectedAmountText,
    required this.enteredAmountText,
    this.hasReceipt = false,
  });

  final DeliveryFlowData flow;
  final AppLocalizations strings;
  final String expectedAmountText;
  final String enteredAmountText;
  final bool hasReceipt;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 15,
            children: [
              // ======= Confirmation Title ======= //
              Text(
                strings.delivery_confirmation_summary,
                style: Styles.textStyle22,
              ),

              // ======= Customer Name ======= //
              DeliveryPaymentReviewRow(
                label: strings.order_customer_data,
                value: flow.customerName,
              ),

              // ======= Sales Order ======= //
              DeliveryPaymentReviewRow(
                label: strings.order,
                value: flow.salesOrder,
              ),

              // ======= Delivery Status ======= //
              DeliveryPaymentReviewRow(
                label: strings.delivery_status_label,
                value: flow.isPartial
                    ? strings.delivery_partial_draft
                    : strings.delivery_full_draft,
              ),

              // ======= Delivered Items Value ======= //
              DeliveryPaymentReviewRow(
                label: strings.delivery_selected_items_value,
                value: expectedAmountText,
              ),

              // ======= Mandatory Cash Collection ======= //
              DeliveryPaymentReviewRow(
                label: strings.delivery_collected_amount,
                value: enteredAmountText,
              ),
              DeliveryPaymentReviewRow(
                label: strings.delivery_payment_method,
                value: strings.delivery_cash,
              ),

              // ======= Confirmation Warning ======= //
              Text(
                strings.delivery_confirmation_warning,
                style: Styles.textStyle13.copyWith(
                  color: AppColors.grey4,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 4),

              // ======= Actions ======= //
              Row(
                children: [
                  // ======= Confirm Button ======= //
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green0,
                        foregroundColor: AppColors.white0,
                        minimumSize: const Size.fromHeight(58),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        strings.delivery_confirm_button,
                        textAlign: TextAlign.center,
                        style: Styles.base.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ======= Back Button ======= //
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(58),
                        foregroundColor: AppColors.black1,
                        side: BorderSide(color: AppColors.grey3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        strings.back,
                        style: Styles.textStyle15.copyWith(
                          fontWeight: FontWeight.w700,
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
