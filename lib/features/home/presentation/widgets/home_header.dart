import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/app_assets.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/custom_svg.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.strings.welcome,
                style: Styles.base.copyWith(
                  fontSize: 14,
                  color: AppColors.grey4,
                ),
              ),
              if (userName.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  userName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.textStyle27.copyWith(
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black1,
                  ),
                ),
              ],
              if (tripBadge != null) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blue4,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            tripBadge!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Styles.textStyle12.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: AppColors.white0,
          borderRadius: BorderRadius.circular(17),
          child: InkWell(
            onTap: () => LayoutCubit.get(context).selectTap(2),
            borderRadius: BorderRadius.circular(17),
            child: Container(
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: AppColors.grey3),
              ),
              child: Stack(
                children: [
                  CustomSVG(assetName: AppAssets.notifications),
                  PositionedDirectional(
                    top: 0,
                    end: 0,
                    child: BlocBuilder<NotificationsCubit, NotificationsState>(
                      builder: (context, notificationState) {
                        final unreadCount =
                            notificationState is NotificationsSuccessState
                            ? notificationState.unreadCount
                            : 0;
                        if (unreadCount <= 0) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.red1,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white0,
                              width: 1.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
