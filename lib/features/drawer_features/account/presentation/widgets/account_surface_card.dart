import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

/// Shared, lightweight surface for the account page cards.
class AccountSurfaceCard extends StatelessWidget {
  const AccountSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.grey3, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black1.withValues(alpha: .035),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
