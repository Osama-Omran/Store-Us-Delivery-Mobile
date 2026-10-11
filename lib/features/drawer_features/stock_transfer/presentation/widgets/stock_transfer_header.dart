import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class StockTransferHeader extends StatelessWidget {
  const StockTransferHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 90),
      decoration: BoxDecoration(
        color: AppColors.grey0,
        border: Border(bottom: BorderSide(color: AppColors.grey3)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 76, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 2,
              children: [
                Text(
                  context.strings.stock_transfer,
                  textAlign: TextAlign.center,
                  style: Styles.textStyle24.copyWith(color: AppColors.black1),
                ),
                Text(
                  context.strings.stock_transfer_subtitle,
                  textAlign: TextAlign.center,
                  style: Styles.textStyle14.copyWith(color: AppColors.grey4),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            start: 20,
            child: Material(
              color: AppColors.white0,
              shape: CircleBorder(side: BorderSide(color: AppColors.grey3)),
              child: InkWell(
                key: const ValueKey('stock-transfer-back'),
                onTap: onBack,
                customBorder: const CircleBorder(),
                child: Semantics(
                  label: context.strings.back,
                  button: true,
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Icon(
                      context.isArabic
                          ? Icons.chevron_right_rounded
                          : Icons.chevron_left_rounded,
                      size: 30,
                      textDirection: TextDirection.ltr,
                      color: AppColors.black1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
