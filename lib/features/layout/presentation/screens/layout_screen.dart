import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/custom_loading_indicator.dart';

import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_state.dart';

import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/cubit/stock_transfer_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/cubit/stock_transfer_state.dart';

import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_cubit.dart';

import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_state.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/utils/trip_badge_counts.dart';

import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_state.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/app_menu_drawer.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/app_nav_bar.dart';

class LayoutScreen extends StatelessWidget {
  const LayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ======= Current User ======= //
        BlocProvider<AccountCubit>(
          create: (_) => getIt<AccountCubit>()..getMe(),
        ),

        // ======= Notifications ======= //
        BlocProvider<NotificationsCubit>(
          create: (_) => getIt<NotificationsCubit>()..getNotifications(),
        ),

        // ======= Current Trip ======= //
        BlocProvider<TripTabCubit>(
          lazy: false,
          create: (_) => getIt<TripTabCubit>()..getCurrentTrip(),
        ),

        // ======= Stock Transfers ======= //
        BlocProvider<StockTransferCubit>(
          lazy: false,
          create: (_) => getIt<StockTransferCubit>()..load(),
        ),
      ],
      child: const _LayoutContent(),
    );
  }
}

class _LayoutContent extends StatefulWidget {
  const _LayoutContent();

  @override
  State<_LayoutContent> createState() => _LayoutContentState();
}

class _LayoutContentState extends State<_LayoutContent> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isDrawerOpen = false;

  // ======= Refresh On Drawer Open ======= //
  void _onDrawerChanged(bool isOpen) {
    setState(() => _isDrawerOpen = isOpen);

    if (!isOpen) return;

    // ======= Refresh Stock Transfers ======= //
    context.read<StockTransferCubit>().refreshIfStale();

    // ======= Refresh Current Trip ======= //
    final tripCubit = context.read<TripTabCubit>();
    final tripState = tripCubit.state;

    final acceptanceStatus = tripState is TripTabSuccessState
        ? tripState.trip.acceptance?.status.trim().toUpperCase()
        : null;

    // Accepted and overridden trips are operationally active.
    final hasAcceptedTrip =
        acceptanceStatus == 'ACCEPTED' || acceptanceStatus == 'OVERRIDDEN';

    if (!hasAcceptedTrip && tripState is! TripTabLoadingState) {
      tripCubit.getCurrentTrip();
    }
  }

  // ======= Open Receive Trip ======= //
  Future<void> _openReceiveTrip() async {
    await context.pushNamed(RoutesNames.receiveTrip);

    if (!mounted) return;

    await context.read<TripTabCubit>().getCurrentTrip();
  }

  @override
  Widget build(BuildContext context) {
    final layout = context.watch<LayoutCubit>();

    return BlocListener<AccountCubit, AccountState>(
      listenWhen: (previous, current) =>
          current is AccountLoggedOutState ||
          current is AccountLogoutFailureState,
      listener: (context, state) {
        // ======= Logout Success ======= //
        if (state is AccountLoggedOutState) {
          context.goNamed(RoutesNames.login);
          return;
        }

        // ======= Logout Failure ======= //
        if (state is AccountLogoutFailureState) {
          final message = state.errorMessage == 'account_logout_failed'
              ? context.strings.account_logout_failed
              : state.errorMessage;

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.red0,
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
      child: Material(
        color: AppColors.white0,
        child: PopScope<Object?>(
          canPop: !layout.isDrawerFeatureOpen || _isDrawerOpen,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            if (_isDrawerOpen) {
              _scaffoldKey.currentState?.closeDrawer();
            } else if (layout.isDrawerFeatureOpen) {
              layout.closeDrawerFeature();
            }
          },
          child: SafeArea(
            top: false,
            bottom: true,
            child: Scaffold(
              key: _scaffoldKey,
              onDrawerChanged: _onDrawerChanged,
              backgroundColor: AppColors.white0,

              // ======= Main Layout ======= //
              body: Stack(
                children: [
                  BlocBuilder<LayoutCubit, LayoutState>(
                    builder: (context, state) {
                      return LayoutCubit.get(context).currentScreen;
                    },
                  ),

                  // ======= Bottom Navigation ======= //
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AppNavBar(),
                  ),

                  // ======= Logout Loading Overlay ======= //
                  BlocBuilder<AccountCubit, AccountState>(
                    builder: (context, state) {
                      if (state is! AccountLoggingOutState) {
                        return const SizedBox.shrink();
                      }

                      return Positioned.fill(
                        child: Container(
                          color: AppColors.black1.withValues(alpha: 0.18),
                          alignment: Alignment.center,
                          child: const CustomLoadingIndicator(
                            size: 84,
                            primaryColor: true,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // ======= Drawer ======= //
              drawer: BlocBuilder<AccountCubit, AccountState>(
                builder: (context, state) {
                  final user = AccountCubit.get(context).currentUser;

                  final storedName = PreferencesHelper.getUserName()?.trim();

                  final userName = user?.name.isNotEmpty == true
                      ? user!.name
                      : storedName?.isNotEmpty == true
                      ? storedName!
                      : '—';

                  final userRole = user?.role == 'Delivery Representative'
                      ? context.strings.account_delivery_representative
                      : user?.role.isNotEmpty == true
                      ? user!.role
                      : '—';

                  // ======= Trip Badge Counts ======= //
                  return BlocSelector<
                    TripTabCubit,
                    TripTabState,
                    TripBadgeCounts
                  >(
                    selector: getTripBadgeCounts,
                    builder: (context, counts) {
                      // ======= Stock Transfer Badge Count ======= //
                      return BlocSelector<
                        StockTransferCubit,
                        StockTransferState,
                        int?
                      >(
                        selector: (state) => state.pendingActionCount,
                        builder: (context, transferCount) {
                          return AppMenuDrawer(
                            // ======= User Data ======= //
                            userName: userName,
                            userRole: userRole,
                            isOnTrip: false,

                            // ======= Real Badge Counts ======= //
                            pendingDeliveriesCount: counts.deliveries,
                            pendingTransfersCount: transferCount,

                            // ======= Receive Vehicle Availability ======= //
                            canReceiveTrip: counts.receiveVehicle > 0,

                            // ======= Selected Section ======= //
                            selectedSection: layout.isTopRank
                                ? AppMenuSection.topRank
                                : layout.isTreasury
                                ? AppMenuSection.treasury
                                : layout.isStockTransfer
                                ? AppMenuSection.stockTransfer
                                : layout.isReports
                                ? AppMenuSection.reports
                                : layout.isContactUs
                                ? AppMenuSection.contactUs
                                : AppMenuSection.deliveries,

                            // ======= Drawer Navigation ======= //
                            onTopRankTap: layout.openTopRank,

                            onTreasuryTap: layout.openTreasury,

                            onDeliveriesTap: () {},

                            onStockTransferTap: layout.openStockTransfer,

                            onDirectSaleTap: () {
                              context.pushNamed(RoutesNames.directSale);
                            },

                            onCustomersTap: () {},

                            onAreasTap: () {},

                            onReportsTap: layout.openReports,

                            onContactUsTap: layout.openContactUs,

                            // ======= Receive Vehicle ======= //
                            onReceiveCustodyTap: _openReceiveTrip,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
