import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class DeliveryOrderHeader extends StatelessWidget {
  const DeliveryOrderHeader({super.key, this.salesOrder});

  final String? salesOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 90),
      padding: const EdgeInsets.symmetric(vertical: 14),
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
                  context.strings.delivery_order_title,
                  textAlign: TextAlign.center,
                  style: Styles.textStyle23.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.black1,
                  ),
                ),
                Text(
                  salesOrder ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  style: Styles.textStyle13.copyWith(color: AppColors.grey4),
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
                  onTap: () => context.pop(),
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
