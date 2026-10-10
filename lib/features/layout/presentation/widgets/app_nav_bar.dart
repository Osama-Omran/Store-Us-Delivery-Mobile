
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
            Container(
              color: Colors.transparent,
              height: 14,
            ),
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.white0,
                border: Border(
                  top: BorderSide(
                    color: AppColors.grey1.withValues(
                      alpha: .7,
                    ),
                    width: .3,
                  ),
                ),
              ),
            ),
          ],
        ),

        // ======= Navbar Items ======= //
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavBarItem(
              icon: AppAssets.home,
              title: context.strings.home,
              index: 0,
            ),
            NavBarItem(
              icon: AppAssets.van,
              title: context.strings.trip,
              index: 1,
            ),
            NavBarItem(
              icon: AppAssets.notifications,
              title: context.strings.notifications,
              index: 2,
            ),
            NavBarItem(
              icon: AppAssets.menu,
              title: context.strings.menu,
              index: 3,
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
            if (isNotifications &&
                cubit.selectedTap != index) {
              context
                  .read<NotificationsCubit>()
                  .getNotifications();
            }

            // ======= Select Tab ======= //
            cubit.selectTap(index);
          },

          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              if (!isTrip) const Gap(10),

              Container(
                margin: isTrip
                    ? null
                    : const EdgeInsets.only(top: 10),
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
                        color: AppColors.primary.withValues(
                          alpha: .4,
                        ),
                        blurRadius: 3,
                        offset: const Offset(0, 4),
                        spreadRadius: 2,
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
                        child: BlocBuilder<
                            NotificationsCubit,
                            NotificationsState>(
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
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.red1,
                                borderRadius:
                                BorderRadius.circular(20),
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

              // ======= Tab Title ======= //
              Text(
                title,
                style: Styles.textStyle14.copyWith(
                  color:
                  selected ? AppColors.primary : null,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
