import 'package:flutter/material.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class OrderDetailsHeader extends StatelessWidget {
  const OrderDetailsHeader({super.key, this.subtitle, required this.onBack});

  final String? subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 90),
      padding: const EdgeInsets.symmetric(vertical: 14),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.grey0,
        border: Border(bottom: BorderSide(color: AppColors.grey3)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 76),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Text(
                  context.strings.order_details_title,
                  textAlign: TextAlign.center,
                  style: Styles.textStyle24.copyWith(color: AppColors.black1),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Styles.textStyle12.copyWith(color: AppColors.grey4),
                  ),
              ],
            ),
          ),

          PositionedDirectional(
            start: 20,
            child: Material(
              color: AppColors.white0,
              shape: CircleBorder(side: BorderSide(color: AppColors.grey3)),
              child: Tooltip(
                message: MaterialLocalizations.of(context).backButtonTooltip,
                child: InkWell(
                  onTap: onBack,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: const BackButtonIcon(),
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
