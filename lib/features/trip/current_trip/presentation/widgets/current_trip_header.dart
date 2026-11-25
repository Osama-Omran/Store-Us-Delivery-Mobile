import 'package:material_ui/material_ui.dart';
import 'package:storeus_delivery/core/printing/receipt_print_button.dart';
import 'package:storeus_delivery/core/printing/storeus_receipt_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_state.dart';
import 'package:storeus_delivery/features/trip/trip_map/data/models/trip_map_stop.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class CurrentTripHeader extends StatelessWidget {
  const CurrentTripHeader({super.key});

  // ======= Open Trip Map: original navigation and validation ======= //
  void _openTripMap(BuildContext context) {
    final state = context.read<TripTabCubit>().state;

    if (state is! TripTabSuccessState ||
        state.ordersStatus != TripOrdersStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.strings.trip_map_orders_unavailable)),
      );
      return;
    }

    final stops =
        state.orders
            .where((order) => order.hasCoordinates)
            .map(
              (order) => TripMapStop(
                order: order,
                location: LatLng(order.latitude!, order.longitude!),
              ),
            )
            .toList()
          ..sort((a, b) => a.number.compareTo(b.number));

    GoRouter.of(context).push(
      RoutesNames.tripMap,
      extra: {
        'trip_id': state.trip.id,
        'trip_number': state.trip.number,
        'stops': stops,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayTripNumber = context.select<TripTabCubit, String?>((cubit) {
      final state = cubit.state;
      return state is TripTabSuccessState ? state.trip.number : null;
    });
    // Rebuild when orders finish loading or an order status changes.
    final hasHandledOrders = context.select<TripTabCubit, bool>((cubit) {
      final state = cubit.state;
      return state is TripTabSuccessState &&
          state.ordersStatus == TripOrdersStatus.success &&
          state.orders.any((order) => order.isHandled);
    });
    if (displayTripNumber == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 98),
      padding: const EdgeInsetsDirectional.fromSTEB(20, 13, 20, 13),
      decoration: BoxDecoration(
        color: AppColors.white0,
        border: Border(bottom: BorderSide(color: AppColors.grey3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black1.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.blue5,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.route_outlined,
              color: AppColors.primary,
              size: 23,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.strings.my_current_trip,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.textStyle20.copyWith(color: AppColors.black1),
                ),
                const SizedBox(height: 5),
                Text(
                  context.strings.trip_number_title(
                    '\u2066#$displayTripNumber\u2069',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.textStyle12.copyWith(color: AppColors.grey4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Hide trip printing until at least one order has been handled.
          // Keep the report content unchanged (all trip orders, no UI filter).
          if (hasHandledOrders) ...[
            ReceiptPrintButton(
              compact: true,
              tooltip: Localizations.localeOf(context).languageCode == 'ar'
                  ? 'طباعة كشف الرحلة عبر RawBT'
                  : 'Print trip report via RawBT',
              receiptBuilder: () async {
                final state = context.read<TripTabCubit>().state;
                if (state is! TripTabSuccessState ||
                    state.ordersStatus != TripOrdersStatus.success ||
                    !state.orders.any((order) => order.isHandled)) {
                  throw StateError('لا توجد أوردرات تم اتخاذ إجراء عليها للطباعة');
                }
                return StoreusReceiptBuilder.trip(
                  tripNumber: state.trip.number,
                  orders: state.orders,
                );
              },
            ),
            const SizedBox(width: 4),
          ],
          Material(
            color: AppColors.blue4,
            borderRadius: BorderRadius.circular(15),
            child: Tooltip(
              message: context.strings.open_location,
              child: InkWell(
                onTap: () => _openTripMap(context),
                borderRadius: BorderRadius.circular(15),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                    size: 25,
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
