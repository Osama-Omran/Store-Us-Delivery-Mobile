import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/usecases/get_trip_orders_usecase.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_flow_data.dart';

class DeliverySuccessScreen extends StatefulWidget {
  const DeliverySuccessScreen({
    super.key,
    required this.flow,
    required this.collectedAmount,
    required this.paymentMethod,
  });

  final DeliveryFlowData flow;
  final num collectedAmount;
  final String paymentMethod;

  @override
  State<DeliverySuccessScreen> createState() => _DeliverySuccessScreenState();
}

class _DeliverySuccessScreenState extends State<DeliverySuccessScreen> {
  bool _loading = false;

  Future<void> _nextOrder() async {
    if (_loading) return;

    setState(() => _loading = true);

    int? nextOrderId;
    String? error;

    try {
      final result = await getIt<GetTripOrdersUsecase>().call(
        tripId: widget.flow.tripId,
      );

      result.when(
        success: (response) {
          if (!response.success) {
            error = context.strings.delivery_next_order_failed;
            return;
          }

          final orders = List<TripOrderData>.from(response.data)
            ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));

          int? currentStopOrder;

          for (final order in orders) {
            if (order.id == widget.flow.orderId) {
              currentStopOrder = order.stopOrder;
              break;
            }
          }

          final pending = orders
              .where(
                (order) =>
                    order.id != widget.flow.orderId &&
                    order.deliveryStatus.toUpperCase() == 'PENDING',
              )
              .toList();

          if (currentStopOrder != null) {
            for (final order in pending) {
              if (order.stopOrder > currentStopOrder) {
                nextOrderId = order.id;
                break;
              }
            }
          }

          if (nextOrderId == null && pending.isNotEmpty) {
            nextOrderId = pending.first.id;
          }
        },
        failure: (failure) {
          error = failure.apiErrorModel.message;
        },
      );
    } catch (_) {
      error = mounted ? context.strings.delivery_next_order_failed : null;
    }

    if (!mounted) return;

    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error!)));
      return;
    }

    if (nextOrderId != null) {
      context.goNamed(
        RoutesNames.orderDetails,
        extra: {'trip_id': widget.flow.tripId, 'order_id': nextOrderId!},
      );
    } else {
      context.goNamed(RoutesNames.layout);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = widget.flow;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.grey0,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(28),
            children: [
              const SizedBox(height: 40),

              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.green1,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.green0,
                    size: 82,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              Text(
                context.strings.delivery_success_title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.black1,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white0,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.grey3),
                ),
                child: Column(
                  spacing: 16,
                  children: [
                    _SuccessRow(
                      label: context.strings.order,
                      value: flow.salesOrder,
                    ),
                    _SuccessRow(
                      label: context.strings.order_customer_data,
                      value: flow.customerName,
                    ),
                    _SuccessRow(
                      label: context.strings.delivery_selected_items_value,
                      value: flow.estimatedTotal == null
                          ? '—'
                          : formatTripAmount(context, flow.estimatedTotal!),
                    ),
                    _SuccessRow(
                      label: context.strings.delivery_collected_amount,
                      value: formatTripAmount(context, widget.collectedAmount),
                    ),
                    _SuccessRow(
                      label: context.strings.delivery_payment_method,
                      value: widget.paymentMethod == 'cash'
                          ? context.strings.delivery_cash
                          : widget.paymentMethod,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                height: 65,
                child: ElevatedButton(
                  onPressed: _loading ? null : _nextOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white0,
                  ),
                  child: _loading
                      ? CircularProgressIndicator(color: AppColors.white0)
                      : Text(
                          context.strings.delivery_next_order,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 10),

              OutlinedButton(
                onPressed: () {
                  context.goNamed(
                    RoutesNames.orderDetails,
                    extra: {'trip_id': flow.tripId, 'order_id': flow.orderId},
                  );
                },
                child: Text(context.strings.view_delivery_details),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessRow extends StatelessWidget {
  const _SuccessRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: TextStyle(color: AppColors.grey4)),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: AppColors.black1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
