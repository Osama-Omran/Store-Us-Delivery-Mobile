import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import '../utils/trip_order_navigation.dart';

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
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: InkWell(
        onTap: isPhone ? () => callOrderCustomer(context, text) : null,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 16,
              color: isPhone ? AppColors.primary : AppColors.grey4,
            ),

            const SizedBox(width: 5),

            Expanded(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textDirection: isPhone ? TextDirection.ltr : null,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.25,
                  color: isPhone ? AppColors.primary : AppColors.grey4,
                  fontWeight: isPhone ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
