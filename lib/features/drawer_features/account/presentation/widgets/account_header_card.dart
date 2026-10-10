
import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/account/data/models/me_response.dart';

class AccountHeaderCard extends StatelessWidget {
  const AccountHeaderCard({
    super.key,
    required this.user,
    this.isOnTrip = false,
  });

  final AccountUser user;
  final bool isOnTrip;

  @override
  Widget build(BuildContext context) {
    final role = user.role == 'Delivery Representative'
        ? context.strings.account_delivery_representative
        : user.role;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.grey3),
        boxShadow: [
          BoxShadow(
            color: AppColors.black1.withValues(alpha: .04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        spacing: 18,
        children: [
          Container(
            width: 80,
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.person_outline_rounded,
              size: 44,
              color: AppColors.white0,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.textStyle24.copyWith(
                    color: AppColors.black1,
                  ),
                ),
                Text(
                  role,
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.grey4,
                  ),
                ),
                Text(
                  user.employeeId,
                  textDirection: TextDirection.ltr,
                  style: Styles.textStyle12.copyWith(
                    color: AppColors.grey4,
                  ),
                ),
                if (isOnTrip)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue4,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        context.strings.currently_on_trip,
                        style: Styles.textStyle12.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
