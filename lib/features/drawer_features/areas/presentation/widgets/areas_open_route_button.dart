import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/models/areas_route_data.dart';

class AreasOpenRouteButton extends StatelessWidget {
  const AreasOpenRouteButton({
    super.key,
    required this.route,
    required this.isOpening,
    required this.onPressed,
  });

  final AreasRouteData route;
  final bool isOpening;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (route.warehouseLocation == null) ...[
            Text(
              context.strings.areas_route_origin_unavailable,
              style: Styles.textStyle12.copyWith(color: AppColors.grey4),
            ),
            const SizedBox(height: 10),
          ],
          OutlinedButton.icon(
            onPressed: isOpening ? null : onPressed,
            icon: const Icon(Icons.map_outlined),
            label: Text(context.strings.areas_open_google_maps),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.blue2,
              minimumSize: const Size.fromHeight(56),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
