import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class OrderCustomerActions extends StatelessWidget {
  const OrderCustomerActions({
    super.key,
    required this.onCall,
    required this.onOpenLocation,
    required this.onNavigate,
    required this.onEdit,
  });

  final VoidCallback onCall;
  final VoidCallback onOpenLocation;
  final VoidCallback onNavigate;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: _SmallAction(
              title: context.strings.call_customer,
              icon: Icons.phone_outlined,
              background: AppColors.green1,
              foreground: AppColors.green0,
              onTap: onCall,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SmallAction(
              title: context.strings.open_location,
              icon: Icons.location_on_outlined,
              background: AppColors.grey5,
              foreground: AppColors.black1,
              onTap: onOpenLocation,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SmallAction(
              title: context.strings.start_navigation,
              icon: Icons.navigation_outlined,
              background: AppColors.blue4,
              foreground: AppColors.primary,
              onTap: onNavigate,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: onEdit,
        icon: const Icon(Icons.sync_rounded),
        label: Text(context.strings.order_update_address),
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
  );
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

class OrderCustomerFullAction extends StatelessWidget {
  const OrderCustomerFullAction({
    super.key,
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
