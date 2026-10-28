import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/core/widgets/custom_loading_indicator.dart';
import 'package:storeus_delivery/features/home/data/models/trip_history_response.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_history_cubit.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_history_state.dart';

class HomePreviousTripsSection extends StatelessWidget {
  const HomePreviousTripsSection({super.key, this.currentTripId});

  final int? currentTripId;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.blue4,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.history_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.strings.previous_today_trips,
                  style: Styles.textStyle18.copyWith(
                    color: AppColors.black1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          BlocBuilder<HomeHistoryCubit, HomeHistoryState>(
            builder: (context, state) {
              if (state is HomeHistoryInitial ||
                  state is HomeHistoryLoadingState) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white0,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.grey3),
                  ),
                  child: const Center(
                    child: CustomLoadingIndicator(size: 72, primaryColor: true),
                  ),
                );
              }

              if (state is HomeHistoryFailureState) {
                return _HistoryMessage(
                  message: state.errorMessage?.isNotEmpty == true
                      ? state.errorMessage!
                      : context.strings.home_history_load_failed,
                  onRetry: () => HomeHistoryCubit.get(context).getTripHistory(),
                );
              }

              if (state is HomeHistorySuccessState) {
                final today = DateTime.now();
                final trips = state.trips.where((trip) {
                  if (trip.id == currentTripId) return false;
                  if (!trip.isPreviousTrip) return false;
                  return trip.isOnDate(today);
                }).toList()..sort((a, b) => b.id.compareTo(a.id));

                if (trips.isEmpty) {
                  return _HistoryMessage(
                    message: context.strings.home_history_empty_today,
                  );
                }

                return Column(
                  spacing: 10,
                  children: [
                    for (final trip in trips)
                      _PreviousTripCard(key: ValueKey(trip.id), trip: trip),
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

class _PreviousTripCard extends StatelessWidget {
  const _PreviousTripCard({super.key, required this.trip});

  final TripHistoryItem trip;

  @override
  Widget build(BuildContext context) {
    final isCompleted = trip.normalizedStatus == 'COMPLETED';
    final statusColor = isCompleted ? AppColors.green0 : AppColors.red1;
    final statusText = isCompleted
        ? context.strings.home_history_completed
        : context.strings.home_history_cancelled;
    final completedAt = trip.completedAt?.toLocal();
    final completedTime = completedAt == null
        ? null
        : MaterialLocalizations.of(context)
              .formatTimeOfDay(TimeOfDay.fromDateTime(completedAt));
    final statusBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        statusText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Styles.textStyle12.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey3),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth < 300 ||
              MediaQuery.textScalerOf(context).scale(16) > 20;

          return Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle_outline_rounded
                      : Icons.cancel_outlined,
                  color: statusColor,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.strings.trip_number_title(trip.number),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Styles.textStyle16.copyWith(
                        color: AppColors.black1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      trip.totalOrders == null
                          ? context.strings.orders_count_unavailable
                          : context.strings.orders_count(trip.totalOrders!),
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.grey4,
                      ),
                    ),
                    if (completedTime != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        context.strings.trip_completed_at_time(completedTime),
                        style: Styles.textStyle12.copyWith(
                          color: AppColors.grey4,
                        ),
                      ),
                    ],
                    if (compact) ...[const SizedBox(height: 10), statusBadge],
                  ],
                ),
              ),
              if (!compact) ...[const SizedBox(width: 7), statusBadge],
            ],
          );
        },
      ),
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        children: [
          Icon(Icons.history_rounded, color: AppColors.primary, size: 32),
          const SizedBox(height: 10),
          Text(
            context.localizedErrorMessage(message),
            textAlign: TextAlign.center,
            style: Styles.textStyle14.copyWith(color: AppColors.grey4),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.strings.current_trip_retry),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.blue3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
