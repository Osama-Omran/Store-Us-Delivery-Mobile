import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

class TripCustomersMessage extends StatelessWidget {
  const TripCustomersMessage({
    super.key,
    required this.message,
    required this.icon,
    this.buttonText,
    this.onRetry,
  });
  final String message;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: AppColors.white0,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        Icon(icon, size: 45, color: AppColors.primary),
        const SizedBox(height: 16),
        Text(
          context.localizedErrorMessage(message),
          textAlign: TextAlign.center,
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 13),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(buttonText ?? ''),
          ),
        ],
      ],
    ),
  );
}
