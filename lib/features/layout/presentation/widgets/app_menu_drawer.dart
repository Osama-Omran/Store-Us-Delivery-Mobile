import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/widgets/account_logout_button.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/cubit/stock_transfer_cubit.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/app_menu_drawer_header.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/app_menu_drawer_item.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_state.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/utils/trip_badge_counts.dart';

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key, required this.onReceiveCustodyTap});

  final VoidCallback onReceiveCustodyTap;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: math.min(MediaQuery.sizeOf(context).width * 0.82, 430.0),
      backgroundColor: AppColors.white0,
      surfaceTintColor: AppColors.white0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            const AppMenuDrawerHeader(),
            Expanded(
              child: _DrawerMenuItems(onReceiveCustodyTap: onReceiveCustodyTap),
            ),
            const _DrawerLogoutButton(),
          ],
        ),
      ),
    );
  }
}

class _DrawerMenuItems extends StatelessWidget {
  const _DrawerMenuItems({required this.onReceiveCustodyTap});

  final VoidCallback onReceiveCustodyTap;

  void _handleTap(BuildContext context, VoidCallback callback) {
    Navigator.of(context).pop();
    callback();
  }

  @override
  Widget build(BuildContext context) {
    final selectedFeature = context.select<LayoutCubit, LayoutDrawerFeature?>(
      (cubit) => cubit.drawerFeature,
    );
    final layout = LayoutCubit.get(context);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        AppMenuDrawerItem(
          title: context.strings.account,
          icon: Icons.person_outline_rounded,
          onTap: () {
            final router = GoRouter.of(context);
            Navigator.of(context).pop();
            router.push(RoutesNames.account);
          },
        ),
        AppMenuDrawerItem(
          title: context.strings.top_rank,
          icon: Icons.emoji_events_outlined,
          isSelected: selectedFeature == LayoutDrawerFeature.topRank,
          onTap: () => _handleTap(context, layout.openTopRank),
        ),
        AppMenuDrawerItem(
          title: context.strings.treasury,
          icon: Icons.account_balance_wallet_outlined,
          isSelected: selectedFeature == LayoutDrawerFeature.treasury,
          onTap: () => _handleTap(context, layout.openTreasury),
        ),
        _DrawerDeliveriesItem(isSelected: selectedFeature == null),
        _DrawerStockTransferItem(
          isSelected: selectedFeature == LayoutDrawerFeature.stockTransfer,
        ),
        AppMenuDrawerItem(
          title: context.strings.direct_sale,
          icon: Icons.shopping_bag_outlined,
          onTap: () {
            final router = GoRouter.of(context);
            final tripCubit = context.read<TripTabCubit>();
            _handleTap(context, () {
              final tripState = tripCubit.state;
              if (tripState is! TripTabSuccessState) return;
              router.pushNamed(
                RoutesNames.directSale,
                extra: tripState.trip.id,
              );
            });
          },
        ),
        _DrawerCustomersItem(
          isSelected: selectedFeature == LayoutDrawerFeature.customers,
        ),
        AppMenuDrawerItem(
          title: context.strings.areas,
          icon: Icons.route_outlined,
          isSelected: selectedFeature == LayoutDrawerFeature.areas,
          onTap: () => _handleTap(context, layout.openAreas),
        ),
        AppMenuDrawerItem(
          title: context.strings.reports,
          icon: Icons.bar_chart_outlined,
          isSelected: selectedFeature == LayoutDrawerFeature.reports,
          onTap: () => _handleTap(context, layout.openReports),
        ),
        AppMenuDrawerItem(
          title: context.strings.contact_us,
          icon: Icons.support_agent_outlined,
          isSelected: selectedFeature == LayoutDrawerFeature.contactUs,
          onTap: () => _handleTap(context, layout.openContactUs),
        ),
        _DrawerReceiveTripItem(
          onTap: () => _handleTap(context, onReceiveCustodyTap),
        ),
      ],
    );
  }
}

class _DrawerDeliveriesItem extends StatelessWidget {
  const _DrawerDeliveriesItem({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final count = context.select<TripTabCubit, int?>(
      (cubit) => getTripBadgeCounts(cubit.state).deliveries,
    );
    return AppMenuDrawerItem(
      title: context.strings.deliveries,
      icon: Icons.inventory_2_outlined,
      badgeCount: count,
      isSelected: isSelected,
      onTap: () {
        GoRouter.of(context).pop();
        LayoutCubit.get(context).selectTap(1);
      },
    );
  }
}

class _DrawerStockTransferItem extends StatelessWidget {
  const _DrawerStockTransferItem({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final count = context.select<StockTransferCubit, int?>(
      (cubit) => cubit.state.pendingActionCount,
    );
    return AppMenuDrawerItem(
      title: context.strings.stock_transfer,
      icon: Icons.swap_horiz_rounded,
      badgeCount: count,
      isSelected: isSelected,
      onTap: () {
        final layout = LayoutCubit.get(context);
        Navigator.of(context).pop();
        layout.openStockTransfer();
      },
    );
  }
}

class _DrawerCustomersItem extends StatelessWidget {
  const _DrawerCustomersItem({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final hasCurrentTrip = context.select<TripTabCubit, bool>(
      (cubit) => cubit.state is TripTabSuccessState,
    );
    if (!hasCurrentTrip) return const SizedBox.shrink();

    return AppMenuDrawerItem(
      title: context.strings.customers,
      icon: Icons.groups_2_outlined,
      isSelected: isSelected,
      onTap: () {
        final layout = LayoutCubit.get(context);
        Navigator.of(context).pop();
        layout.openCustomerScreen();
      },
    );
  }
}

class _DrawerReceiveTripItem extends StatelessWidget {
  const _DrawerReceiveTripItem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final canReceiveTrip = context.select<TripTabCubit, bool>(
      (cubit) => getTripBadgeCounts(cubit.state).receiveVehicle > 0,
    );
    if (!canReceiveTrip) return const SizedBox.shrink();

    return AppMenuDrawerItem(
      title: context.strings.receive_vehicle,
      icon: Icons.local_shipping_outlined,
      badgeCount: 1,
      onTap: onTap,
    );
  }
}

class _DrawerLogoutButton extends StatelessWidget {
  const _DrawerLogoutButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white0,
        border: Border(top: BorderSide(color: AppColors.grey3, width: 1)),
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
              final accountCubit = AccountCubit.get(context);
              final confirmed = await showAccountLogoutConfirmation(context);
              if (!context.mounted || !confirmed) return;

              Navigator.of(context).pop();
              await accountCubit.logout();
            },
          ),
        ),
      ),
    );
  }
}
