import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/receiving_success_header.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/receiving_success_details.dart';

class ReceiveTripSuccessScreen extends StatelessWidget {
  const ReceiveTripSuccessScreen({
    super.key,
    required this.tripNumber,
    required this.receivedAt,
  });

  final String tripNumber;
  final DateTime receivedAt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey0,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Gap(110),
                      const ReceivingSuccessHeader(),
                      const Gap(30),
                      ReceivingSuccessDetails(
                        tripNumber: tripNumber,
                        receivedAt: receivedAt,
                      ),
                      const Gap(40),
                      SizedBox(
                        width: double.infinity,
                        height: 70,
                        child: ElevatedButton(
                          onPressed: () => GoRouter.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white0,
                            elevation: 5,
                            shadowColor: AppColors.primary.withValues(
                              alpha: 0.25,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            context.strings.show_trip_orders,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const Gap(24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
