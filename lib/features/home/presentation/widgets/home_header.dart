import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/app_assets.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/custom_svg.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_state.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.userName,
    required this.tripBadge,
  });

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
            child: Stack(
              children: [
                CustomSVG(assetName: AppAssets.notifications),
                BlocBuilder<NotificationsCubit, NotificationsState>(
                  builder: (context, notificationState) {
                    final unreadCount =
                        notificationState is NotificationsSuccessState
                        ? notificationState.unreadCount
                        : 0;

                    if (unreadCount <= 0) {
                      return const SizedBox.shrink();
                    }

                    return unreadCount > 0
                        ? Container(
                            width: 10,
                            height: 10,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.red1,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.white0,
                                width: 1.5,
                              ),
                            ),
                          )
                        : const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
