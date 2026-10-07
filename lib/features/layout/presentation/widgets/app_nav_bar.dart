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

class AppNavBar extends StatelessWidget {
  const AppNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(color: AppColors.grey0, height: 14),
              Container(
                height: double.minPositive,
                decoration: BoxDecoration(
                  color: AppColors.white0,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.grey1.withValues(alpha: .7),
                      width: .3,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
      ),
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

  final String icon, title;
  final int index;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LayoutCubit, LayoutState>(
      builder: (_, _) {
        final LayoutCubit cubit = LayoutCubit.get(context);
        final bool selected = cubit.selectedTap == index;
        final bool isTrip = index == 1;
        return CustomInkWell(
          withEffect: false,
          onTap: () => cubit.selectTap(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              if (!isTrip) const Gap(10),
              Container(
                margin: isTrip ? null : const EdgeInsets.only(top: 10),
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
                    if (isTrip)
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: .4),
                        blurRadius: 3,
                        offset: const Offset(0, 4),
                        spreadRadius: 2,
                      ),
                  ],
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isTrip ? 20 : 16,
                  vertical: isTrip ? 20 : 8,
                ),
                child: CustomSVG(
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
              ),
              Text(
                title,
                style: Styles.textStyle14.copyWith(
                  color: selected ? AppColors.primary : null,
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
