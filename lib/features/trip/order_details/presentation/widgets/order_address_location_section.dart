import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_customer_location.dart';

import 'order_address_review.dart';

class OrderAddressLocationSection extends StatelessWidget {
  const OrderAddressLocationSection({
    super.key,
    required this.location,
    required this.position,
    required this.latitudeText,
    required this.longitudeText,
    required this.accuracy,
    required this.locating,
    required this.onUseCurrentLocation,
    required this.onMapTap,
  });

  final OrderCustomerLocation location;
  final LatLng? position;
  final String latitudeText;
  final String longitudeText;
  final double? accuracy;
  final bool locating;
  final VoidCallback onUseCurrentLocation;
  final ValueChanged<LatLng> onMapTap;

  @override
  Widget build(BuildContext context) {
    final position = this.position;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ======= Existing Data ======= //
        OrderAddressPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.strings.order_current_saved_data,
                style: Styles.textStyle14.copyWith(color: AppColors.grey4),
              ),
              const SizedBox(height: 6),
              Text(
                location.hasAddress
                    ? location.address
                    : context.strings.order_no_address,
                style: Styles.textStyle16.copyWith(
                  color: AppColors.black1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                location.hasCoordinates
                    ? '${location.latitude}, '
                          '${location.longitude}'
                    : context.strings.order_customer_gps_missing,
                style: Styles.textStyle12.copyWith(color: AppColors.grey4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        SizedBox(
          height: 62,
          child: ElevatedButton.icon(
            onPressed: locating ? null : onUseCurrentLocation,
            icon: locating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded),
            label: Text(
              position != null
                  ? context.strings.order_reselect_location
                  : context.strings.order_use_current_location,
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.blue4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ======= Real Map Preview ======= //
        if (position != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              height: 180,
              child: GoogleMap(
                key: ValueKey('${position.latitude}_${position.longitude}'),
                initialCameraPosition: CameraPosition(
                  target: position,
                  zoom: 16,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('customer_location'),
                    position: position,
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                onTap: onMapTap,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _CoordinateValue(
                  label: context.strings.order_latitude,
                  value: latitudeText,
                ),
              ),
              Expanded(
                child: _CoordinateValue(
                  label: context.strings.order_longitude,
                  value: longitudeText,
                ),
              ),
            ],
          ),

          if (accuracy != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                '${context.strings.order_location_accuracy} '
                '±${accuracy!.toStringAsFixed(0)} '
                '${context.strings.order_meters}',
                style: Styles.textStyle12.copyWith(color: AppColors.orange0),
              ),
            ),

          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _CoordinateValue extends StatelessWidget {
  const _CoordinateValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Styles.textStyle12),
        const SizedBox(height: 4),
        Text(
          value,
          textDirection: TextDirection.ltr,
          style: Styles.textStyle14.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
