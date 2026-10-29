import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/core/widgets/custom_button.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_state.dart';

Future<bool> showAccountLogoutConfirmation(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.white0,
      title: Text(
        context.strings.account_logout_confirm_title,
        style: Styles.textStyle18,
      ),
      content: Text(context.strings.account_logout_confirm_description),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(context.strings.account_cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            context.strings.logout,
            style: Styles.base.copyWith(color: AppColors.red1),
          ),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}

class AccountLogoutButton extends StatelessWidget {
  const AccountLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      buildWhen: (previous, current) =>
          previous is AccountLoggingOutState ||
          current is AccountLoggingOutState ||
          current is AccountLogoutFailureState,
      builder: (context, state) {
        final loading = state is AccountLoggingOutState;
        return CustomButton(
          height: 52,
          radius: 16,
          withShadow: false,
          isActive: !loading,
          color: AppColors.red1.withValues(alpha: .10),
          borderColor: AppColors.red1.withValues(alpha: .40),
          borderThickness: 1.5,
          text: loading ? null : context.strings.logout,
          icon: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.red1,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.logout_rounded, color: AppColors.red1),
          textStyle: Styles.textStyle16.copyWith(color: AppColors.red1),
          onPressed: () async {
            final confirmed = await showAccountLogoutConfirmation(context);
            if (!context.mounted || !confirmed) return;
            AccountCubit.get(context).logout();
          },
        );
      },
    );
  }
}
