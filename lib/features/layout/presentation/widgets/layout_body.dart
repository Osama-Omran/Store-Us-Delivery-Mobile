import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/custom_loading_indicator.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_state.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_state.dart';
import 'package:storeus_delivery/features/layout/presentation/widgets/app_nav_bar.dart';

class LayoutBody extends StatelessWidget {
  const LayoutBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocBuilder<LayoutCubit, LayoutState>(
          builder: (context, state) => LayoutCubit.get(context).currentScreen,
        ),
        const Positioned(left: 0, right: 0, bottom: 0, child: AppNavBar()),
        const _LogoutLoadingOverlay(),
      ],
    );
  }
}

class _LogoutLoadingOverlay extends StatelessWidget {
  const _LogoutLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AccountCubit, AccountState, bool>(
      selector: (state) => state is AccountLoggingOutState,
      builder: (context, loading) {
        if (!loading) return const SizedBox.shrink();

        return Positioned.fill(
          child: Container(
            color: AppColors.black1.withValues(alpha: 0.18),
            alignment: Alignment.center,
            child: const CustomLoadingIndicator(size: 84, primaryColor: true),
          ),
        );
      },
    );
  }
}
