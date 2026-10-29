import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/widgets/current_trip_body.dart';

class CurrentTripScreen extends StatelessWidget {
  const CurrentTripScreen({super.key});

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.grey0,
      body: const CurrentTripBody(),
    ),
  );
}
