import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import '../../data/models/delivery_flow_data.dart';
import '../widgets/delivery_result_form.dart';

class DeliveryResultScreen extends StatelessWidget {
  const DeliveryResultScreen({super.key, required this.flow});
  final DeliveryFlowData flow;
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.grey0,
      body: DeliveryResultForm(flow: flow),
    ),
  );
}
