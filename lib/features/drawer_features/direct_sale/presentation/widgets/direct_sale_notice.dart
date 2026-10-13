import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class DirectSaleNotice extends StatelessWidget {
  const DirectSaleNotice({
    super.key,
    required this.message,
    this.error = false,
  });

  final String message;
  final bool error;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: error ? AppColors.red2 : AppColors.grey5,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          error ? Icons.error_outline : Icons.info_outline,
          size: 20,
          color: error ? AppColors.red1 : AppColors.grey4,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: Styles.textStyle14.copyWith(
              color: error ? AppColors.red1 : AppColors.grey4,
            ),
          ),
        ),
      ],
    ),
  );
}
