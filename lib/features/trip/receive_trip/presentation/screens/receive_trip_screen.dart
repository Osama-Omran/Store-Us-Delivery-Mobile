import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/widgets/custom_app_bar.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/loaded_goods_details.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/trip_data.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/van_products.dart';

class ReceiveTripScreen extends StatelessWidget {
  const ReceiveTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: context.strings.confirm_receiving_van),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TripData(),
          Gap(24),
          LoadedGoodsDetails(),
          const Gap(16),
          VanProducts(),
        ],
      ),
    );
  }
}
