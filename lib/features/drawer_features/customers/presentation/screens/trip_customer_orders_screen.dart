import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';

import '../../data/models/trip_customers_response.dart';
import '../widgets/trip_customer_orders_body.dart';

class TripCustomerOrdersScreen extends StatelessWidget {
  const TripCustomerOrdersScreen({
    super.key,
    required this.tripId,
    required this.customer,
  });
  final int tripId;
  final TripCustomer customer;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(context.strings.trip_customers_customer_orders),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F7FA),
      ),
      body: TripCustomerOrdersBody(tripId: tripId, customer: customer),
    ),
  );
}
