import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import '../utils/trip_order_navigation.dart';

import 'package:storeus_delivery/core/theme/text_styles.dart';

class TripOrderContactLine extends StatelessWidget {
  const TripOrderContactLine({
    super.key,
    required this.icon,
    required this.text,
    this.isPhone = false,
  });

  final IconData icon;
  final String text;
  final bool isPhone;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: isPhone ? () => callOrderCustomer(context, text) : null,
        borderRadius: BorderRadius.circular(9),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: isPhone ? 48 : 24),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: isPhone ? 8 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isPhone ? AppColors.blue4 : AppColors.white0,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(
                    icon,
                    size: 15,
                    color: isPhone ? AppColors.primary : AppColors.grey4,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: isPhone ? TextDirection.ltr : null,
                      textAlign: TextAlign.start,
                      style: Styles.textStyle12.copyWith(
                        height: 1.35,
                        color: isPhone ? AppColors.primary : AppColors.grey4,
                        fontWeight: isPhone ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
