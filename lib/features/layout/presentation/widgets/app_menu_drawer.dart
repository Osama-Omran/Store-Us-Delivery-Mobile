import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/app_menu_drawer_item.dart';

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({
    super.key,
    required this.userName,
    required this.userRole,
    this.pendingDeliveriesCount = 0,
    this.onAccountTap,
    this.onTreasuryTap,
    this.onDeliveriesTap,
    this.onCustomersTap,
    this.onAreasTap,
    this.onReportsTap,
    this.onContactUsTap,
    this.onReceiveCustodyTap,
    this.onLogoutTap,
  });

  final String userName;
  final String userRole;
  final int pendingDeliveriesCount;

  final VoidCallback? onAccountTap;
  final VoidCallback? onTreasuryTap;
  final VoidCallback? onDeliveriesTap;
  final VoidCallback? onCustomersTap;
  final VoidCallback? onAreasTap;
  final VoidCallback? onReportsTap;
  final VoidCallback? onContactUsTap;
  final VoidCallback? onReceiveCustodyTap;
  final VoidCallback? onLogoutTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 0.82;

    return Drawer(
      width: width,
      backgroundColor: AppColors.white0,
      surfaceTintColor: AppColors.white0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _DrawerHeader(
              userName: userName,
              userRole: userRole,
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        AppMenuDrawerItem(
                          title: context.strings.account,
                          icon: Icons.person_outline_rounded,
                          onTap: onAccountTap,
                        ),
                        AppMenuDrawerItem(
                          title: context.strings.treasury,
                          icon: Icons.account_balance_wallet_outlined,
                          onTap: onTreasuryTap,
                        ),
                        AppMenuDrawerItem(
                          title: context.strings.deliveries,
                          icon: Icons.inventory_2_outlined,
                          badgeCount: pendingDeliveriesCount > 0
                              ? pendingDeliveriesCount
                              : null,
                          onTap: onDeliveriesTap,
                        ),
                        AppMenuDrawerItem(
                          title: context.strings.customers,
                          icon: Icons.groups_2_outlined,
                          onTap: onCustomersTap,
                        ),
                        AppMenuDrawerItem(
                          title: context.strings.areas,
                          icon: Icons.tune_rounded,
                          onTap: onAreasTap,
                        ),
                        AppMenuDrawerItem(
                          title: context.strings.reports,
                          icon: Icons.bar_chart_rounded,
                          onTap: onReportsTap,
                        ),
                        AppMenuDrawerItem(
                          title: context.strings.contact_us,
                          icon: Icons.headset_mic_outlined,
                          onTap: onContactUsTap,
                        ),
                        AppMenuDrawerItem(
                          title: context.strings.receive_custody,
                          icon: Icons.local_shipping_outlined,
                          onTap: onReceiveCustodyTap,
                        ),
                      ],
                    ),
                  ),
                  AppMenuDrawerItem(
                    title: context.strings.logout,
                    icon: Icons.logout_rounded,
                    isLogout: true,
                    showDivider: true,
                    onTap: onLogoutTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.userName,
    required this.userRole,
  });

  final String userName;
  final String userRole;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
      color: AppColors.blue5,
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.white0,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.black1,
                    size: 28,
                  ),
                ),
              ),
              const Spacer(),
              Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.20),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.local_shipping_outlined,
                      color: AppColors.white0,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.white0,
                      size: 34,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            userName,
            style: TextStyle(
              color: AppColors.black1,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            userRole,
            style: TextStyle(
              color: AppColors.grey4,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              context.strings.currently_on_trip,
              style: TextStyle(
                color: AppColors.white0,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}