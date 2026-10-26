import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class OrderCollectionActionBar extends StatelessWidget {
  const OrderCollectionActionBar({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.white0,
        border: Border(top: BorderSide(color: AppColors.grey3)),
      ),
      child: SizedBox(
        height: 58,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.payments_outlined, size: 24),
          label: Text(
            context.strings.order_collection_button,
            style: Styles.textStyle17.copyWith(fontWeight: FontWeight.w800),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(19),
            ),
          ),
        ),
      ),
    ),
  );
}
