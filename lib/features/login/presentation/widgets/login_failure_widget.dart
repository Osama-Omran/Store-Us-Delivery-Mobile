import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/login/presentation/cubit/login_cubit.dart';
import 'package:storeus_delivery/features/login/presentation/cubit/login_state.dart';

class LoginFailureWidget extends StatelessWidget {
  const LoginFailureWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        if (state is! LoginFailureState) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.loginErrorBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(
              child: Text(
                context.localizedErrorMessage(state.errorMessage),
                textAlign: TextAlign.center,
                style: Styles.textStyle14.copyWith(
                  color: AppColors.loginErrorForeground,
                  height: 1.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
