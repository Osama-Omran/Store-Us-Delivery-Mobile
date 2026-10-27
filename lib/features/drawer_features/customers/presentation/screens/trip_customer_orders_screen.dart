import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/features/drawer_features/customers/data/models/trip_customers_response.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/usecases/get_trip_orders_usecase.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/widgets/trip_order_card.dart';

class TripCustomerOrdersScreen extends StatefulWidget {
  const TripCustomerOrdersScreen({
    super.key,
    required this.tripId,
    required this.customer,
  });
  final int tripId;
  final TripCustomer customer;

  @override
  State<TripCustomerOrdersScreen> createState() =>
      _TripCustomerOrdersScreenState();
}

class _TripCustomerOrdersScreenState extends State<TripCustomerOrdersScreen> {
  late Future<List<TripOrderModel>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _load();
  }

  Future<List<TripOrderModel>> _load() async {
    final ApiResult<TripOrdersResponse> result =
        await getIt<GetTripOrdersUsecase>().call(tripId: widget.tripId);
    List<TripOrderModel>? orders;
    String? errorMessage;
    result.when(
      success: (response) {
        if (!response.success) {
          errorMessage = response.message;
          return;
        }
        orders = response.data
            .where(_belongsToCustomer)
            .map(TripOrderModel.fromApi)
            .toList(growable: false);
      },
      failure: (error) {
        errorMessage = error.apiErrorModel.message;
      },
    );
    if (orders == null) {
      throw StateError(errorMessage ?? 'trip_customers_orders_load_failed');
    }
    return orders!;
  }

  bool _belongsToCustomer(TripOrderData order) {
    final customer = widget.customer;
    final apiCustomer = order.customer;
    if (apiCustomer == null) return false;
    if (customer.customerId?.isNotEmpty == true &&
        apiCustomer.id?.isNotEmpty == true) {
      return customer.customerId == apiCustomer.id;
    }
    // Prefer phone, not a display name, when both IDs are unavailable.
    final phone = customer.phone.replaceAll(RegExp(r'\D'), '');
    final orderPhone = (apiCustomer.phone ?? '').replaceAll(RegExp(r'\D'), '');
    if (phone.isNotEmpty && orderPhone.isNotEmpty) {
      return phone == orderPhone;
    }
    // Backend presently returns null customer_id / empty phone.
    // Match by exact name AND address if both are available.
    if (customer.name.trim().isEmpty ||
        customer.name.trim() != (apiCustomer.name ?? '').trim()) {
      return false;
    }
    if (customer.address.trim().isNotEmpty &&
        order.address?.trim().isNotEmpty == true) {
      return customer.address.trim() == order.address!.trim();
    }
    return true;
  }

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
      body: FutureBuilder<List<TripOrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0462D2)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.strings.trip_customers_orders_load_failed,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => setState(() {
                        _ordersFuture = _load();
                      }),
                      child: Text(context.strings.trip_customers_retry),
                    ),
                  ],
                ),
              ),
            );
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return Center(
              child: Text(context.strings.trip_customers_no_matched_orders),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Text(
                widget.customer.name,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              if (widget.customer.customerId == null &&
                  widget.customer.phone.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    context.strings.trip_customers_name_match_warning,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A6A22),
                    ),
                  ),
                ),
              for (final order in orders) ...[
                TripOrderCard(order: order, tripID: widget.tripId),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    ),
  );
}
