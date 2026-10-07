import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

class CustomTripContainer extends StatelessWidget {
  const CustomTripContainer({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white0,
        border: Border.all(color: AppColors.grey2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
