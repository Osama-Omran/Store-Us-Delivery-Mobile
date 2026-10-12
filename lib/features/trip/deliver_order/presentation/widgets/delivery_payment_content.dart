import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_flow_data.dart';
import 'delivery_collection_selector.dart';
import 'delivery_payment_amount_field.dart';
import 'delivery_payment_summary_card.dart';

class DeliveryPaymentContent extends StatelessWidget {
  const DeliveryPaymentContent({
    super.key,
    required this.flow,
    required this.expected,
    required this.amountController,
    required this.isLoading,
    required this.amountMatches,
    required this.showMismatch,
    required this.onAmountChanged,
    required this.hasProof,
    required this.onOpenProof,required this.collectPayment,
    required this.onCollectionChanged,
  });

  final DeliveryFlowData flow;
  final num? expected;
  final TextEditingController amountController;
  final bool isLoading;
  final bool amountMatches;
  final bool showMismatch;
  final ValueChanged<String> onAmountChanged;
  final bool hasProof;
  final VoidCallback onOpenProof;final bool collectPayment;
  final ValueChanged<bool> onCollectionChanged;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      DeliveryPaymentSummaryCard(
        originalTotal: flow.originalTotal,
        expected: expected,
        collectPayment: collectPayment,
      ),

      const SizedBox(height: 22),

      DeliveryCollectionSelector(
        collectPayment: collectPayment,
        enabled: !isLoading,
        onChanged: onCollectionChanged,
      ),

      const SizedBox(height: 22),



      if (collectPayment) ...[
        Text(
          context.strings.delivery_collected_amount,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 10),

        DeliveryPaymentAmountField(
          controller: amountController,
          isLoading: isLoading,
          amountMatches: amountMatches,
          showMismatch: showMismatch,
          onChanged: onAmountChanged,
        ),

        const SizedBox(height: 10),

        if (amountMatches)
          _StatusMessage(
            message: context.strings.delivery_amount_matches,
            success: true,
          )
        else if (showMismatch)
          _StatusMessage(
            message: context.strings.delivery_amount_mismatch,
            success: false,
          ),

        const SizedBox(height: 26),

        Text(
          context.strings.delivery_payment_method,
          style: TextStyle(
            color: AppColors.black1,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _PaymentMethodTile(
                icon: Icons.payments_outlined,
                title: context.strings.delivery_cash,
                selected: true,
                enabled: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: const _PaymentMethodTile(
                icon: Icons.phone_android,
                title: 'InstaPay',
                selected: false,
                enabled: false,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PaymentMethodTile(
                icon: Icons.credit_card,
                title: context.strings.delivery_wallet,
                selected: false,
                enabled: false,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          context.strings.delivery_payment_not_supported,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.grey4,
          ),
        ),
      ] else ...[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.orange1,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.orange0,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.strings.delivery_no_collection_notice,
                  style: TextStyle(
                    color: AppColors.black1,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],

      if (flow.hasMissingLineIds) ...[
        const SizedBox(height: 12),
        _StatusMessage(
          message: context.strings.delivery_missing_line_ids,
          success: false,
        ),
      ],

      const SizedBox(height: 20),


      const SizedBox(height: 10),
      DeliveryPaymentAmountField(
        controller: amountController,
        isLoading: isLoading,
        amountMatches: amountMatches,
        showMismatch: showMismatch,
        onChanged: onAmountChanged,
      ),

      const SizedBox(height: 10),

      if (amountMatches)
        _StatusMessage(
          message: context.strings.delivery_amount_matches,
          success: true,
        )
      else if (showMismatch)
        _StatusMessage(
          message: context.strings.delivery_amount_mismatch,
          success: false,
        ),

      if (flow.hasMissingLineIds) ...[
        const SizedBox(height: 12),
        _StatusMessage(
          message: context.strings.delivery_missing_line_ids,
          success: false,
        ),
      ],

      const SizedBox(height: 26),

      Text(
        context.strings.delivery_payment_method,
        style: TextStyle(
          color: AppColors.black1,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),

      const SizedBox(height: 12),

      Row(
        children: [
          Expanded(
            child: _PaymentMethodTile(
              icon: Icons.payments_outlined,
              title: context.strings.delivery_cash,
              selected: true,
              enabled: true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: const _PaymentMethodTile(
              icon: Icons.phone_android,
              title: 'InstaPay',
              selected: false,
              enabled: false,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _PaymentMethodTile(
              icon: Icons.credit_card,
              title: context.strings.delivery_wallet,
              selected: false,
              enabled: false,
            ),
          ),
        ],
      ),

      const SizedBox(height: 8),

      Text(
        context.strings.delivery_payment_not_supported,
        style: TextStyle(fontSize: 12, color: AppColors.grey4),
      ),

      const SizedBox(height: 20),

      OutlinedButton.icon(
        onPressed: isLoading ? null : onOpenProof,
        icon: const Icon(Icons.camera_alt_outlined),
        label: Text(
          hasProof
              ? context.strings.delivery_proof_prepared
              : context.strings.delivery_add_proof,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    ],
  );
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.message, required this.success});

  final String message;
  final bool success;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: success
            ? AppColors.green1
            : AppColors.red1.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: success ? AppColors.green0 : AppColors.red1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.enabled,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : .45,
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: selected ? AppColors.blue4 : AppColors.white0,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.grey3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 7,
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.grey4),
            Text(
              title,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.black1,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
