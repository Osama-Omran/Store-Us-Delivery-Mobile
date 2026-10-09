import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/custom_trip_container.dart';

class TripData extends StatelessWidget {
  const TripData({super.key, required this.trip});

  final CurrentTripData trip;

  String _nameOrId(String? name, String? id) {
    if (name != null && name.trim().isNotEmpty) return name;
    if (id != null && id.trim().isNotEmpty) return id;
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    return CustomTripContainer(
      child: Column(
        spacing: 12,
        children: [
          TripDataItem(
            title: context.strings.trip_number,
            value: trip.number,
          ),
          TripDataItem(
            title: context.strings.trip_status,
            value: trip.status == 'SHIPPED'
                ? context.strings.trip_status_shipped
                : trip.status,
          ),
          TripDataItem(
            title: context.strings.warehouse,
            value: _nameOrId(trip.warehouse?.name, trip.warehouse?.id),
          ),
          TripDataItem(
            title: context.strings.van,
            value: _nameOrId(trip.vehicle?.name, trip.vehicle?.id),
          ),
          TripDataItem(
            title: context.strings.driver,
            value: _nameOrId(trip.driver?.name, trip.driver?.id),
          ),
          TripDataItem(
            title: context.strings.trip_total_orders,
            value: trip.ordersSummary?.total.toString() ?? '—',
          ),
          TripDataItem(
            title: context.strings.trip_acceptance_status,
            value: trip.acceptance?.status == 'PENDING'
                ? context.strings.trip_acceptance_pending
                : (trip.acceptance?.status ?? '—'),
          ),
          if (trip.acceptance?.acceptedAt != null)
            TripDataItem(
              title: context.strings.trip_accepted_at,
              value: MaterialLocalizations.of(context).formatMediumDate(
                trip.acceptance!.acceptedAt!.toLocal(),
              ),
            ),
        ],
      ),
    );
  }
}

class TripDataItem extends StatelessWidget {
  const TripDataItem({
    super.key,
    required this.title,
    required this.value,
  });

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
          child: Text(title, style: Styles.textStyle14),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
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
