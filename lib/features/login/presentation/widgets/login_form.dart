import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/regex.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/custom_text_field.dart';
import 'package:storeus_delivery/features/login/presentation/cubit/login_cubit.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscurePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final LoginCubit cubit = LoginCubit.get(context);

    return Form(
      key: cubit.formKey,
      child: Column(
        spacing: 10,
        children: [
          CustomTextField(
            controller: cubit.emailController,
            label: context.strings.email,
            hint: context.strings.enter_your_email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (email) {
              if (email == null || email.trim().isEmpty) {
                return context.strings.email_is_required;
              }
              if (!Regex.isValidEmail(email)) {
                return context.strings.please_enter_a_valid_email;
              }
              return null;
            },
          ),

          CustomTextField(
            controller: cubit.passwordController,
            label: context.strings.password,
            hint: context.strings.password,
            obscureText: _obscurePassword,
            maxLines: 1,
            suffixIcon: IconButton(
              onPressed: _togglePasswordVisibility,
              tooltip: _obscurePassword
                  ? context.strings.show_password
                  : context.strings.hide_password,
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.grey4,
                size: 22,
              ),
            ),
            validator: (password) {
              if (password?.trim().isNullOrEmpty() ?? true) {
                return context.strings.password_is_required;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
