
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/usecases/get_trip_orders_usecase.dart';

class RescheduleSuccessScreen extends StatefulWidget {
  const RescheduleSuccessScreen({
    super.key,
    required this.tripId,
    required this.orderId,
    required this.salesOrder,
    required this.customerName,
    required this.rescheduledFor,
    required this.reason,
  });

  final int tripId;
  final int orderId;
  final String salesOrder;
  final String customerName;
  final DateTime rescheduledFor;
  final String reason;

  @override
  State<RescheduleSuccessScreen> createState() =>
      _RescheduleSuccessScreenState();
}

class _RescheduleSuccessScreenState
    extends State<RescheduleSuccessScreen> {
  bool _loadingNext = false;

  // ======= Find Next Pending Order ======= //
  Future<void> _openNextOrder() async {
    if (_loadingNext) return;

    setState(() => _loadingNext = true);

    TripOrderData? nextOrder;

    try {
      final result = await getIt<GetTripOrdersUsecase>().call(
        tripId: widget.tripId,
      );

      result.when(
        success: (response) {
          if (!response.success) return;

          final orders = response.data;

          TripOrderData? currentOrder;

          for (final item in orders) {
            if (item.id == widget.orderId) {
              currentOrder = item;
              break;
            }
          }

          final pending = orders
              .where(
                (item) =>
            item.deliveryStatus.trim().toUpperCase() ==
                'PENDING' &&
                item.id != widget.orderId,
          )
              .toList()
            ..sort(
                  (a, b) =>
                  a.stopOrder.compareTo(b.stopOrder),
            );

          if (pending.isEmpty) return;

          if (currentOrder != null) {
            for (final item in pending) {
              if (item.stopOrder > currentOrder.stopOrder) {
                nextOrder = item;
                break;
              }
            }
          }

          nextOrder ??= pending.first;
        },
        failure: (_) {},
      );
    } catch (_) {
      // Fall back to trip orders screen.
    }

    if (!mounted) return;

    if (nextOrder != null) {
      context.goNamed(
        RoutesNames.orderDetails,
        extra: {
          'trip_id': widget.tripId,
          'order_id': nextOrder!.id,
        },
      );
    } else {
      context.goNamed(RoutesNames.layout);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.rescheduledFor.toLocal();

    final formattedDate =
    MaterialLocalizations.of(context).formatMediumDate(date);

    final formattedTime =
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(date),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.grey0,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              28,
              70,
              28,
              36,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 24,
              children: [
                // ======= Success Icon ======= //
                Center(
                  child: Container(
                    width: 145,
                    height: 145,
                    decoration: BoxDecoration(
                      color: AppColors.blue4,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.event_repeat_rounded,
                      size: 82,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                // ======= Title ======= //
                Text(
                  context.strings.reschedule_success_title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black1,
                  ),
                ),

                // ======= Details Card ======= //
                Container(
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
                          alpha: 0.04,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    spacing: 18,
                    children: [
                      _ResultRow(
                        title: context.strings
                            .order_customer_data,
                        value: widget.customerName,
                      ),

                      _ResultRow(
                        title: context.strings.order,
                        value: widget.salesOrder,
                      ),

                      _ResultRow(
                        title: context.strings
                            .reschedule_new_date_time,
                        value:
                        '$formattedDate\n$formattedTime',
                        highlighted: true,
                      ),

                      _ResultRow(
                        title: context.strings
                            .reschedule_reason_label,
                        value: widget.reason,
                      ),
                    ],
                  ),
                ),

                Text(
                  context.strings
                      .reschedule_no_delivery_recorded,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey4,
                  ),
                ),

                const SizedBox(height: 4),

                // ======= Next Order ======= //
                SizedBox(
                  height: 70,
                  child: ElevatedButton(
                    onPressed:
                    _loadingNext ? null : _openNextOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: _loadingNext
                        ? CircularProgressIndicator(
                      color: AppColors.white0,
                    )
                        : Text(
                      context.strings
                          .reschedule_next_order,
                      style: const TextStyle(
                        fontSize: 20,
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

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.title,
    required this.value,
    this.highlighted = false,
  });

  final String title;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey4,
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: highlighted ? 22 : 16,
              fontWeight: FontWeight.w800,
              color: highlighted
                  ? AppColors.primary
                  : AppColors.black1,
            ),
          ),
        ),
      ],
    );
  }
}
