import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

class AppMenuDrawerItem extends StatelessWidget {
  const AppMenuDrawerItem({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.badgeCount,
    this.isLogout = false,
    this.showDivider = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final int? badgeCount;
  final bool isLogout;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final titleColor = isLogout ? AppColors.red0 : AppColors.black1;
    final iconColor = isLogout ? AppColors.red0 : AppColors.grey4;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 18,
            ),
            child: Row(
              children: [
                if (badgeCount != null) ...[
                  Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.orange0,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: TextStyle(
                        color: AppColors.white0,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                ] else
                  const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 14),
                Icon(
                  icon,
                  size: 24,
                  color: iconColor,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.grey3,
          ),
      ],
    );
  }
}