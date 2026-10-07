import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/custom_trip_container.dart';

class TripData extends StatelessWidget {
  const TripData({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomTripContainer(
      child: Column(
        spacing: 8,
        children: [
          TripDataItem(title: context.strings.trip_number, value: 'TRIP-0025'),
          TripDataItem(
            title: context.strings.warehouse,
            value: 'مخزن الجيزة الرئيسي',
          ),
          TripDataItem(
            title: context.strings.van,
            value: 'سوزوكي فان - أ ب ج 1234',
          ),
          TripDataItem(title: context.strings.driver, value: 'محمد أحمد'),
          TripDataItem(title: context.strings.loading_time, value: '90:00 صـ'),
        ],
      ),
    );
  }
}

class TripDataItem extends StatelessWidget {
  const TripDataItem({super.key, required this.title, required this.value});
  final String title, value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          value,
          style: Styles.textStyle14.copyWith(
            color: AppColors.black0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
