import 'package:flutter/material.dart';
import 'package:storeus_delivery/features/login/presentation/widgets/app_version.dart';
import 'package:storeus_delivery/features/login/presentation/widgets/login_button.dart';
import 'package:storeus_delivery/features/login/presentation/widgets/login_failure_widget.dart';
import 'package:storeus_delivery/features/login/presentation/widgets/login_form.dart';
import 'package:storeus_delivery/features/login/presentation/widgets/login_header.dart';

class LoginBody extends StatelessWidget {
  const LoginBody({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: constraints.maxHeight < 600 ? 32 : 48,
            horizontal: 16,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: const Column(
                children: [
                  LoginHeader(),
                  SizedBox(height: 32),
                  LoginForm(),
                  LoginFailureWidget(),
                  SizedBox(height: 32),
                  LoginButton(),
                  SizedBox(height: 32),
                  AppVersion(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
