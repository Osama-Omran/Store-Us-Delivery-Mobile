
import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class AppMenuDrawerItem extends StatelessWidget {
  const AppMenuDrawerItem({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.badgeCount,
    this.isSelected = false,
    this.isLogout = false,
    this.showDivider = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final int? badgeCount;
  final bool isSelected;
  final bool isLogout;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final titleColor = isLogout
        ? AppColors.red0
        : isSelected
        ? AppColors.primary
        : AppColors.black1;

    final iconColor = isLogout
        ? AppColors.red0
        : isSelected
        ? AppColors.primary
        : AppColors.grey4;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 3,
          ),
          child: Material(
            color: isSelected
                ? AppColors.blue4
                : AppColors.white0,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(
                      icon,
                      size: 24,
                      color: iconColor,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: Styles.textStyle18.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (badgeCount != null &&
                        badgeCount! > 0)
                      Container(
                        height: 28,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.orange0,
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$badgeCount',
                          style: Styles.textStyle12.copyWith(
                            color: AppColors.white0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
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
