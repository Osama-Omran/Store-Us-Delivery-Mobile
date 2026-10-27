import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/customers/data/models/trip_customers_response.dart';
import 'package:url_launcher/url_launcher.dart';

class TripCustomerActions extends StatelessWidget {
  const TripCustomerActions({
    super.key,
    required this.customer,
    required this.onOrders,
  });
  final TripCustomer customer;
  final VoidCallback? onOrders;

  Future<void> _launch(BuildContext context, Uri uri) async {
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
          context.mounted) {
        _unavailable(context);
      }
    } catch (_) {
      if (context.mounted) _unavailable(context);
    }
  }

  void _unavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.strings.trip_customers_action_unavailable),
      ),
    );
  }

  String? get _whatsappNumber {
    final phone = customer.phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (phone.startsWith('+') && phone.length > 7) {
      return phone.substring(1);
    }
    if (phone.startsWith('00') && phone.length > 8) {
      return phone.substring(2);
    }
    if (RegExp(r'^01\d{9}$').hasMatch(phone)) {
      return '20${phone.substring(1)}';
    }
    if (RegExp(r'^20\d{10}$').hasMatch(phone)) return phone;
    return null; // Other formats need confirmed country code.
  }

  @override
  Widget build(BuildContext context) {
    final hasPhone = customer.hasPhone;
    final whatsappNumber = _whatsappNumber;
    final hasLocation = customer.hasLocation;
    final lat = customer.latitude;
    final lng = customer.longitude;

    final actions = [
      _CustomerAction(
        icon: Icons.call_outlined,
        title: context.strings.trip_customers_call,
        foreground: const Color(0xFF00894C),
        background: const Color(0xFFD5F5E2),
        onTap: !hasPhone
            ? null
            : () => _launch(
                context,
                Uri(scheme: 'tel', path: customer.phone.trim()),
              ),
      ),
      _CustomerAction(
        icon: Icons.chat_bubble_outline_rounded,
        title: context.strings.trip_customers_whatsapp,
        foreground: const Color(0xFF00894C),
        background: const Color(0xFFD5F5E2),
        onTap: whatsappNumber == null
            ? null
            : () =>
                  _launch(context, Uri.parse('https://wa.me/$whatsappNumber')),
      ),
      _CustomerAction(
        icon: Icons.location_on_outlined,
        title: context.strings.trip_customers_location,
        foreground: const Color(0xFF172948),
        background: const Color(0xFFEDF2F7),
        onTap: !hasLocation
            ? null
            : () => _launch(
                context,
                Uri.parse(
                  'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
                ),
              ),
      ),
      _CustomerAction(
        icon: Icons.inventory_2_outlined,
        title: context.strings.trip_customers_orders_button,
        foreground: const Color(0xFF0061D5),
        background: const Color(0xFFE0EDFF),
        onTap: onOrders,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 300 ||
            MediaQuery.textScalerOf(context).scale(16) > 20) {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final action in actions)
                SizedBox(width: (constraints.maxWidth - 8) / 2, child: action),
            ],
          );
        }
        return Row(
          spacing: 8,
          children: [for (final action in actions) Expanded(child: action)],
        );
      },
    );
  }
}

class _CustomerAction extends StatelessWidget {
  const _CustomerAction({
    required this.icon,
    required this.title,
    required this.foreground,
    required this.background,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final Color foreground;
  final Color background;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: onTap == null ? background.withValues(alpha: .45) : background,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        constraints: const BoxConstraints(minHeight: 66),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 23,
              color: onTap == null
                  ? foreground.withValues(alpha: .35)
                  : foreground,
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Styles.textStyle12.copyWith(
                color: onTap == null
                    ? foreground.withValues(alpha: .35)
                    : foreground,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
