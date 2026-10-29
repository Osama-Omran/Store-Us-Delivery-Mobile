import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_cubit.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_state.dart';
import 'package:storeus_delivery/features/home/presentation/widgets/home_current_trip_card.dart';
import 'package:storeus_delivery/features/home/presentation/widgets/home_message.dart';
import 'package:storeus_delivery/features/home/presentation/widgets/home_shimmer.dart';

class HomeCurrentTripSection extends StatelessWidget {
  const HomeCurrentTripSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) {
        if (previous is HomeSuccessState && current is HomeSuccessState) {
          return previous.trip != current.trip;
        }
        return true;
      },
      builder: (context, state) {
        if (state is HomeInitial || state is HomeLoadingState) {
          return const HomeCurrentTripShimmer();
        }
        if (state is HomeFailureState) {
          return HomeMessage(
            message: state.errorMessage?.isNotEmpty == true
                ? state.errorMessage!
                : context.strings.current_trip_load_failed,
            onRetry: () => HomeCubit.get(context).getCurrentTrip(),
          );
        }
        if (state is HomeEmptyState) {
          return HomeMessage(
            message: context.strings.home_no_current_trip,
            onRetry: () => HomeCubit.get(context).getCurrentTrip(),
          );
        }
        return HomeCurrentTripCard();
      },
    );
  }
}
