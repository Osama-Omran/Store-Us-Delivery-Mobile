import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class OrderAddressReview extends StatelessWidget {
  const OrderAddressReview({
    super.key,
    required this.address,
    required this.phone,
    required this.city,
    required this.country,
    required this.notes,
    required this.latitudeText,
    required this.longitudeText,
    required this.accuracy,
  });

  final String address;
  final String phone;
  final String city;
  final String country;
  final String notes;
  final String latitudeText;
  final String longitudeText;
  final double? accuracy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OrderAddressPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.strings.order_confirm_data_before_save,
                style: Styles.textStyle14.copyWith(
                  color: AppColors.grey4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              _ReviewRow(
                title: context.strings.order_correct_address,
                value: address,
              ),
              _ReviewRow(title: 'Latitude', value: latitudeText),
              _ReviewRow(title: 'Longitude', value: longitudeText),
              if (accuracy != null)
                _ReviewRow(
                  title: context.strings.order_location_accuracy,
                  value:
                      '±${accuracy!.toStringAsFixed(0)} '
                      '${context.strings.order_meters}',
                ),

              _ReviewRow(
                title: context.strings.order_delivery_phone,
                value: phone.isEmpty ? '—' : phone,
              ),

              _ReviewRow(
                title: context.strings.order_delivery_city,
                value: city.isEmpty ? '—' : city,
              ),

              _ReviewRow(
                title: context.strings.order_delivery_country,
                value: country.isEmpty ? '—' : country,
              ),

              if (notes.isNotEmpty)
                _ReviewRow(
                  title: context.strings.order_optional_notes,
                  value: notes,
                ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Text(
          context.strings.order_confirm_location_warning,
          textAlign: TextAlign.center,
          style: Styles.textStyle14.copyWith(color: AppColors.grey4),
        ),
      ],
    );
  }
}

class OrderAddressPanel extends StatelessWidget {
  const OrderAddressPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.grey5,
      borderRadius: BorderRadius.circular(24),
    ),
    child: child,
  );
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: Styles.textStyle14.copyWith(color: AppColors.grey4),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Styles.textStyle14.copyWith(
                color: AppColors.black1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
