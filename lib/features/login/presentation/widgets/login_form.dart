import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/regex.dart';
import 'package:storeus_delivery/core/widgets/custom_text_field.dart';
import 'package:storeus_delivery/features/login/presentation/cubit/login_cubit.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginCubit cubit = LoginCubit.get(context);
    return Form(
      key: cubit.formKey,
      child: Column(
        spacing: 10,
        children: [
          // const PhoneTextField(),
          CustomTextField(
            controller: cubit.emailController,
            label: context.strings.email,
            hint: context.strings.enter_your_email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (email) {
              if (email?.trim() == null || email!.trim().isEmpty) {
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
            obscureText: true,
            maxLines: 1,
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
