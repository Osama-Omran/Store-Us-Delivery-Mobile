import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

Future<bool?> showTripReceivingConfirmationSheet({
  required BuildContext context,
  required String tripNumber,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: false,
    showDragHandle: false,
    backgroundColor: AppColors.white0,
    barrierColor: AppColors.black0.withValues(alpha: 0.40),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) {
      return TripReceivingConfirmationSheet(tripNumber: tripNumber);
    },
  );
}

class TripReceivingConfirmationSheet extends StatelessWidget {
  const TripReceivingConfirmationSheet({super.key, required this.tripNumber});

  final String tripNumber;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.strings.confirm_receiving_dialog_title,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.black1,
              ),
            ),
            const Gap(12),
            Text(
              '${context.strings.confirm_receiving_dialog_description} '
              '\u2066$tripNumber\u2069.',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: AppColors.grey4,
              ),
            ),
            const Gap(24),
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 70,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.white0,
                        foregroundColor: AppColors.black1,
                        side: BorderSide(color: AppColors.grey3, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        context.strings.back,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 70,
                    child: ElevatedButton(
                      onPressed: () {
                        GoRouter.of(context).pop();
                        GoRouter.of(context)
                            .pushReplacement(RoutesNames.receiveTripSuccess);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green0,
                        foregroundColor: AppColors.white0,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        context.strings.yes_confirm_receiving,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
