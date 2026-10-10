
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

class DeliveryOrderHeader extends StatelessWidget {
  const DeliveryOrderHeader({
    super.key,
    this.salesOrder,
  });

  final String? salesOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.grey0,
        border: Border(
          bottom: BorderSide(color: AppColors.grey3),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Text(
                context.strings.delivery_order_title,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black1,
                ),
              ),
              Text(
                salesOrder ?? '—',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.grey4,
                ),
              ),
            ],
          ),

          PositionedDirectional(
            start: 20,
            child: Material(
              color: AppColors.white0,
              shape: CircleBorder(
                side: BorderSide(color: AppColors.grey3),
              ),
              child: InkWell(
                onTap: () => context.pop(),
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 50,
                  height: 50,
                  child: Icon(
                    Icons.chevron_right_rounded,
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
