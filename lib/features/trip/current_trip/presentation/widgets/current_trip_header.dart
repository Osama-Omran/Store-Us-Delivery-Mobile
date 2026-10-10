import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

class CurrentTripHeader extends StatelessWidget {
  const CurrentTripHeader({super.key, required this.tripNumber, this.onMapPressed});
  final VoidCallback? onMapPressed;
  final String tripNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.grey0,
        border: Border(bottom: BorderSide(color: AppColors.grey3)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.strings.my_current_trip,
                style: TextStyle(
                  color: AppColors.black1,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${context.strings.trip_label} \u2066#$tripNumber\u2069',
                style: TextStyle(fontSize: 13, color: AppColors.grey4),
              ),
            ],
          ),

          if (onMapPressed != null)
            PositionedDirectional(
              end: 22,
              child: Material(
                color: AppColors.white0,
                shape: CircleBorder(
                  side: BorderSide(
                    color: AppColors.grey3,
                  ),
                ),
                child: InkWell(
                  onTap: onMapPressed,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 27,
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
