import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_customer_location.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_cubit.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_address_edit_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

import 'order_customer_actions.dart';
import 'order_customer_location_panel.dart';

class OrderCustomerCard extends StatelessWidget {
  const OrderCustomerCard({
    super.key,
    required this.tripId,
    required this.orderId,
    required this.location,
  });

  final int tripId;
  final int orderId;
  final OrderCustomerLocation location;

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(context.localizedErrorMessage(message))),
      );
  }

  Future<void> _openPhone(BuildContext context) async {
    if (location.phone.isEmpty) {
      _showMessage(context, context.strings.order_customer_phone_missing);
      return;
    }

    await _launch(context, Uri(scheme: 'tel', path: location.phone));
  }

  Future<void> _openMap(
    BuildContext context, {
    required bool directions,
  }) async {
    if (!location.hasCoordinates) {
      _showMessage(context, context.strings.order_customer_gps_missing);
      return;
    }

    final coordinates = '${location.latitude},${location.longitude}';

    final uri = directions
        ? Uri.https('www.google.com', '/maps/dir/', {
            'api': '1',
            'destination': coordinates,
          })
        : Uri.https('www.google.com', '/maps/search/', {
            'api': '1',
            'query': coordinates,
          });

    await _launch(context, uri);
  }

  Future<void> _launch(BuildContext context, Uri uri) async {
    try {
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!success && context.mounted) {
        _showMessage(context, context.strings.trip_action_unavailable);
      }
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, context.strings.trip_action_unavailable);
      }
    }
  }

  // ======= Open Address Edit Bottom Sheet ======= //
  void _editAddress(BuildContext context) {
    final cubit = context.read<OrderDetailsCubit>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.white0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: OrderAddressEditSheet(
            tripId: tripId,
            orderId: orderId,
            location: location,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAddress = location.hasAddress;
    final hasGPS = location.hasCoordinates;

    final statusText = hasAddress && hasGPS
        ? context.strings.order_address_defined
        : hasAddress
        ? context.strings.order_address_only
        : hasGPS
        ? context.strings.order_gps_only
        : context.strings.order_address_undefined;

    final statusColor = hasAddress && hasGPS
        ? AppColors.green0
        : AppColors.orange0;

    final statusBackground = hasAddress && hasGPS
        ? AppColors.green1
        : AppColors.orange1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.strings.order_customer_data,
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.grey4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  statusText,
                  style: Styles.textStyle12.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Text(
            location.name.isEmpty ? '—' : location.name,
            style: Styles.textStyle24.copyWith(
              color: AppColors.black1,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              Icon(Icons.phone_outlined, color: AppColors.grey4, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location.phone.isEmpty ? '—' : location.phone,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.end,
                  style: Styles.textStyle16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ======= Address & GPS ======= //
          OrderCustomerLocationPanel(location: location),

          if (!location.isComplete) ...[
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.orange1,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.orange0),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.orange0,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hasAddress
                              ? context.strings.order_location_not_defined
                              : context.strings.order_address_not_defined,
                          style: Styles.textStyle16.copyWith(
                            color: AppColors.orange0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  OrderCustomerFullAction(
                    title: context.strings.order_set_location,
                    icon: Icons.add_location_alt_outlined,
                    background: AppColors.orange0,
                    foreground: AppColors.white0,
                    onTap: () => _editAddress(context),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // ======= Contact / Location / Navigation ======= //
          OrderCustomerActions(
            onCall: () => _openPhone(context),
            onOpenLocation: () => _openMap(context, directions: false),
            onNavigate: () => _openMap(context, directions: true),
            onEdit: () => _editAddress(context),
          ),
        ],
      ),
    );
  }
}
