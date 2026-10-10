import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_customer_location.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/widgets/order_address_edit_sheet.dart';


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
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openPhone(BuildContext context) async {
    if (location.phone.isEmpty) {
      _showMessage(
        context,
        context.strings.order_customer_phone_missing,
      );
      return;
    }

    await _launch(
      context,
      Uri(scheme: 'tel', path: location.phone),
    );
  }

  Future<void> _openMap(
      BuildContext context, {
        required bool directions,
      }) async {
    if (!location.hasCoordinates) {
      _showMessage(
        context,
        context.strings.order_customer_gps_missing,
      );
      return;
    }

    final coordinates =
        '${location.latitude},${location.longitude}';

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

  Future<void> _launch(
      BuildContext context,
      Uri uri,
      ) async {
    try {
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!success && context.mounted) {
        _showMessage(
          context,
          context.strings.trip_action_unavailable,
        );
      }
    } catch (_) {
      if (context.mounted) {
        _showMessage(
          context,
          context.strings.trip_action_unavailable,
        );
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
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
              Icon(
                Icons.phone_outlined,
                color: AppColors.grey4,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location.phone.isEmpty
                      ? '—'
                      : location.phone,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.end,
                  style: Styles.textStyle16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ======= Address & GPS ======= //
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.grey5,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppColors.grey4,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasAddress
                            ? location.address
                            : context.strings.order_no_address,
                        style: Styles.textStyle16.copyWith(
                          color: AppColors.black1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    Icon(
                      Icons.my_location_outlined,
                      size: 20,
                      color: hasGPS
                          ? AppColors.grey4
                          : AppColors.red1,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasGPS
                            ? '${location.latitude!.toStringAsFixed(7)}, '
                            '${location.longitude!.toStringAsFixed(7)}'
                            : context.strings.order_customer_gps_missing,
                        style: Styles.textStyle12.copyWith(
                          color: hasGPS
                              ? AppColors.grey4
                              : AppColors.red1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (!location.isComplete) ...[
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.orange1,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.orange0,
                ),
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
                              ? context.strings
                              .order_location_not_defined
                              : context.strings
                              .order_address_not_defined,
                          style: Styles.textStyle16.copyWith(
                            color: AppColors.orange0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _FullAction(
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
          Row(
            children: [
              Expanded(
                child: _SmallAction(
                  title: context.strings.call_customer,
                  icon: Icons.phone_outlined,
                  background: AppColors.green1,
                  foreground: AppColors.green0,
                  onTap: () => _openPhone(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SmallAction(
                  title: context.strings.open_location,
                  icon: Icons.location_on_outlined,
                  background: AppColors.grey5,
                  foreground: AppColors.black1,
                  onTap: () => _openMap(
                    context,
                    directions: false,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SmallAction(
                  title: context.strings.start_navigation,
                  icon: Icons.navigation_outlined,
                  background: AppColors.blue4,
                  foreground: AppColors.primary,
                  onTap: () => _openMap(
                    context,
                    directions: true,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () => _editAddress(context),
            icon: const Icon(Icons.sync_rounded),
            label: Text(
              context.strings.order_update_address,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.blue3),
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullAction extends StatelessWidget {
  const _FullAction({
    required this.title,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: foreground),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({
    required this.title,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground, size: 24),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: Styles.textStyle12.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
