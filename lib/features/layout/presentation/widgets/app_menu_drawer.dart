import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/widgets/account_logout_button.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/app_menu_drawer_item.dart';

enum AppMenuSection {
  account,
  topRank,
  treasury,
  deliveries,
  stockTransfer,
  directSale,
  customers,
  areas,
  reports,
  contactUs,
  receiveCustody,
}

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({
    super.key,
    required this.userName,
    required this.userRole,
    this.isOnTrip = true,
    this.pendingDeliveriesCount = 0,
    this.pendingTransfersCount = 0,
    this.selectedSection = AppMenuSection.deliveries,
    this.onTopRankTap,
    this.onTreasuryTap,
    this.onDeliveriesTap,
    this.onStockTransferTap,
    this.onDirectSaleTap,
    this.onCustomersTap,
    this.onAreasTap,
    this.onReportsTap,
    this.onContactUsTap,
    this.onReceiveCustodyTap,
  });

  final String userName;
  final String userRole;
  final bool isOnTrip;
  final int pendingDeliveriesCount;
  final int pendingTransfersCount;
  final AppMenuSection selectedSection;

  final VoidCallback? onTopRankTap;
  final VoidCallback? onTreasuryTap;
  final VoidCallback? onDeliveriesTap;
  final VoidCallback? onStockTransferTap;
  final VoidCallback? onDirectSaleTap;
  final VoidCallback? onCustomersTap;
  final VoidCallback? onAreasTap;
  final VoidCallback? onReportsTap;
  final VoidCallback? onContactUsTap;
  final VoidCallback? onReceiveCustodyTap;

  void _handleTap(BuildContext context, VoidCallback? callback) {
    Navigator.of(context).pop();
    callback?.call();
  }

  @override
  Widget build(BuildContext context) {
    final drawerWidth = math.min(
      MediaQuery.sizeOf(context).width * 0.82,
      430.0,
    );

    return Drawer(
      width: drawerWidth,
      backgroundColor: AppColors.white0,
      surfaceTintColor: AppColors.white0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // ======= Header ======= //
            _DrawerHeader(
              userName: userName,
              userRole: userRole,
              isOnTrip: isOnTrip,
            ),

            // ======= Menu Items ======= //
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  AppMenuDrawerItem(
                    title: context.strings.account,
                    icon: Icons.person_outline_rounded,
                    isSelected: selectedSection == AppMenuSection.account,

                    onTap: () {
                      final router = GoRouter.of(context);

                      Navigator.of(context).pop();

                      router.push(RoutesNames.account);
                    },
                  ),

                  AppMenuDrawerItem(
                    title: '${context.strings.top_rank} · Top Rank',
                    icon: Icons.emoji_events_outlined,
                    isSelected: selectedSection == AppMenuSection.topRank,
                    onTap: () => _handleTap(context, onTopRankTap),
                  ),

                  AppMenuDrawerItem(
                    title: context.strings.treasury,
                    icon: Icons.account_balance_wallet_outlined,
                    isSelected: selectedSection == AppMenuSection.treasury,
                    onTap: () => _handleTap(context, onTreasuryTap),
                  ),

                  AppMenuDrawerItem(
                    title: context.strings.deliveries,
                    icon: Icons.inventory_2_outlined,
                    badgeCount: pendingDeliveriesCount,
                    isSelected: selectedSection == AppMenuSection.deliveries,
                    onTap: () {
                      GoRouter.of(context).pop();
                      LayoutCubit.get(context).selectTap(1);
                    },
                  ),

                  AppMenuDrawerItem(
                    title: context.strings.stock_transfer,
                    icon: Icons.swap_horiz_rounded,
                    badgeCount: pendingTransfersCount,
                    isSelected: selectedSection == AppMenuSection.stockTransfer,
                    onTap: () => _handleTap(context, onStockTransferTap),
                  ),

                  AppMenuDrawerItem(
                    title: context.strings.direct_sale,
                    icon: Icons.shopping_bag_outlined,
                    isSelected: selectedSection == AppMenuSection.directSale,
                    onTap: () => _handleTap(context, onDirectSaleTap),
                  ),

                  AppMenuDrawerItem(
                    title: context.strings.customers,
                    icon: Icons.groups_2_outlined,
                    isSelected: selectedSection == AppMenuSection.customers,
                    onTap: () => _handleTap(context, onCustomersTap),
                  ),

                  AppMenuDrawerItem(
                    title: context.strings.areas,
                    icon: Icons.route_outlined,
                    isSelected: selectedSection == AppMenuSection.areas,
                    onTap: () => _handleTap(context, onAreasTap),
                  ),

                  AppMenuDrawerItem(
                    title: context.strings.reports,
                    icon: Icons.bar_chart_outlined,
                    isSelected: selectedSection == AppMenuSection.reports,
                    onTap: () => _handleTap(context, onReportsTap),
                  ),

                  AppMenuDrawerItem(
                    title: context.strings.contact_us,
                    icon: Icons.support_agent_outlined,
                    isSelected: selectedSection == AppMenuSection.contactUs,
                    onTap: () => _handleTap(context, onContactUsTap),
                  ),

                  AppMenuDrawerItem(
                    title: context.strings.receive_custody,
                    icon: Icons.local_shipping_outlined,
                    isSelected:
                        selectedSection == AppMenuSection.receiveCustody,
                    onTap: () => _handleTap(context, onReceiveCustodyTap),
                  ),
                ],
              ),
            ),

            // ======= Fixed Logout Footer ======= //
            Container(
              decoration: BoxDecoration(
                color: AppColors.white0,
                border: Border(
                  top: BorderSide(color: AppColors.grey3, width: 1),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: AppMenuDrawerItem(
                    title: context.strings.logout,
                    icon: Icons.logout_rounded,
                    isLogout: true,
                    onTap: () async {
                      // Get Cubit before closing the drawer.
                      final accountCubit = context.read<AccountCubit>();

                      final confirmed = await showAccountLogoutConfirmation(
                        context,
                      );

                      if (!context.mounted || !confirmed) return;

                      // Close drawer.
                      Navigator.of(context).pop();

                      // POST /logout
                      await accountCubit.logout();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// Drawer Header
// =====================================================

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.userName,
    required this.userRole,
    required this.isOnTrip,
  });

  final String userName;
  final String userRole;
  final bool isOnTrip;

  @override
  Widget build(BuildContext context) {
    final initial = userName.trim().isNotEmpty
        ? userName.trim().substring(0, 1)
        : '؟';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.blue4, AppColors.blue5],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ======= Top Actions ======= //
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
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
                      size: 24,
                    ),
                  ),

                  const Spacer(),

                  Material(
                    color: AppColors.white0,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).pop(),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.black1,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ======= User Information ======= //
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      initial,
                      style: Styles.textStyle24.copyWith(
                        fontSize: 32,
                        color: AppColors.white0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 3,
                      children: [
                        Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Styles.textStyle20.copyWith(
                            fontSize: 22,
                            color: AppColors.black1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        Text(
                          userRole,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Styles.textStyle14.copyWith(
                            color: AppColors.grey4,
                          ),
                        ),

                        if (isOnTrip)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                context.strings.currently_on_trip,
                                style: Styles.textStyle12.copyWith(
                                  color: AppColors.white0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
