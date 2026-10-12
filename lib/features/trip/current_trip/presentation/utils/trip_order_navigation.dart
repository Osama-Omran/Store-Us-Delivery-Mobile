import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openTripOrderDetails(
  BuildContext context, {
  required int tripID,
  required int? orderID,
}) async {
  // ======= Validate Order ID ======= //
  if (orderID == null || orderID <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.strings.trip_order_details_unavailable)),
    );
    return;
  }

  // ======= Keep Cubit Reference ======= //
  final tripCubit = context.read<TripTabCubit>();

  // ======= Navigate To Order Details ======= //
  await GoRouter.of(context).push(
    RoutesNames.orderDetails,
    extra: {'trip_id': tripID, 'order_id': orderID},
  );

  // ======= Check Widget & Cubit ======= //
  if (!context.mounted || tripCubit.isClosed) {
    return;
  }

  // ======= Refresh Orders After Returning ======= //
  await tripCubit.getTripOrders();
}

bool hasValidOrderPhone(String phone) {
  final value = phone.trim();

  return value.isNotEmpty && value != '—' && value.toLowerCase() != 'null';
}

Future<void> callOrderCustomer(BuildContext context, String phone) async {
  if (!hasValidOrderPhone(phone)) return;

  final number = phone.trim().replaceAll(RegExp(r'\s+'), '');

  final uri = Uri(scheme: 'tel', path: number);

  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.strings.trip_action_unavailable)),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.strings.trip_action_unavailable)),
      );
    }
  }
}

Future<void> openOrderDirections(
  BuildContext context,
  TripOrderModel order,
) async {
  if (!order.hasCoordinates) return;

  final uri = Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': '${order.latitude},${order.longitude}',
  });

  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.strings.trip_action_unavailable)),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.strings.trip_action_unavailable)),
      );
    }
  }
}
