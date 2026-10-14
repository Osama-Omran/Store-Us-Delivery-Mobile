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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          child: Material(
            color: isSelected ? AppColors.blue4 : AppColors.white0,
            borderRadius: BorderRadius.circular(17),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(17),
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  border: isSelected
                      ? Border.all(
                          color: AppColors.primary.withValues(alpha: 0.10),
                        )
                      : null,
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isLogout
                            ? AppColors.red0.withValues(alpha: 0.07)
                            : isSelected
                                ? AppColors.primary.withValues(alpha: 0.10)
                                : AppColors.grey3.withValues(alpha: 0.30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 23, color: iconColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: Styles.textStyle18.copyWith(
                          color: titleColor,
                          fontWeight: isSelected || isLogout
                              ? FontWeight.w800
                              : FontWeight.w700,
                        ),
                      ),
                    ),
                    if (badgeCount != null && badgeCount! > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        height: 27,
                        constraints: const BoxConstraints(minWidth: 27),
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.orange0,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.white0.withValues(alpha: 0.75),
                          ),
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
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.grey3,
            ),
          ),
      ],
    );
  }
}
