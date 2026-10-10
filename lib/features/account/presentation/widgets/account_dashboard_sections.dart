
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class AccountDashboardSections extends StatelessWidget {
  const AccountDashboardSections({
    super.key,
    required this.userName,
  });

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 20,
      children: [
        // ======= Wallet Summary ======= //
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      context.strings.account_wallet_title,
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.grey4,
                      ),
                    ),
                    Text(
                      '${context.strings.account_wallet_name} $userName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Styles.textStyle18.copyWith(
                        color: AppColors.black1,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '—',
                style: Styles.textStyle24.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        // ======= Statistics ======= //
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: _StatisticCard(
                value: '—',
                title: context.strings.account_today_trips,
                valueColor: AppColors.black1,
              ),
            ),
            Expanded(
              child: _StatisticCard(
                value: '—',
                title: context.strings.account_delivered_orders,
                valueColor: AppColors.green0,
              ),
            ),
            Expanded(
              child: _StatisticCard(
                value: '—',
                title: context.strings.account_today_collection,
                valueColor: AppColors.black1,
              ),
            ),
          ],
        ),

        // ======= Sync Status ======= //
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            spacing: 18,
            children: [
              Text(
                context.strings.account_sync_status,
                style: Styles.textStyle18.copyWith(
                  color: AppColors.black1,
                ),
              ),
              Row(
                spacing: 10,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.grey4,
                    size: 22,
                  ),
                  Expanded(
                    child: Text(
                      context.strings.account_sync_unavailable,
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.grey4,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grey5,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      color: AppColors.black1,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        context.strings.account_offline_preview,
                        style: Styles.textStyle16.copyWith(
                          color: AppColors.black1,
                        ),
                      ),
                    ),
                    const Switch.adaptive(
                      value: false,
                      onChanged: null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white0,
      borderRadius: BorderRadius.circular(26),
      border: Border.all(
        color: AppColors.grey3,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.black1.withValues(alpha: .04),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({
    required this.value,
    required this.title,
    required this.valueColor,
  });

  final String value;
  final String title;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 110,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.grey3,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 7,
        children: [
          Text(
            value,
            style: Styles.textStyle24.copyWith(
              color: valueColor,
            ),
          ),
          Text(
            title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Styles.textStyle12.copyWith(
              color: AppColors.grey4,
            ),
          ),
        ],
      ),
    );
  }
}
