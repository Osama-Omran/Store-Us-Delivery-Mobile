import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_state.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/cubit/stock_transfer_cubit.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_state.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/app_menu_drawer.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/layout_body.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_state.dart';

class LayoutContent extends StatefulWidget {
  const LayoutContent({super.key});

  @override
  State<LayoutContent> createState() => _LayoutContentState();
}

class _LayoutContentState extends State<LayoutContent> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDrawerOpen = false;

  void _onDrawerChanged(bool isOpen) {
    setState(() => _isDrawerOpen = isOpen);
    if (!isOpen) return;

    context.read<StockTransferCubit>().refreshIfStale();
    final tripCubit = context.read<TripTabCubit>();
    final tripState = tripCubit.state;
    final acceptanceStatus = tripState is TripTabSuccessState
        ? tripState.trip.acceptance?.status.trim().toUpperCase()
        : null;
    final hasAcceptedTrip =
        acceptanceStatus == 'ACCEPTED' || acceptanceStatus == 'OVERRIDDEN';
    if (!hasAcceptedTrip && tripState is! TripTabLoadingState) {
      tripCubit.getCurrentTrip();
    }
  }

  Future<void> _openReceiveTrip() async {
    final tripCubit = context.read<TripTabCubit>();
    final accepted = await context.pushNamed<bool>(RoutesNames.receiveTrip);
    if (!mounted || tripCubit.isClosed) return;

    final refresh = tripCubit.getCurrentTrip(forceRefresh: accepted == true);
    if (accepted == true) LayoutCubit.get(context).selectTap(1);
    await refresh;
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        key: _scaffoldKey,
        onDrawerChanged: _onDrawerChanged,
        backgroundColor: AppColors.white0,
        body: const LayoutBody(),
        drawer: AppMenuDrawer(onReceiveCustodyTap: _openReceiveTrip),
      ),
    );

    return BlocListener<AccountCubit, AccountState>(
      listenWhen: (previous, current) =>
          current is AccountLoggedOutState ||
          current is AccountLogoutFailureState,
      listener: (context, state) {
        if (state is AccountLoggedOutState) {
          context.goNamed(RoutesNames.login);
          return;
        }
        if (state is AccountLogoutFailureState) {
          final message = state.errorMessage == 'account_logout_failed'
              ? context.strings.account_logout_failed
              : state.errorMessage;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(context.localizedErrorMessage(message)),
                backgroundColor: AppColors.red0,
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
      child: Material(
        color: AppColors.white0,
        child: BlocSelector<LayoutCubit, LayoutState, bool>(
          selector: (_) => LayoutCubit.get(context).isDrawerFeatureOpen,
          builder: (context, isDrawerFeatureOpen) {
            return PopScope<Object?>(
              canPop: !isDrawerFeatureOpen || _isDrawerOpen,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                if (_isDrawerOpen) {
                  _scaffoldKey.currentState?.closeDrawer();
                } else if (LayoutCubit.get(context).isDrawerFeatureOpen) {
                  LayoutCubit.get(context).closeDrawerFeature();
                }
              },
              child: scaffold,
            );
          },
        ),
      ),
    );
  }
}
