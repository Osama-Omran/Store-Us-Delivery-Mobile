import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import '../cubit/direct_sale_cubit.dart';
import '../cubit/direct_sale_state.dart';
import 'direct_sale_card.dart';

class DirectSaleLocationCard extends StatelessWidget {
  const DirectSaleLocationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<DirectSaleCubit>();
    final state = cubit.state;
    final position = state.position;
    final error = switch (state.locationError) {
      DirectSaleLocationError.disabled =>
        context.strings.direct_sale_location_disabled,
      DirectSaleLocationError.denied =>
        context.strings.direct_sale_location_denied,
      DirectSaleLocationError.failed =>
        context.strings.direct_sale_location_failed,
      null => null,
    };
    return DirectSaleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          FilledButton(
            onPressed: state.locating ? null : cubit.captureLocation,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.blue4,
              foregroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(52),
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.locating)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.location_on_outlined),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    context.strings.direct_sale_current_location,
                    textAlign: TextAlign.center,
                    style: Styles.textStyle16,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  context.strings.direct_sale_optional,
                  style: Styles.textStyle12.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          if (position != null)
            Row(
              spacing: 8,
              children: [
                _LocationValue(
                  label: context.strings.direct_sale_accuracy,
                  value: context.strings.location_accuracy_meters(
                    position.accuracy.toStringAsFixed(0),
                  ),
                ),
                _LocationValue(
                  label: context.strings.order_longitude,
                  value: position.longitude.toStringAsFixed(5),
                ),
                _LocationValue(
                  label: context.strings.order_latitude,
                  value: position.latitude.toStringAsFixed(5),
                ),
              ],
            ),
          if (error != null)
            Text(
              error,
              style: Styles.textStyle14.copyWith(color: AppColors.red1),
            ),
        ],
      ),
    );
  }
}

class _LocationValue extends StatelessWidget {
  const _LocationValue({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.grey5,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        spacing: 4,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: Styles.textStyle12.copyWith(color: AppColors.grey4),
          ),
          Text(
            value,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: Styles.textStyle12.copyWith(color: AppColors.black1),
          ),
        ],
      ),
    ),
  );
}
