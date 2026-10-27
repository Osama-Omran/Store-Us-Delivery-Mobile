import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/custom_loading_indicator.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_cubit.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_history_cubit.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_state.dart';
import 'package:storeus_delivery/features/home/presentation/widgets/home_current_trip_card.dart';
import 'package:storeus_delivery/features/home/presentation/widgets/home_header.dart';
import 'package:storeus_delivery/features/home/presentation/widgets/home_message.dart';
import 'package:storeus_delivery/features/home/presentation/widgets/home_previous_trips_section.dart';

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
      'OVERRIDDEN' => context.strings.trip_acceptance_admin_override,
      null || '' => null,
      _ => context.strings.trip_tab_unknown_status,
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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 124),
                children: [
                  HomeHeader(
                    userName: userName,
                    tripBadge: _getTripBadge(context, state),
                  ),
                  const SizedBox(height: 24),
                  if (state is HomeInitial || state is HomeLoadingState)
                    Container(
                      height: 190,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.white0,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.grey3),
                      ),
                      child: const CustomLoadingIndicator(
                        size: 96,
                        primaryColor: true,
                      ),
                    )
                  else if (state is HomeFailureState)
                    HomeMessage(
                      message: state.errorMessage?.isNotEmpty == true
                          ? state.errorMessage!
                          : context.strings.current_trip_load_failed,
                      onRetry: () => HomeCubit.get(context).getCurrentTrip(),
                    )
                  else if (state is HomeEmptyState)
                    HomeMessage(
                      message: context.strings.home_no_current_trip,
                      onRetry: () => HomeCubit.get(context).getCurrentTrip(),
                    )
                  else if (state is HomeSuccessState)
                    HomeCurrentTripCard(
                      state: state,
                      onRetryOrders: () =>
                          HomeCubit.get(context).getTripOrders(),
                    ),
                  const SizedBox(height: 26),
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
