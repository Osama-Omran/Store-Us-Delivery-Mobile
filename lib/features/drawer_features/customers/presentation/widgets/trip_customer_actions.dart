import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
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
      SnackBar(content: Text(context.strings.trip_customers_action_unavailable)),
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

    return Row(
      children: [
        Expanded(child: _CustomerAction(
          icon: Icons.call_outlined,
          title: context.strings.trip_customers_call,
          foreground: const Color(0xFF00894C),
          background: const Color(0xFFD5F5E2),
          onTap: !hasPhone ? null : () => _launch(
            context, Uri(scheme: 'tel', path: customer.phone.trim()),
          ),
        )),
        const SizedBox(width: 8),
        Expanded(child: _CustomerAction(
          icon: Icons.chat_bubble_outline_rounded,
          title: context.strings.trip_customers_whatsapp,
          foreground: const Color(0xFF00894C),
          background: const Color(0xFFD5F5E2),
          onTap: whatsappNumber == null ? null : () => _launch(
            context, Uri.parse('https://wa.me/$whatsappNumber'),
          ),
        )),
        const SizedBox(width: 8),
        Expanded(child: _CustomerAction(
          icon: Icons.location_on_outlined,
          title: context.strings.trip_customers_location,
          foreground: const Color(0xFF172948),
          background: const Color(0xFFEDF2F7),
          onTap: !hasLocation ? null : () => _launch(
            context, Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
            ),
          ),
        )),
        const SizedBox(width: 8),
        Expanded(child: _CustomerAction(
          icon: Icons.inventory_2_outlined,
          title: context.strings.trip_customers_orders_button,
          foreground: const Color(0xFF0061D5),
          background: const Color(0xFFE0EDFF),
          onTap: onOrders,
        )),
      ],
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
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 66,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 23, color: onTap == null ? foreground.withValues(alpha: .35) : foreground),
            const SizedBox(height: 5),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                  color: onTap == null ? foreground.withValues(alpha: .35) : foreground)),
          ],
        ),
      ),
    ),
  );
}
