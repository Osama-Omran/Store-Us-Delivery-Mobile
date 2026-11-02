import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:storeus_delivery/features/drawer_features/account/data/models/me_response.dart';
import 'package:storeus_delivery/features/drawer_features/account/data/models/update_profile_request_body.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_state.dart';

class AccountEditProfileDialog extends StatefulWidget {
  const AccountEditProfileDialog({
    super.key,
    required this.user,
  });

  final AccountUser user;

  @override
  State<AccountEditProfileDialog> createState() =>
      _AccountEditProfileDialogState();
}

class _AccountEditProfileDialogState
    extends State<AccountEditProfileDialog> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  late String _initialFirstName;
  late String _initialLastName;
  late String _initialPhone;

  File? _photo;

  @override
  void initState() {
    super.initState();

    // /me currently returns the full name, not separate first/last names.
    final nameParts = widget.user.name
        .trim()
        .split(RegExp(r'\s+'));

    _initialFirstName =
    nameParts.isEmpty ? '' : nameParts.first;

    _initialLastName = nameParts.length > 1
        ? nameParts.skip(1).join(' ')
        : '';

    _initialPhone = widget.user.phone ?? '';

    _firstNameController.text = _initialFirstName;
    _lastNameController.text = _initialLastName;
    _phoneController.text = _initialPhone;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 4096,
      maxHeight: 4096,
    );

    if (picked == null || !mounted) return;

    final extension = picked.path
        .split('.')
        .last
        .toLowerCase();

    const allowedExtensions = [
      'jpg',
      'jpeg',
      'png',
      'webp',
    ];

    if (!allowedExtensions.contains(extension)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('صيغة الصورة غير مدعومة'),
        ),
      );
      return;
    }

    final file = File(picked.path);

    final fileSize = await file.length();

    if (!mounted) return;

    if (fileSize > 5 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حجم الصورة يجب ألا يتجاوز 5 MB'),
        ),
      );
      return;
    }

    setState(() {
      _photo = file;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();

    final body = UpdateProfileRequestBody(
      firstName: firstName != _initialFirstName
          ? firstName
          : null,
      lastName: lastName != _initialLastName
          ? lastName
          : null,
      phone: phone != _initialPhone
          ? phone
          : null,
      photo: _photo,
    );

    if (body.toJson().isEmpty && body.photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لم يتم إجراء أي تغييرات'),
        ),
      );
      return;
    }

    await AccountCubit.get(context).updateProfile(body);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountCubit, AccountState>(
      listenWhen: (_, state) =>
      state is AccountProfileUpdateSuccessState,
      listener: (context, state) {
        Navigator.of(context).pop();
      },
      child: AlertDialog(
        title: const Text('تعديل بيانات الحساب'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الأول',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الأخير',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('اختيار صورة'),
                ),
                if (_photo != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _photo!.path.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
            state is AccountProfileUpdatingState ||
                state is AccountProfileUpdateFailureState,
            builder: (context, state) {
              final loading =
              state is AccountProfileUpdatingState;

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
                    : const Text('حفظ'),
              );
            },
          ),
        ],
      ),
    );
  }
}