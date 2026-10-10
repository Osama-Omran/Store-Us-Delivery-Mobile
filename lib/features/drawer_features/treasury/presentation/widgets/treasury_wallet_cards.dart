import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/data/models/treasury_models.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/widgets/treasury_card.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';

class TreasuryTripStrip extends StatelessWidget {
  const TreasuryTripStrip({super.key, required this.data});

  final TreasuryData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${context.strings.treasury_current_trip} ',
                    style: Styles.textStyle14.copyWith(color: AppColors.grey4),
                  ),
                  TextSpan(
                    text: data.tripNumber,
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.black1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: Text(
              data.vehicleName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Styles.textStyle14.copyWith(color: AppColors.grey4),
            ),
          ),
        ],
      ),
    );
  }
}

class TreasuryBalanceCard extends StatelessWidget {
  const TreasuryBalanceCard({super.key, required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context) {
    return TreasuryCard(
      borderColor: AppColors.blue3,
      gradient: LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [AppColors.white0, AppColors.lightPrimary],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(
            context.strings.treasury_trip_custody,
            style: Styles.textStyle18.copyWith(color: AppColors.grey4),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              formatTripAmount(context, balance),
              style: Styles.textStyle24.copyWith(
                color: AppColors.primary,
                fontSize: 56,
                height: 1.2,
              ),
            ),
          ),
          Text(
            context.strings.treasury_custody_description,
            style: Styles.textStyle14.copyWith(color: AppColors.grey4),
          ),
        ],
      ),
    );
  }
}

class TreasuryWalletStatistics extends StatelessWidget {
  const TreasuryWalletStatistics({super.key, required this.data});

  final TreasuryData data;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Expanded(
            child: _StatisticCard(
              title: context.strings.treasury_delivered_total,
              value: formatTripAmount(context, data.deliveredTotal),
              color: AppColors.black1,
            ),
          ),
          Expanded(
            child: _StatisticCard(
              title: context.strings.treasury_collected_total,
              value: formatTripAmount(context, data.collectedTotal),
              color: AppColors.green0,
            ),
          ),
          Expanded(
            child: _StatisticCard(
              title: context.strings.treasury_collected_orders,
              value: '${data.collections.length}',
              color: AppColors.black1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TreasuryCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(
            title,
            style: Styles.textStyle14.copyWith(
              color: AppColors.grey4,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: Styles.textStyle20.copyWith(color: color, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class TreasuryCollectionCard extends StatelessWidget {
  const TreasuryCollectionCard({super.key, required this.collection});

  final TreasuryCollection collection;

  @override
  Widget build(BuildContext context) {
    return TreasuryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.customerName,
                      style: Styles.textStyle20.copyWith(
                        color: AppColors.black1,
                        height: 1.5,
                      ),
                    ),
                    Text(
                      '${collection.orderNumber} · ${DateFormat.jm(context.language).format(collection.collectedAt)}',
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.grey4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              _PaymentBadge(
                title: context.strings.treasury_collected,
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.green0,
                background: AppColors.green1,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.grey0,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              spacing: 12,
              children: [
                Expanded(
                  child: _CollectionValue(
                    title: context.strings.treasury_delivered_value,
                    value: collection.deliveredAmount,
                  ),
                ),
                Expanded(
                  child: _CollectionValue(
                    title: context.strings.treasury_received_value,
                    value: collection.receivedAmount,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _PaymentBadge(
                    title: switch (collection.paymentMethod) {
                      TreasuryPaymentMethod.cash =>
                        context.strings.treasury_cash,
                      TreasuryPaymentMethod.instaPay =>
                        context.strings.treasury_insta_pay,
                      TreasuryPaymentMethod.electronicWallet =>
                        context.strings.treasury_electronic_wallet,
                    },
                    icon: switch (collection.paymentMethod) {
                      TreasuryPaymentMethod.cash => Icons.payments_outlined,
                      TreasuryPaymentMethod.instaPay => Icons.bolt_rounded,
                      TreasuryPaymentMethod.electronicWallet =>
                        Icons.phone_android_rounded,
                    },
                    color:
                        collection.paymentMethod == TreasuryPaymentMethod.cash
                        ? AppColors.green0
                        : AppColors.primary,
                    background:
                        collection.paymentMethod == TreasuryPaymentMethod.cash
                        ? AppColors.green1
                        : AppColors.lightPrimary,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      context.strings.treasury_custody_impact,
                      textAlign: TextAlign.end,
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.grey4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '${collection.custodyImpact > 0 ? '+' : ''}${formatTripAmount(context, collection.custodyImpact)}',
                      textAlign: TextAlign.end,
                      style: Styles.textStyle20.copyWith(
                        color: collection.custodyImpact > 0
                            ? AppColors.green0
                            : AppColors.grey4,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: AppColors.grey3),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${context.strings.treasury_balance_after}: ',
                  style: Styles.textStyle12.copyWith(
                    color: AppColors.grey4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: formatTripAmount(context, collection.cashBalanceAfter),
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.black1,
                    fontWeight: FontWeight.w700,
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

class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge({
    required this.title,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String title;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          Icon(icon, size: 16, color: color),
          Flexible(
            child: Text(
              title,
              style: Styles.textStyle12.copyWith(color: color, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionValue extends StatelessWidget {
  const _CollectionValue({required this.title, required this.value});

  final String title;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          title,
          style: Styles.textStyle12.copyWith(
            color: AppColors.grey4,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            formatTripAmount(context, value),
            style: Styles.textStyle20.copyWith(
              color: AppColors.black1,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class TreasurySettlementNotice extends StatelessWidget {
  const TreasurySettlementNotice({
    super.key,
    required this.preview,
    required this.balance,
  });

  final TreasuryPreview preview;
  final int balance;

  @override
  Widget build(BuildContext context) {
    final settled = preview == TreasuryPreview.settled;
    final color = settled ? AppColors.green0 : AppColors.orange0;

    return TreasuryCard(
      key: const ValueKey('treasury-settlement-notice'),
      color: settled ? AppColors.green1 : AppColors.orange1,
      borderColor: color.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            spacing: 10,
            children: [
              Icon(
                settled
                    ? Icons.check_circle_outline_rounded
                    : Icons.access_time_rounded,
                color: color,
              ),
              Expanded(
                child: Text(
                  settled
                      ? context.strings.treasury_settled
                      : context.strings.treasury_pending_settlement,
                  style: Styles.textStyle18.copyWith(color: color, height: 1.5),
                ),
              ),
            ],
          ),
          Text(
            '${context.strings.treasury_current_custody}: ${formatTripAmount(context, balance)}',
            style: Styles.textStyle16.copyWith(color: AppColors.black1),
          ),
          Text(
            settled
                ? context.strings.treasury_settled_hint
                : context.strings.treasury_settlement_hint,
            style: Styles.textStyle14.copyWith(color: AppColors.grey4),
          ),
        ],
      ),
    );
  }
}

class TreasuryEmptyWallet extends StatelessWidget {
  const TreasuryEmptyWallet({super.key});

  @override
  Widget build(BuildContext context) {
    return TreasuryCard(
      key: const ValueKey('treasury-empty-wallet'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
      child: Column(
        spacing: 14,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.grey5,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 40,
              color: AppColors.grey4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.strings.treasury_no_active_trip,
            textAlign: TextAlign.center,
            style: Styles.textStyle24.copyWith(
              color: AppColors.black1,
              height: 1.5,
            ),
          ),
          Text(
            context.strings.treasury_no_custody,
            textAlign: TextAlign.center,
            style: Styles.textStyle16.copyWith(color: AppColors.grey4),
          ),
          const SizedBox(height: 4),
          Text(
            context.strings.treasury_balance,
            style: Styles.textStyle14.copyWith(color: AppColors.grey4),
          ),
          Text(
            formatTripAmount(context, 0),
            style: Styles.textStyle24.copyWith(
              color: AppColors.black1,
              fontSize: 40,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
