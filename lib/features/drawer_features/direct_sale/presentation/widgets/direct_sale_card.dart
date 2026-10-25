import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

class DirectSaleCard extends StatelessWidget {
  const DirectSaleCard({super.key, required this.child, this.selected = false});

  final Widget child;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white0,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: selected ? AppColors.primary : AppColors.grey3,
        width: selected ? 2 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.black1.withValues(alpha: .035),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );
}
