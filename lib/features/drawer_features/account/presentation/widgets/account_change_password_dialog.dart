import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/features/drawer_features/account/data/models/change_password_request_body.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_state.dart';

class AccountChangePasswordDialog extends StatefulWidget {
  const AccountChangePasswordDialog({super.key});

  @override
  State<AccountChangePasswordDialog> createState() =>
      _AccountChangePasswordDialogState();
}

class _AccountChangePasswordDialogState
    extends State<AccountChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final body = ChangePasswordRequestBody(
      currentPassword: _currentPasswordController.text,
      password: _passwordController.text,
      passwordConfirmation: _confirmationController.text,
    );

    await AccountCubit.get(context).changePassword(body);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تغيير كلمة المرور'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'أدخل كلمة المرور الحالية';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                ),
                validator: (value) {
                  if (value == null || value.length < 12) {
                    return 'كلمة المرور يجب ألا تقل عن 12 حرفًا';
                  }

                  if (value == _currentPasswordController.text) {
                    return 'يجب أن تختلف عن كلمة المرور الحالية';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmationController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'تأكيد كلمة المرور غير مطابق';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        BlocBuilder<AccountCubit, AccountState>(
          buildWhen: (_, state) =>
          state is AccountPasswordChangingState ||
              state is AccountPasswordChangeFailureState,
          builder: (context, state) {
            final loading =
            state is AccountPasswordChangingState;

            return ElevatedButton(
              onPressed: loading ? null : _submit,
              child: loading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Text('تغيير كلمة المرور'),
            );
          },
        ),
      ],
    );
  }
}