import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/custom_trip_container.dart';

class LoadedGoodsDetails extends StatelessWidget {
  const LoadedGoodsDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text(context.strings.loaded_goods_details, style: Styles.textStyle18),
        Row(
          spacing: 8,
          children: [
            CustomTripContainer(
              child: Column(spacing: 6, children: [],)
            ),
          ],
        ),
      ],
    );
  }
}
