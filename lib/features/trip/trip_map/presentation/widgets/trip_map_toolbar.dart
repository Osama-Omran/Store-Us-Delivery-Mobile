import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class TripMapToolbar extends StatelessWidget {
  const TripMapToolbar({
    super.key,
    required this.tripId,
    required this.onBack,
    required this.onRefreshLocation,
    required this.isRefreshing,
  });

  final String tripId;
  final VoidCallback onBack;
  final VoidCallback onRefreshLocation;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Row(
            children: [
              Material(
                color: AppColors.white0,
                shape: const CircleBorder(),
                elevation: 3,
                child: IconButton(
                  icon: const BackButtonIcon(),
                  color: AppColors.black1,
                  iconSize: 30,
                  onPressed: onBack,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white0,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black0.withValues(alpha: .12),
                          blurRadius: 9,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      context.strings.trip_map_number_title(
                        '\u2066#$tripId\u2069',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Styles.textStyle15.copyWith(
                        color: AppColors.black1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              Material(
                color: AppColors.white0,
                shape: const CircleBorder(),
                elevation: 3,
                child: IconButton(
                  icon: isRefreshing
                      ? SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(
                          Icons.my_location_rounded,
                          color: AppColors.primary,
                        ),
                  onPressed: isRefreshing ? null : onRefreshLocation,
                  tooltip: context.strings.trip_map_refresh_location,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
