import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_cubit.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_history_cubit.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_state.dart';
import 'package:storeus_delivery/features/home/presentation/widgets/home_previous_trips_section.dart';

import '../widgets/home_current_trip_card.dart';
import '../widgets/home_header.dart';
import '../widgets/home_message.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(
          create: (_) => getIt<HomeCubit>()..getCurrentTrip(),
        ),
        BlocProvider<HomeHistoryCubit>(
          create: (_) => getIt<HomeHistoryCubit>()..getTripHistory(),
        ),
      ],
      child: const _HomeScreenBody(),
    );
  }
}

class _HomeScreenBody extends StatelessWidget {
  const _HomeScreenBody();

  String? _getTripBadge(BuildContext context, HomeState state) {
    if (state is! HomeSuccessState) return null;

    final status = state.trip.acceptance?.status.trim().toUpperCase();

    return switch (status) {
      'ACCEPTED' => context.strings.currently_on_trip,
      'PENDING' => context.strings.trip_acceptance_pending,
      null || '' => null,
      final value => value,
    };
  }

  @override
  Widget build(BuildContext context) {
    final userName = PreferencesHelper.getUserName()?.trim() ?? '';

    return Scaffold(
      backgroundColor: AppColors.grey0,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
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
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 124),
                children: [
                  // ======= Original Header ======= //
                  HomeHeader(
                    userName: userName,
                    tripBadge: _getTripBadge(context, state),
                  ),

                  const Gap(24),

                  // ======= Loading ======= //
                  if (state is HomeInitial || state is HomeLoadingState)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 80),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  // ======= Failure ======= //
                  else if (state is HomeFailureState)
                    HomeMessage(
                      message: state.errorMessage?.isNotEmpty == true
                          ? state.errorMessage!
                          : context.strings.current_trip_load_failed,
                      onRetry: () => HomeCubit.get(context).getCurrentTrip(),
                    )
                  // ======= No Current Trip ======= //
                  else if (state is HomeEmptyState)
                    HomeMessage(
                      message: context.strings.home_no_current_trip,
                      onRetry: () => HomeCubit.get(context).getCurrentTrip(),
                    )
                  // ======= Current Trip ======= //
                  else if (state is HomeSuccessState)
                    HomeCurrentTripCard(
                      state: state,
                      onRetryOrders: () =>
                          HomeCubit.get(context).getTripOrders(),
                    ),

                  const Gap(24),

                  HomePreviousTripsSection(
                    currentTripId: state is HomeSuccessState
                        ? state.trip.id
                        : null,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
