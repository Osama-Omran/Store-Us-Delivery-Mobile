import 'package:flutter/material.dart';
import 'package:storeus_delivery/features/login/presentation/widgets/app_version.dart';
import 'package:storeus_delivery/features/login/presentation/widgets/login_button.dart';
import 'package:storeus_delivery/features/login/presentation/widgets/login_form.dart';
import 'package:storeus_delivery/features/login/presentation/widgets/login_header.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 60, horizontal: 16),
        child: SafeArea(
          child: Column(
            spacing: 32,
            children: [LoginHeader(), LoginForm(), LoginButton(), AppVersion()],
          ),
        ),
      ),
    );
  }
}
