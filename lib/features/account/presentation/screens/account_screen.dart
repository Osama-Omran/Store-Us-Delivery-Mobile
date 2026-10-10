import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/core/widgets/custom_app_bar.dart';

import 'package:storeus_delivery/features/account/data/models/me_response.dart';
import 'package:storeus_delivery/features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/account/presentation/cubit/account_state.dart';
import 'package:storeus_delivery/features/account/presentation/widgets/account_dashboard_sections.dart';
import 'package:storeus_delivery/features/account/presentation/widgets/account_header_card.dart';
import 'package:storeus_delivery/features/account/presentation/widgets/account_logout_button.dart';
import 'package:storeus_delivery/features/account/presentation/widgets/account_personal_info_card.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, this.isOnTrip = false});

  final bool isOnTrip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey0,
      appBar: CustomAppBar(title: context.strings.account),
      body: BlocConsumer<AccountCubit, AccountState>(
        listener: (_, state) {
          if (state is AccountLoggedOutState) {
            GoRouter.of(context).go(RoutesNames.login);
          }
        },
        builder: (context, state) {
          if (state is AccountInitial || state is AccountLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AccountFailureState) {
            return _AccountErrorView(
              message: state.errorMessage == 'account_load_failed'
                  ? context.strings.account_load_failed
                  : state.errorMessage,
            );
          }

          final AccountUser? user;
          final bool isLoggingOut;

          if (state is AccountSuccessState) {
            user = state.user;
            isLoggingOut = false;
          } else if (state is AccountLoggingOutState) {
            user = state.user;
            isLoggingOut = true;
          } else if (state is AccountLogoutFailureState) {
            user = state.user;
            isLoggingOut = false;
          } else {
            user = null;
            isLoggingOut = false;
          }

          if (user == null) {
            return const SizedBox.shrink();
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => AccountCubit.get(context).getMe(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                // ======= Account Header ======= //
                AccountHeaderCard(user: user, isOnTrip: isOnTrip),

                const Gap(20),

                // ======= Personal Information ======= //
                AccountPersonalInfoCard(user: user),

                const Gap(20),

                // ======= Wallet / Stats / Sync ======= //
                AccountDashboardSections(userName: user.name),

                const Gap(20),

                // ======= Logout ======= //
                AccountLogoutButton(
                  isLoading: isLoggingOut,
                  onPressed: () async {
                    final confirmed = await showAccountLogoutConfirmation(
                      context,
                    );

                    if (!context.mounted || !confirmed) {
                      return;
                    }

                    AccountCubit.get(context).logout();
                  },
                ),

                const Gap(24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AccountErrorView extends StatelessWidget {
  const _AccountErrorView({required this.message});

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
            Icon(Icons.error_outline_rounded, color: AppColors.red1, size: 42),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Styles.textStyle14.copyWith(color: AppColors.grey4),
            ),
            OutlinedButton(
              onPressed: () {
                AccountCubit.get(context).getMe();
              },
              child: Text(context.strings.account_retry),
            ),
          ],
        ),
      ),
    );
  }
}
