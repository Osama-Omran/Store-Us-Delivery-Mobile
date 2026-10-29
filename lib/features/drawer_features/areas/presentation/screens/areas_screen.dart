import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/drawer_features/areas/presentation/widgets/areas_body.dart';
import 'package:storeus_delivery/features/trip/trip_map/services/route_navigation_launcher.dart';

class AreasScreen extends StatelessWidget {
  const AreasScreen({
    super.key,
    required this.onBack,
    this.navigationLauncher = const RouteNavigationLauncher(),
  });

  final VoidCallback onBack;
  final RouteNavigationLauncher navigationLauncher;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ColoredBox(
        color: AppColors.grey0,
        child: Padding(
          // Bottom navigation is managed by the parent layout.
          padding: const EdgeInsets.only(bottom: 100),
          child: AreasBody(
            onBack: onBack,
            navigationLauncher: navigationLauncher,
          ),
        ),
      ),
    );
  }
}
