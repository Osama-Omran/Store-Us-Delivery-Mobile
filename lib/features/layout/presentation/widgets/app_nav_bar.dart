import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/app_assets.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/core/widgets/custom_ink_well.dart';
import 'package:storeus_delivery/core/widgets/custom_svg.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_state.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/utils/trip_badge_counts.dart';

class AppNavBar extends StatelessWidget {
  const AppNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ======= Navbar Background ======= //
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(color: AppColors.transparent, height: 14),
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.white0,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                border: Border(
                  top: BorderSide(
                    color: AppColors.grey1.withValues(alpha: 0.45),
                    width: 0.5,
                  ),
                  left: BorderSide(
                    color: AppColors.grey1.withValues(alpha: 0.45),
                    width: 0.5,
                  ),
                  right: BorderSide(
                    color: AppColors.grey1.withValues(alpha: 0.45),
                    width: 0.5,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black1.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ======= Navbar Items ======= //
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: NavBarItem(
                icon: AppAssets.home,
                title: context.strings.home,
                index: 0,
              ),
            ),
            Expanded(
              child: NavBarItem(
                icon: AppAssets.van,
                title: context.strings.trip,
                index: 1,
              ),
            ),
            Expanded(
              child: NavBarItem(
                icon: AppAssets.notifications,
                title: context.strings.notifications,
                index: 2,
              ),
            ),
            Expanded(
              child: NavBarItem(
                icon: AppAssets.menu,
                title: context.strings.menu,
                index: 3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class NavBarItem extends StatelessWidget {
  const NavBarItem({
    super.key,
    required this.icon,
    required this.title,
    required this.index,
  });

  final String icon;
  final String title;
  final int index;

  @override
  Widget build(BuildContext context) {
    final menuBadgeCount = index == 3
        ? context.select<TripTabCubit, int>(
            (cubit) => getTripBadgeCounts(cubit.state).receiveVehicle,
          )
        : 0;

    return BlocBuilder<LayoutCubit, LayoutState>(
      builder: (context, state) {
        final cubit = LayoutCubit.get(context);

        final selected = cubit.selectedTap == index;
        final isTrip = index == 1;
        final isNotifications = index == 2;

        return CustomInkWell(
          withEffect: false,

          onTap: () {
            // ======= Open Drawer ======= //
            if (index == 3) {
              Scaffold.of(context).openDrawer();
              return;
            }

            // ======= Refresh Notifications ======= //
            if (isNotifications && cubit.selectedTap != index) {
              context.read<NotificationsCubit>().getNotifications();
            }

            // ======= Select Tab ======= //
            cubit.selectTap(index);
          },

          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              if (!isTrip) const Gap(10),

              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 190),
                    curve: Curves.easeOutCubic,
                    margin: isTrip ? null : const EdgeInsets.only(top: 10),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTrip ? 20 : 16,
                      vertical: isTrip ? 20 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? isTrip
                                ? AppColors.primary
                                : AppColors.lightPrimary
                          : isTrip
                          ? AppColors.lightPrimary
                          : null,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        if (isTrip && selected)
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.22),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),

                    // ======= Icon + Real Notification Badge ======= //
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        CustomSVG(
                          assetName: icon,
                          color: selected
                              ? isTrip
                                    ? AppColors.white0
                                    : AppColors.primary
                              : isTrip
                              ? AppColors.primary
                              : AppColors.grey2,
                          w: 24,
                        ),

                        if (isNotifications)
                          PositionedDirectional(
                            top: -12,
                            end: -14,
                            child:
                                BlocBuilder<
                                  NotificationsCubit,
                                  NotificationsState
                                >(
                                  builder: (context, notificationState) {
                                    final unreadCount =
                                        notificationState
                                            is NotificationsSuccessState
                                        ? notificationState.unreadCount
                                        : 0;

                                    if (unreadCount <= 0) {
                                      return const SizedBox.shrink();
                                    }

                                    return Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 20,
                                        minHeight: 20,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: AppColors.red1,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppColors.white0,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        unreadCount > 99
                                            ? '99+'
                                            : '$unreadCount',
                                        style: Styles.textStyle10.copyWith(
                                          color: AppColors.white0,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          ),
                      ],
                    ),
                  ),

                  if (index == 3 && menuBadgeCount > 0)
                    PositionedDirectional(
                      top: 3,
                      end: -5,
                      child: Container(
                        height: 20,
                        constraints: const BoxConstraints(minWidth: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.red0,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$menuBadgeCount',
                          style: Styles.textStyle11.copyWith(
                            color: AppColors.white0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // ======= Tab Title ======= //
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Styles.textStyle14.copyWith(
                  color: selected ? AppColors.primary : AppColors.grey4,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
