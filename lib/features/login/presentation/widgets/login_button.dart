import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/widgets/custom_button.dart';
import 'package:storeus_delivery/features/login/presentation/cubit/login_cubit.dart';
import 'package:storeus_delivery/features/login/presentation/cubit/login_state.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (_, state) {
        if (state is LoginSuccessState) {
          GoRouter.of(context).go(RoutesNames.layout);
        }
      },
      child: CustomButton(
        text: context.strings.login,
        onPressed: () => LoginCubit.get(context).validateToLogin(),
      ),
    );
  }
}
