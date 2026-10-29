import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_state.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/widgets/account_dashboard_sections.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/widgets/account_header_card.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/widgets/account_logout_button.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/widgets/account_personal_info_card.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/widgets/account_shimmer.dart';

class AccountBody extends StatelessWidget {
  const AccountBody({super.key, this.isOnTrip = false});

  final bool isOnTrip;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      // Logout loading is handled by its own button, not the whole page.
      buildWhen: (_, state) =>
          state is AccountInitial ||
          state is AccountLoadingState ||
          state is AccountSuccessState ||
          state is AccountFailureState,
      builder: (context, state) {
        if (state is AccountFailureState) {
          return _AccountError(message: state.errorMessage);
        }

        if (AccountCubit.get(context).currentUser == null) {
          return const AccountShimmer();
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => AccountCubit.get(context).getMe(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              AccountHeaderCard(isOnTrip: isOnTrip),
              const Gap(16),
              AccountPersonalInfoCard(),
              const Gap(16),
              AccountDashboardSections(),
              const Gap(16),
              const AccountLogoutButton(),
            ],
          ),
        );
      },
    );
  }
}

class _AccountError extends StatelessWidget {
  const _AccountError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.red1,
              size: 42,
            ),
            Text(
              context.localizedErrorMessage(
                message == 'account_load_failed'
                    ? context.strings.account_load_failed
                    : message,
              ),
              textAlign: TextAlign.center,
              style: Styles.textStyle14.copyWith(color: AppColors.grey4),
            ),
            OutlinedButton(
              onPressed: () => AccountCubit.get(context).getMe(),
              child: Text(context.strings.account_retry),
            ),
          ],
        ),
      ),
    );
  }
}
