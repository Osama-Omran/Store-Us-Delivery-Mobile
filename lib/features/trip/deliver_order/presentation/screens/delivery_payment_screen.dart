import 'package:flutter/material.dart';

import '../../data/models/delivery_flow_data.dart';
import '../widgets/delivery_payment_form.dart';

class DeliveryPaymentScreen extends StatelessWidget {
  const DeliveryPaymentScreen({super.key, required this.flow});
  final DeliveryFlowData flow;
  @override
  Widget build(BuildContext context) => DeliveryPaymentForm(flow: flow);
}
