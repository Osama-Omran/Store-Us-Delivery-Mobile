import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/widgets/account_surface_card.dart';

class AccountHeaderCard extends StatelessWidget {
  const AccountHeaderCard({super.key, this.isOnTrip = false});

  final bool isOnTrip;

  @override
  Widget build(BuildContext context) {
    final user = AccountCubit.get(context).currentUser;
    if (user == null) return const SizedBox.shrink();

    return AccountSurfaceCard(
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 40,
              color: AppColors.white0,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.textStyle24.copyWith(
                    color: AppColors.black1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    context.localizedUserRole(user.role),
                    if (user.employeeId.isNotEmpty) user.employeeId,
                  ].join(' • '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.textStyle12.copyWith(color: AppColors.grey4),
                ),
                if (isOnTrip) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blue4,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      context.strings.currently_on_trip,
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
