import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

class LoginFailureWidget extends StatelessWidget {
  const LoginFailureWidget({super.key, required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.loginErrorBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Center(
        child: Text(
          context.localizedErrorMessage(error),
          textAlign: TextAlign.center,
          style: Styles.textStyle14.copyWith(
            color: AppColors.loginErrorForeground,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
