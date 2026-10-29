import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import 'treasury_wallet_shimmer.dart';
import 'treasury_wallet_transaction_card.dart';

import 'package:storeus_delivery/features/drawer_features/treasury/data/models/treasury_wallet_response.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/cubit/treasury_state.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/widgets/treasury_card.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/widgets/treasury_wallet_cards.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';

/// Wallet only. Inventory widgets and their preview/sample data are untouched.
class TreasuryWalletLive extends StatelessWidget {
  const TreasuryWalletLive({
    super.key,
    required this.state,
    required this.onRefresh,
  });

  final TreasuryState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final wallet = state.wallet;
    if (state.walletLoading && wallet == null) {
      return const TreasuryWalletShimmer();
    }
    if (state.walletHasNoTrip) return const TreasuryEmptyWallet();

    if (wallet == null) {
      return _WalletMessage(
        message: state.walletError == null
            ? context.strings.treasury_wallet_no_data
            : state.walletError!.trim().isEmpty
            ? context.strings.treasury_wallet_load_failed
            : state.walletError!,
        onRetry: onRefresh,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.strings.treasury_trip_title(wallet.trip),
                style: Styles.textStyle16.copyWith(color: AppColors.black1),
              ),
            ),
            IconButton(
              tooltip: context.strings.treasury_wallet_refresh,
              onPressed: state.walletLoading ? null : onRefresh,
              icon: state.walletLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TreasuryCard(
          borderColor: AppColors.blue3,
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [AppColors.white0, AppColors.lightPrimary],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.strings.treasury_trip_custody,
                style: Styles.textStyle18.copyWith(color: AppColors.grey4),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  formatTripAmount(context, wallet.custodyBalance),
                  style: Styles.textStyle24.copyWith(
                    color: AppColors.primary,
                    fontSize: 48,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.strings.treasury_wallet_balance_description,
                style: Styles.textStyle14.copyWith(color: AppColors.grey4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _WalletStatistics(wallet: wallet),
        const SizedBox(height: 16),
        _SettlementStatus(wallet: wallet),
        if (state.walletError != null) ...[
          const SizedBox(height: 12),
          _WalletMessage(
            message: state.walletError!.trim().isEmpty
                ? context.strings.treasury_wallet_load_failed
                : state.walletError!,
            onRetry: onRefresh,
          ),
        ],
        const SizedBox(height: 24),
        Text(
          context.strings.treasury_collection_details,
          style: Styles.textStyle24.copyWith(color: AppColors.black1),
        ),
        const SizedBox(height: 14),
        if (wallet.transactions.isEmpty)
          TreasuryCard(
            child: Center(
              child: Text(
                context.strings.treasury_wallet_no_transactions,
                style: Styles.textStyle16.copyWith(color: AppColors.grey4),
              ),
            ),
          )
        else
          for (final transaction in wallet.transactions) ...[
            TreasuryWalletTransactionCard(transaction: transaction),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _WalletStatistics extends StatelessWidget {
  const _WalletStatistics({required this.wallet});
  final TreasuryWalletData wallet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = [
          _WalletMetric(
            title: context.strings.treasury_collected_total,
            value: formatTripAmount(context, wallet.totalCollected),
            color: AppColors.green0,
          ),
          _WalletMetric(
            title: context.strings.treasury_wallet_received_warehouse,
            value: formatTripAmount(context, wallet.totalReceivedByWarehouse),
            color: AppColors.black1,
          ),
          _WalletMetric(
            title: context.strings.treasury_collected_orders,
            value: '${wallet.transactions.length}',
            color: AppColors.black1,
          ),
        ];
        if (constraints.maxWidth < 300 ||
            MediaQuery.textScalerOf(context).scale(16) > 20) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: metrics,
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [for (final metric in metrics) Expanded(child: metric)],
          ),
        );
      },
    );
  }
}

class _WalletMetric extends StatelessWidget {
  const _WalletMetric({
    required this.title,
    required this.value,
    required this.color,
  });
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);

    return TreasuryCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: textScaler.scale(12) * 1.5 * 2,
            child: Center(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Styles.textStyle12.copyWith(
                  color: AppColors.grey4,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: Styles.textStyle18.copyWith(color: color, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _SettlementStatus extends StatelessWidget {
  const _SettlementStatus({required this.wallet});
  final TreasuryWalletData wallet;

  @override
  Widget build(BuildContext context) {
    final status = wallet.settlementStatus.trim().toUpperCase();
    final settled = const {'SETTLED', 'COMPLETED', 'PAID'}.contains(status);
    final pending = const {'PENDING', 'UNSETTLED'}.contains(status);
    final label = settled
        ? context.strings.treasury_settled
        : pending
        ? context.strings.treasury_pending_settlement
        : status == 'PARTIAL' || status == 'PARTIALLY_SETTLED'
        ? context.strings.treasury_wallet_partially_settled
        : context.strings.treasury_wallet_status_unknown;
    final color = settled ? AppColors.green0 : AppColors.orange0;
    return TreasuryCard(
      color: settled ? AppColors.green1 : AppColors.orange1,
      borderColor: color.withValues(alpha: .35),
      child: Row(
        children: [
          Icon(
            settled ? Icons.check_circle_outline : Icons.access_time_rounded,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Styles.textStyle16.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletMessage extends StatelessWidget {
  const _WalletMessage({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return TreasuryCard(
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.grey4),
          const SizedBox(height: 14),
          Text(
            context.localizedErrorMessage(message),
            textAlign: TextAlign.center,
            style: Styles.textStyle14.copyWith(color: AppColors.black1),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(context.strings.treasury_wallet_retry),
          ),
        ],
      ),
    );
  }
}
