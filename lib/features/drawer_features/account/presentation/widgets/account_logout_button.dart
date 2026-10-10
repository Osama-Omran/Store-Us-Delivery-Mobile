
import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/core/widgets/custom_button.dart';

Future<bool> showAccountLogoutConfirmation(
    BuildContext context,
    ) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.white0,
        title: Text(
          context.strings.account_logout_confirm_title,
          style: Styles.textStyle18,
        ),
        content: Text(
          context.strings.account_logout_confirm_description,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: Text(
              context.strings.account_cancel,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: Text(
              context.strings.logout,
              style: TextStyle(
                color: AppColors.red1,
              ),
            ),
          ),
        ],
      );
    },
  );

  return confirmed ?? false;
}

class AccountLogoutButton extends StatelessWidget {
  const AccountLogoutButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      height: 66,
      radius: 25,
      withShadow: false,
      isActive: !isLoading,
      color: AppColors.red1.withValues(alpha: .10),
      borderColor: AppColors.red1.withValues(alpha: .40),
      borderThickness: 1.5,
      text: isLoading ? null : context.strings.logout,
      icon: isLoading
          ? SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          color: AppColors.red1,
          strokeWidth: 2,
        ),
      )
          : Icon(
        Icons.logout_rounded,
        color: AppColors.red1,
      ),
      textStyle: Styles.textStyle18.copyWith(
        color: AppColors.red1,
      ),
      onPressed: onPressed,
    );
  }
}
