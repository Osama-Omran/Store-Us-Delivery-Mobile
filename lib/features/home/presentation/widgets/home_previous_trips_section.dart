
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import 'package:storeus_delivery/features/home/data/models/trip_history_response.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_history_cubit.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_history_state.dart';

class HomePreviousTripsSection extends StatelessWidget {
  const HomePreviousTripsSection({
    super.key,
    this.currentTripId,
  });

  final int? currentTripId;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          // ======= Section Title ======= //
          Text(
            context.strings.previous_today_trips,
            style: Styles.textStyle18.copyWith(
              color: AppColors.black1,
              fontWeight: FontWeight.w800,
            ),
          ),

          BlocBuilder<HomeHistoryCubit, HomeHistoryState>(
            builder: (context, state) {
              // ======= Loading ======= //
              if (state is HomeHistoryInitial ||
                  state is HomeHistoryLoadingState) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 22),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // ======= Failure ======= //
              if (state is HomeHistoryFailureState) {
                return _HistoryMessage(
                  message: state.errorMessage?.isNotEmpty == true
                      ? state.errorMessage!
                      : context.strings.home_history_load_failed,
                  onRetry: () {
                    HomeHistoryCubit.get(context)
                        .getTripHistory();
                  },
                );
              }

              if (state is HomeHistorySuccessState) {
                final today = DateTime.now();

                final trips = state.trips.where((trip) {
                  // Never show the current trip here.
                  if (trip.id == currentTripId) {
                    return false;
                  }

                  // Only completed or cancelled past trips.
                  if (!trip.isPreviousTrip) {
                    return false;
                  }

                  // Only trips with today's trip_date.
                  return trip.isOnDate(today);
                }).toList()
                  ..sort(
                        (a, b) => b.id.compareTo(a.id),
                  );

                // ======= Empty Today ======= //
                if (trips.isEmpty) {
                  return _HistoryMessage(
                    message: context.strings
                        .home_history_empty_today,
                  );
                }

                // ======= Trip Cards ======= //
                return Column(
                  spacing: 12,
                  children: [
                    for (final trip in trips)
                      _PreviousTripCard(
                        key: ValueKey(trip.id),
                        trip: trip,
                      ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

// =====================================================
// Previous Trip Card
// =====================================================

class _PreviousTripCard extends StatelessWidget {
  const _PreviousTripCard({
    super.key,
    required this.trip,
  });

  final TripHistoryItem trip;

  @override
  Widget build(BuildContext context) {
    final isCompleted =
        trip.normalizedStatus == 'COMPLETED';

    final statusColor = isCompleted
        ? AppColors.green0
        : AppColors.red1;

    final statusText = isCompleted
        ? context.strings.home_history_completed
        : context.strings.home_history_cancelled;

    final completedAt = trip.completedAt?.toLocal();

    final completedTime = completedAt == null
        ? null
        : MaterialLocalizations.of(context)
        .formatTimeOfDay(
      TimeOfDay.fromDateTime(completedAt),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.grey3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black0.withValues(alpha: .035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 12,
        children: [
          // ======= Trip Information ======= //
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(
                  '${context.strings.trip_label} ${trip.number}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.black1,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      '${trip.totalOrders?.toString() ?? '—'} '
                          '${context.strings.orders_plural}',
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.grey4,
                      ),
                    ),

                    if (completedTime != null)
                      Text(
                        '— ${context.strings.completed_at} '
                            '$completedTime',
                        style: Styles.textStyle12.copyWith(
                          color: AppColors.grey4,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ======= Trip Status ======= //
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 5,
            children: [
              Icon(
                isCompleted
                    ? Icons.check_circle_outline_rounded
                    : Icons.cancel_outlined,
                size: 19,
                color: statusColor,
              ),
              Text(
                statusText,
                style: Styles.textStyle12.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================
// Empty / Failure
// =====================================================

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.grey3,
        ),
      ),
      child: Column(
        spacing: 12,
        children: [
          Icon(
            Icons.history_rounded,
            color: AppColors.grey4,
            size: 35,
          ),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Styles.textStyle14.copyWith(
              color: AppColors.grey4,
            ),
          ),
          if (onRetry != null)
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                context.strings.current_trip_retry,
              ),
            ),
        ],
      ),
    );
  }
}
