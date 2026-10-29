import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_state.dart';

class AreasStateMessage extends StatelessWidget {
  const AreasStateMessage({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TripTabCubit>().state;
    String message;
    if (state is TripTabEmptyState) {
      message = context.strings.trip_tab_no_trip;
    } else if (state is TripTabFailureState) {
      message = context.localizedErrorMessage(
        state.errorMessage,
        fallback: context.strings.areas_load_failed,
      );
    } else if (state is TripTabSuccessState) {
      message = state.trip.acceptance?.isOperationallyAccepted != true
          ? context.strings.you_must_confirm_receiving_van_and_goods_first
          : context.localizedErrorMessage(
              state.ordersError,
              fallback: context.strings.areas_load_failed,
            );
    } else {
      message = context.strings.areas_load_failed;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.route_outlined, size: 48, color: AppColors.grey4),
            const SizedBox(height: 16),
            Text(
              this.message ?? message,
              textAlign: TextAlign.center,
              style: Styles.textStyle15.copyWith(color: AppColors.black1),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.read<TripTabCubit>().getCurrentTrip(),
              child: Text(context.strings.current_trip_retry),
            ),
          ],
        ),
      ),
    );
  }
}
