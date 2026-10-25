import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';

import 'package:storeus_delivery/core/theme/app_colors.dart';

class DeliveryFlowHeader extends StatelessWidget {
  const DeliveryFlowHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.grey0,
        border: Border(bottom: BorderSide(color: AppColors.grey3)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.black1,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: AppColors.grey4, fontSize: 13),
              ),
            ],
          ),
          PositionedDirectional(
            start: 20,
            child: Material(
              color: AppColors.white0,
              shape: CircleBorder(side: BorderSide(color: AppColors.grey3)),
              child: InkWell(
                onTap: () => context.pop(),
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Icon(
                    context.isArabic
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    size: 30,
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
