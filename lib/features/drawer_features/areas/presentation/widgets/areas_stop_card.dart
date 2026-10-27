import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/widgets/trip_order_status.dart';

class AreasStopCard extends StatelessWidget {
  const AreasStopCard({
    super.key,
    required this.order,
    required this.isNext,
    required this.isFirst,
    required this.isLast,
    required this.onSelect,
    required this.onShowOrder,
  });

  final TripOrderModel order;
  final bool isNext;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onSelect;
  final VoidCallback onShowOrder;

  @override
  Widget build(BuildContext context) {
    final status = TripOrderStatusStyle.forOrder(context, order);
    final markerColor = isNext
        ? AppColors.primary
        : order.isPending
        ? AppColors.grey5
        : status.numberBackground;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 38,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: isFirst ? 22 : 0,
                  bottom: isLast ? null : 0,
                  height: isLast ? 22 : null,
                  child: Container(width: 2, color: AppColors.grey3),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 21),
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: markerColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isNext ? AppColors.blue3 : AppColors.white0,
                        width: isNext ? 3 : 2,
                      ),
                    ),
                    child: order.status == TripOrderStatus.delivered
                        ? const Icon(
                            Icons.check_rounded,
                            size: 19,
                            color: AppColors.white0,
                          )
                        : order.status == TripOrderStatus.cancelled
                        ? const Icon(
                            Icons.close_rounded,
                            size: 19,
                            color: AppColors.white0,
                          )
                        : Text(
                            '${order.stopNumber}',
                            style: Styles.textStyle14.copyWith(
                              color: isNext
                                  ? AppColors.white0
                                  : order.isPending
                                  ? AppColors.black1
                                  : status.numberForeground,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Material(
                color: AppColors.white0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: isNext ? AppColors.primary : AppColors.grey3,
                    width: isNext ? 1.5 : 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onSelect,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 15, 15, 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      order.customerName,
                                      style: Styles.textStyle16.copyWith(
                                        color: AppColors.black1,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  if (isNext) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        context.strings.areas_next,
                                        style: Styles.textStyle10.copyWith(
                                          color: AppColors.white0,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                context.strings.areas_stop_summary(
                                  order.address.isEmpty
                                      ? context
                                            .strings
                                            .areas_address_unavailable
                                      : order.address,
                                  status.title,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Styles.textStyle12.copyWith(
                                  color: AppColors.grey4,
                                ),
                              ),
                              if (!order.hasCoordinates) ...[
                                const SizedBox(height: 5),
                                Text(
                                  context
                                      .strings
                                      .areas_stop_location_unavailable,
                                  style: Styles.textStyle11.copyWith(
                                    color: AppColors.grey4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: onShowOrder,
                          icon: const Icon(Icons.chevron_left_rounded),
                          color: AppColors.grey4,
                          tooltip: context.strings.trip_map_show_order,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
