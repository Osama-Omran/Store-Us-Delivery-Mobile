import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import '../../data/models/treasury_wallet_response.dart';

import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';

import 'treasury_card.dart';

class TreasuryWalletTransactionCard extends StatelessWidget {
  const TreasuryWalletTransactionCard({super.key, required this.transaction});
  final TreasuryWalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final paymentMethod = transaction.paymentMethod.toLowerCase();
    final paymentLabel = switch (paymentMethod) {
      'cash' => context.strings.treasury_cash,
      'instapay' || 'insta_pay' => context.strings.treasury_insta_pay,
      'wallet' ||
      'electronic_wallet' => context.strings.treasury_electronic_wallet,
      _ => context.strings.payment_method_unknown,
    };
    final time = transaction.collectedAt == null
        ? ''
        : DateFormat(
            'dd/MM/yyyy  hh:mm a',
            context.language,
          ).format(transaction.collectedAt!.toLocal());

    return TreasuryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  transaction.customer,
                  style: Styles.textStyle18.copyWith(color: AppColors.black1),
                ),
              ),
              Text(
                context.strings.treasury_collected,
                style: Styles.textStyle12.copyWith(color: AppColors.green0),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            [
              transaction.salesOrder,
              time,
            ].where((it) => it.isNotEmpty).join('  •  '),
            style: Styles.textStyle12.copyWith(color: AppColors.grey4),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.grey0,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _WalletAmount(
                    title: context.strings.treasury_wallet_collected_amount,
                    amount: transaction.collectedAmount,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _WalletAmount(
                    title: context.strings.treasury_custody_impact,
                    amount: transaction.walletEffect,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.payments_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  paymentLabel,
                  style: Styles.textStyle14.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          if (transaction.paymentEntryId != null &&
              transaction.paymentEntryId!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              context.strings.treasury_payment_entry_label(
                transaction.paymentEntryId!,
              ),
              style: Styles.textStyle12.copyWith(color: AppColors.grey4),
            ),
          ],
        ],
      ),
    );
  }
}

class _WalletAmount extends StatelessWidget {
  const _WalletAmount({required this.title, required this.amount});
  final String title;
  final num amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Styles.textStyle12.copyWith(color: AppColors.grey4)),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            formatTripAmount(context, amount),
            style: Styles.textStyle18.copyWith(color: AppColors.black1),
          ),
        ),
      ],
    );
  }
}
