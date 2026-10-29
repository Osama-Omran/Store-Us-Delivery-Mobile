import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_state.dart';

class AreasHeader extends StatelessWidget {
  const AreasHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  tooltip: context.strings.back,
                  icon: const BackButtonIcon(),
                ),
                Expanded(
                  child: Text(
                    context.strings.areas_title,
                    textAlign: TextAlign.center,
                    style: Styles.textStyle21.copyWith(
                      color: AppColors.black1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                BlocBuilder<TripTabCubit, TripTabState>(
                  buildWhen: (previous, current) =>
                      _loading(previous) != _loading(current),
                  builder: (context, state) => IconButton(
                    onPressed: _loading(state)
                        ? null
                        : () => context.read<TripTabCubit>().getCurrentTrip(),
                    tooltip: context.strings.areas_refresh,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ),
              ],
            ),
            Text(
              context.strings.areas_distribution_order,
              textAlign: TextAlign.center,
              style: Styles.textStyle12.copyWith(color: AppColors.grey4),
            ),
          ],
        ),
      ),
    );
  }

  bool _loading(TripTabState state) =>
      state is TripTabInitial ||
      state is TripTabLoadingState ||
      (state is TripTabSuccessState &&
          state.trip.acceptance?.isOperationallyAccepted == true &&
          (state.ordersStatus == TripOrdersStatus.initial ||
              state.ordersStatus == TripOrdersStatus.loading));
}
