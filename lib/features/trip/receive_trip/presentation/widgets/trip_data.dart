import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/receive_trip_cubit.dart';
import '../cubit/receive_trip_state.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/custom_trip_container.dart';

class TripData extends StatelessWidget {
  const TripData({super.key});

  // ======= Name Or ID ======= //
  String _nameOrId(String? name, String? id) {
    if (name != null && name.trim().isNotEmpty) {
      return name;
    }

    if (id != null && id.trim().isNotEmpty) {
      return id;
    }

    return '—';
  }

  // ======= Trip Status ======= //
  String _getTripStatus(BuildContext context, CurrentTripData trip) {
    final status = trip.status.trim().toUpperCase();

    return switch (status) {
      'SHIPPED' => context.strings.trip_status_shipped,
      'COMPLETED' => context.strings.home_history_completed,
      'CANCELLED' || 'CANCELED' => context.strings.reports_status_cancelled,
      '' => context.strings.trip_tab_unknown_status,
      _ => context.strings.trip_tab_unknown_status,
    };
  }

  // ======= Acceptance Status ======= //
  String _getAcceptanceStatus(BuildContext context, CurrentTripData trip) {
    final status = trip.acceptance?.status.trim().toUpperCase();

    return switch (status) {
      'PENDING' => context.strings.trip_acceptance_pending,
      'ACCEPTED' => context.strings.trip_tab_accepted,
      'OVERRIDDEN' => context.strings.trip_acceptance_admin_override,
      null || '' => context.strings.trip_tab_unknown_status,
      _ => context.strings.trip_tab_unknown_status,
    };
  }

  // ======= Accepted Date & Time ======= //
  String _formatAcceptedAt(BuildContext context, DateTime date) {
    final localDate = date.toLocal();

    final localization = MaterialLocalizations.of(context);

    final formattedDate = localization.formatMediumDate(localDate);

    final formattedTime = localization.formatTimeOfDay(
      TimeOfDay.fromDateTime(localDate),
      alwaysUse24HourFormat: false,
    );

    return '$formattedDate - $formattedTime';
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ReceiveTripCubit, ReceiveTripState>(
        builder: (context, state) {
          if (state is! ReceiveTripSuccessState) return const SizedBox.shrink();
          final trip = state.trip;
          final acceptedAt = trip.acceptance?.acceptedAt;

          return CustomTripContainer(
            child: Column(
              spacing: 12,
              children: [
                // ======= Trip Number ======= //
                TripDataItem(
                  title: context.strings.trip_number,
                  value: trip.number,
                ),

                // ======= Trip Status ======= //
                TripDataItem(
                  title: context.strings.trip_status,
                  value: _getTripStatus(context, trip),
                ),

                // ======= Warehouse ======= //
                TripDataItem(
                  title: context.strings.warehouse,
                  value: _nameOrId(trip.warehouse?.name, trip.warehouse?.id),
                ),

                // ======= Vehicle ======= //
                TripDataItem(
                  title: context.strings.van,
                  value: _nameOrId(trip.vehicle?.name, trip.vehicle?.id),
                ),

                // ======= Driver ======= //
                TripDataItem(
                  title: context.strings.driver,
                  value: _nameOrId(trip.driver?.name, trip.driver?.id),
                ),

                // ======= Total Orders ======= //
                TripDataItem(
                  title: context.strings.trip_total_orders,
                  value: trip.ordersSummary?.total.toString() ?? '—',
                ),

                // ======= Acceptance Status ======= //
                TripDataItem(
                  title: context.strings.trip_acceptance_status,
                  value: _getAcceptanceStatus(context, trip),
                ),

                // ======= Accepted At ======= //
                if (acceptedAt != null)
                  TripDataItem(
                    title: context.strings.trip_accepted_at,
                    value: _formatAcceptedAt(context, acceptedAt),
                  ),
              ],
            ),
          );
        },
      );
}

// =====================================================
// Trip Data Item
// =====================================================

class TripDataItem extends StatelessWidget {
  const TripDataItem({super.key, required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: Styles.textStyle14.copyWith(color: AppColors.grey4),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            softWrap: true,
            style: Styles.textStyle14.copyWith(
              color: AppColors.black0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
