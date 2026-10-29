import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_cubit.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_history_cubit.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_state.dart';
import 'package:storeus_delivery/features/home/presentation/widgets/home_current_trip_section.dart';
import 'package:storeus_delivery/features/home/presentation/widgets/home_header.dart';
import 'package:storeus_delivery/features/home/presentation/widgets/home_previous_trips_section.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await Future.wait<void>([
          HomeCubit.get(context).getCurrentTrip(),
          HomeHistoryCubit.get(context).getTripHistory(),
        ]);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 124),
        children: [
          const HomeHeader(),
          const SizedBox(height: 24),
          const HomeCurrentTripSection(),
          const SizedBox(height: 26),
          BlocSelector<HomeCubit, HomeState, int?>(
            selector: (state) =>
                state is HomeSuccessState ? state.trip.id : null,
            builder: (context, currentTripId) =>
                HomePreviousTripsSection(currentTripId: currentTripId),
          ),
        ],
      ),
    );
  }
}
