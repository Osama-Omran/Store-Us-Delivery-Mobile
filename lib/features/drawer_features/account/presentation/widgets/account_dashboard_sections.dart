import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/widgets/account_surface_card.dart';

class AccountDashboardSections extends StatelessWidget {
  const AccountDashboardSections({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AccountCubit.get(context).currentUser;
    if (user == null) return const SizedBox.shrink();

    return Column(
      children: [
        AccountSurfaceCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.strings.account_wallet_title,
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.grey4,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      context.strings.account_named_wallet(user.name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Styles.textStyle18.copyWith(
                        color: AppColors.black1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(12),
              // The /me response does not include a wallet balance.
              Text(
                '—',
                style: Styles.textStyle24.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const Gap(16),
        Row(
          children: [
            Expanded(
              child: _StatCard(title: context.strings.account_today_trips),
            ),
            const Gap(8),
            Expanded(
              child: _StatCard(title: context.strings.account_delivered_orders),
            ),
            const Gap(8),
            Expanded(
              child: _StatCard(title: context.strings.account_today_collection),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AccountSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        children: [
          Text(
            '—',
            style: Styles.textStyle24.copyWith(color: AppColors.black1),
          ),
          const Gap(6),
          Text(
            title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Styles.textStyle12.copyWith(color: AppColors.grey4),
          ),
        ],
      ),
    );
  }
}
