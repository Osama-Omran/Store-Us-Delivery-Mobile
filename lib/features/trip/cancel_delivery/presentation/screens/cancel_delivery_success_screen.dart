
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/usecases/get_trip_orders_usecase.dart';

class CancelDeliverySuccessScreen extends StatefulWidget {
  const CancelDeliverySuccessScreen({
    super.key,
    required this.tripId,
    required this.orderId,
    required this.salesOrder,
    required this.customerName,
    required this.reason,
  });

  final int tripId;
  final int orderId;
  final String salesOrder;
  final String customerName;
  final String reason;

  @override
  State<CancelDeliverySuccessScreen> createState() =>
      _CancelDeliverySuccessScreenState();
}

class _CancelDeliverySuccessScreenState
    extends State<CancelDeliverySuccessScreen> {
  bool _loadingNext = false;

  // ======= Get Next Pending Order ======= //
  Future<void> _goToNextOrder() async {
    if (_loadingNext) return;

    setState(() => _loadingNext = true);

    int? nextOrderId;
    bool requestFailed = false;

    try {
      final result = await getIt<GetTripOrdersUsecase>().call(
        tripId: widget.tripId,
      );

      result.when(
        success: (response) {
          if (!response.success) {
            requestFailed = true;
            return;
          }

          final List<TripOrderData> orders = [
            ...response.data,
          ]..sort(
                (a, b) => a.stopOrder.compareTo(b.stopOrder),
          );

          int? currentStopOrder;

          for (final order in orders) {
            if (order.id == widget.orderId) {
              currentStopOrder = order.stopOrder;
              break;
            }
          }

          final pendingOrders = orders.where((order) {
            return order.id != widget.orderId &&
                order.deliveryStatus.trim().toUpperCase() ==
                    'PENDING';
          }).toList();

          // Prefer the next stop in the actual trip order.
          if (currentStopOrder != null) {
            for (final order in pendingOrders) {
              if (order.stopOrder > currentStopOrder) {
                nextOrderId = order.id;
                break;
              }
            }
          }

          // Otherwise select the first pending order.
          if (nextOrderId == null && pendingOrders.isNotEmpty) {
            nextOrderId = pendingOrders.first.id;
          }
        },
        failure: (_) {
          requestFailed = true;
        },
      );
    } catch (_) {
      requestFailed = true;
    }

    if (!mounted) return;

    setState(() => _loadingNext = false);

    // ======= API Failure ======= //
    if (requestFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.strings.cancel_delivery_next_order_failed,
          ),
          backgroundColor: AppColors.red0,
        ),
      );
      return;
    }

    // ======= Next Pending Order ======= //
    if (nextOrderId != null) {
      context.goNamed(
        RoutesNames.orderDetails,
        extra: {
          'trip_id': widget.tripId,
          'order_id': nextOrderId,
        },
      );
      return;
    }

    // ======= No Remaining Pending Orders ======= //
    context.goNamed(RoutesNames.layout);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.grey0,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              28, 75, 28, 36,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 24,
              children: [
                // ======= Success Icon ======= //
                Center(
                  child: Container(
                    height: 145,
                    width: 145,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.red1.withValues(
                        alpha: 0.10,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.block_rounded,
                      size: 84,
                      color: AppColors.red1,
                    ),
                  ),
                ),

                // ======= Success Title ======= //
                Text(
                  context.strings.cancel_delivery_success_title,
                  textAlign: TextAlign.center,
                  style: Styles.textStyle24.copyWith(
                    color: AppColors.black1,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                // ======= Details Card ======= //
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white0,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: AppColors.grey3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black0.withValues(
                          alpha: 0.035,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    spacing: 19,
                    children: [
                      _SuccessInfoRow(
                        title: context.strings
                            .order_customer_data,
                        value: widget.customerName,
                      ),

                      _SuccessInfoRow(
                        title: context.strings.order,
                        value: widget.salesOrder,
                      ),

                      _SuccessInfoRow(
                        title: context.strings
                            .cancel_delivery_reason_label,
                        value: widget.reason,
                      ),
                    ],
                  ),
                ),

                Text(
                  context.strings
                      .cancel_delivery_success_description,
                  textAlign: TextAlign.center,
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.grey4,
                  ),
                ),

                const SizedBox(height: 5),

                // ======= Next Order Button ======= //
                SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: ElevatedButton(
                    onPressed:
                    _loadingNext ? null : _goToNextOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(26),
                      ),
                    ),
                    child: _loadingNext
                        ? CircularProgressIndicator(
                      color: AppColors.white0,
                    )
                        : Text(
                      context.strings
                          .cancel_delivery_next_order,
                      style: Styles.textStyle20.copyWith(
                        color: AppColors.white0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessInfoRow extends StatelessWidget {
  const _SuccessInfoRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        SizedBox(
          width: 85,
          child: Text(
            title,
            style: Styles.textStyle14.copyWith(
              color: AppColors.grey4,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value.trim().isEmpty ? '—' : value,
            style: Styles.textStyle16.copyWith(
              color: AppColors.black1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
