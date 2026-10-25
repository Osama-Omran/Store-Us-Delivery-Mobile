import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/features/login/presentation/cubit/login_cubit.dart';
import 'package:storeus_delivery/features/login/presentation/cubit/login_state.dart';
import 'package:storeus_delivery/features/login/presentation/widgets/app_version.dart';
import 'package:storeus_delivery/features/login/presentation/widgets/login_button.dart';
import 'package:storeus_delivery/features/login/presentation/widgets/login_failure_widget.dart';
import 'package:storeus_delivery/features/login/presentation/widgets/login_form.dart';
import 'package:storeus_delivery/features/login/presentation/widgets/login_header.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
        child: SafeArea(
          child: BlocBuilder<LoginCubit, LoginState>(
            builder: (_, state) {
              return Column(
                spacing: 32,
                children: [
                  const LoginHeader(),
                  const LoginForm(),
                  if (state is LoginFailureState)
                    LoginFailureWidget(error: state.errorMessage),
                  const LoginButton(),
                  AppVersion(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
