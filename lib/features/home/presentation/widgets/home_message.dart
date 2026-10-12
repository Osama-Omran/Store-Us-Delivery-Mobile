import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

class HomeMessage extends StatelessWidget {
  const HomeMessage({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        spacing: 18,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 54,
            color: AppColors.primary,
          ),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.grey4, fontSize: 15),
          ),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(context.strings.current_trip_retry),
          ),
        ],
      ),
    );
  }
}
