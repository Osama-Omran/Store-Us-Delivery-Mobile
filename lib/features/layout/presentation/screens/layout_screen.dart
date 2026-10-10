import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_state.dart';

import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_cubit.dart';

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

        // ======= Notifications Count ======= //
        BlocProvider<NotificationsCubit>(
          create: (_) => getIt<NotificationsCubit>()..getNotifications(),
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
              onDrawerChanged: (isOpen) =>
                  setState(() => _isDrawerOpen = isOpen),
              backgroundColor: AppColors.white0,

              // ======= Original Stack ======= //
              body: Stack(
                children: [
                  BlocBuilder<LayoutCubit, LayoutState>(
                    builder: (context, state) {
                      return LayoutCubit.get(context).currentScreen;
                    },
                  ),

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
                          child: const CircularProgressIndicator(),
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

                  return AppMenuDrawer(
                    userName: userName,
                    userRole: userRole,

                    // /me does not return trip acceptance status.
                    isOnTrip: false,

                    // No verified counters for these menu items yet.
                    pendingDeliveriesCount: 0,
                    pendingTransfersCount: 0,

                    selectedSection: layout.isTopRank
                        ? AppMenuSection.topRank
                        : layout.isTreasury
                        ? AppMenuSection.treasury
                        : AppMenuSection.deliveries,

                    onTopRankTap: layout.openTopRank,
                    onTreasuryTap: layout.openTreasury,
                    onDeliveriesTap: () {},
                    onStockTransferTap: () {},
                    onDirectSaleTap: () {},
                    onCustomersTap: () {},
                    onAreasTap: () {},
                    onReportsTap: () {},
                    onContactUsTap: () {},
                    onReceiveCustodyTap: () {},
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
