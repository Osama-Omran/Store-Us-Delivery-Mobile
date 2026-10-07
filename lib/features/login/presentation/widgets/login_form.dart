import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/widgets/custom_text_field.dart';
import 'package:storeus_delivery/features/login/presentation/cubit/login_cubit.dart';
import 'package:storeus_delivery/features/login/presentation/widgets/phone_text_field.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: LoginCubit.get(context).formKey,
      child: Column(
        spacing: 10,
        children: [
          const PhoneTextField(),
          CustomTextField(
            label: context.strings.password,
            hint: context.strings.password,
            obscureText: true,
            maxLines: 1,
            validator: (password) {
              if(password?.trim().isNullOrEmpty() ?? true) return context.strings.password_is_required;
              return null;
            },
          ),
        ],
      ),
    );
  }
}
