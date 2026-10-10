import 'package:storeus_delivery/features/home/presentation/cubit/home_history_cubit.dart';
import 'package:storeus_delivery/features/home/presentation/widgets/home_previous_trips_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/app_assets.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/custom_svg.dart';

import 'package:storeus_delivery/features/home/presentation/cubit/home_cubit.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_state.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(
          create: (_) => getIt<HomeCubit>()..getCurrentTrip(),
        ),
        BlocProvider<HomeHistoryCubit>(
          create: (_) => getIt<HomeHistoryCubit>()..getTripHistory(),
        ),
      ],
      child: const _HomeScreenBody(),
    );
  }
}

class _HomeScreenBody extends StatelessWidget {
  const _HomeScreenBody();

  String? _getTripBadge(BuildContext context, HomeState state) {
    if (state is! HomeSuccessState) return null;

    final status = state.trip.acceptance?.status.trim().toUpperCase();

    return switch (status) {
      'ACCEPTED' => context.strings.currently_on_trip,
      'PENDING' => context.strings.trip_acceptance_pending,
      null || '' => null,
      final value => value,
    };
  }

  @override
  Widget build(BuildContext context) {
    final userName = PreferencesHelper.getUserName()?.trim() ?? '';

    return Scaffold(
      backgroundColor: AppColors.grey0,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return RefreshIndicator(
              color: AppColors.primary,

              onRefresh: () async {
                await Future.wait<void>([
                  HomeCubit.get(context).getCurrentTrip(),
                  HomeHistoryCubit.get(context).getTripHistory(),
                ]);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                children: [
                  // ======= Original Header ======= //
                  _HomeHeader(
                    userName: userName,
                    tripBadge: _getTripBadge(context, state),
                  ),

                  const Gap(24),

                  // ======= Loading ======= //
                  if (state is HomeInitial || state is HomeLoadingState)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 80),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  // ======= Failure ======= //
                  else if (state is HomeFailureState)
                    _HomeMessage(
                      message: state.errorMessage?.isNotEmpty == true
                          ? state.errorMessage!
                          : context.strings.current_trip_load_failed,
                      onRetry: () => HomeCubit.get(context).getCurrentTrip(),
                    )
                  // ======= No Current Trip ======= //
                  else if (state is HomeEmptyState)
                    _HomeMessage(
                      message: context.strings.home_no_current_trip,
                      onRetry: () => HomeCubit.get(context).getCurrentTrip(),
                    )
                  // ======= Current Trip ======= //
                  else if (state is HomeSuccessState)
                    _CurrentTripCard(
                      state: state,
                      onRetryOrders: () =>
                          HomeCubit.get(context).getTripOrders(),
                    ),

                  const Gap(24),

                  HomePreviousTripsSection(
                    currentTripId: state is HomeSuccessState
                        ? state.trip.id
                        : null,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// =====================================================
// Home Header
// =====================================================

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.userName, required this.tripBadge});

  final String userName;
  final String? tripBadge;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                context.strings.welcome,
                style: TextStyle(fontSize: 15, color: AppColors.grey4),
              ),
              if (userName.isNotEmpty)
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black1,
                  ),
                ),
            ],
          ),
        ),

        const Gap(8),

        if (tripBadge != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.blue4,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              tripBadge!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const Gap(10),
        ],

        // ======= Notifications ======= //
        InkWell(
          onTap: () => LayoutCubit.get(context).selectTap(2),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 54,
            height: 54,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white0,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.grey3),
            ),
            child: CustomSVG(assetName: AppAssets.notifications),
          ),
        ),
      ],
    );
  }
}

// =====================================================
// Current Trip Card
// =====================================================

class _CurrentTripCard extends StatelessWidget {
  const _CurrentTripCard({required this.state, required this.onRetryOrders});

  final HomeSuccessState state;
  final VoidCallback onRetryOrders;

  String _nameOrId(String? name, String? id) {
    if (name != null && name.trim().isNotEmpty) return name;
    if (id != null && id.trim().isNotEmpty) return id;
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    final trip = state.trip;

    final vehicleName = _nameOrId(trip.vehicle?.name, trip.vehicle?.id);

    final driverName = _nameOrId(trip.driver?.name, trip.driver?.id);

    final warehouseName = _nameOrId(trip.warehouse?.name, trip.warehouse?.id);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.blue2, AppColors.blue5],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.blue3),
        boxShadow: [
          BoxShadow(
            color: AppColors.black0.withValues(alpha: .04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ======= Trip Header ======= //
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  context.strings.your_current_trip,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black1,
                  ),
                ),
              ),

              const Gap(8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '#${trip.number}',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    color: AppColors.white0,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const Gap(20),

          // ======= Trip Information ======= //
          _TripInfoRow(
            icon: Icons.local_shipping_outlined,
            text: '${context.strings.van}: $vehicleName',
          ),

          const Gap(8),

          _TripInfoRow(text: '${context.strings.driver}: $driverName'),

          const Gap(8),

          _TripInfoRow(icon: Icons.location_on_outlined, text: warehouseName),

          const Gap(20),

          // ======= Orders Statistics ======= //
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: _OrderStatCard(
                  count: trip.ordersSummary?.total,
                  label: context.strings.order,
                  backgroundColor: AppColors.white0,
                  countColor: AppColors.black1,
                  labelColor: AppColors.grey4,
                ),
              ),

              Expanded(
                child: _OrderStatCard(
                  count: state.deliveredOrders,
                  label: context.strings.delivered_orders,
                  backgroundColor: AppColors.green1,
                  countColor: AppColors.green0,
                  labelColor: AppColors.green0,
                ),
              ),

              Expanded(
                child: _OrderStatCard(
                  count: state.remainingOrders,
                  label: context.strings.remaining_orders,
                  backgroundColor: AppColors.orange1,
                  countColor: AppColors.orange0,
                  labelColor: AppColors.orange0,
                ),
              ),
            ],
          ),

          if (state.ordersStatus == HomeOrdersStatus.loading)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(minHeight: 3),
            ),

          if (state.ordersStatus == HomeOrdersStatus.failure)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton.icon(
                onPressed: onRetryOrders,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(context.strings.home_retry_orders),
              ),
            ),

          const Gap(14),

          // ======= Collected Amount ======= //
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            decoration: BoxDecoration(
              color: AppColors.white0,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 21,
                  color: AppColors.grey4,
                ),

                const Gap(8),

                Expanded(
                  child: Text(
                    context.strings.collected_amount,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey4,
                    ),
                  ),
                ),

                Text(
                  '—',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black1,
                  ),
                ),
              ],
            ),
          ),

          const Gap(20),

          // ======= Continue Trip ======= //
          SizedBox(
            height: 70,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                LayoutCubit.get(context).selectTap(1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white0,
                elevation: 5,
                shadowColor: AppColors.primary.withValues(alpha: .24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: [
                  Text(
                    context.strings.continue_trip,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const Icon(Icons.arrow_forward_ios, size: 17),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// Trip Info Row
// =====================================================

class _TripInfoRow extends StatelessWidget {
  const _TripInfoRow({required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SizedBox(
          width: 20,
          child: icon == null
              ? const SizedBox.shrink()
              : Icon(icon, size: 19, color: AppColors.grey4),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 15, height: 1.4, color: AppColors.grey4),
          ),
        ),
      ],
    );
  }
}

// =====================================================
// Statistics Card
// =====================================================

class _OrderStatCard extends StatelessWidget {
  const _OrderStatCard({
    required this.count,
    required this.label,
    required this.backgroundColor,
    required this.countColor,
    required this.labelColor,
  });

  final int? count;
  final String label;
  final Color backgroundColor;
  final Color countColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 2,
        children: [
          Text(
            count?.toString() ?? '—',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: countColor,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: labelColor),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// Empty / Failure
// =====================================================

class _HomeMessage extends StatelessWidget {
  const _HomeMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        spacing: 18,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 54,
            color: AppColors.primary,
          ),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.grey4, fontSize: 15),
          ),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(context.strings.current_trip_retry),
          ),
        ],
      ),
    );
  }
}
