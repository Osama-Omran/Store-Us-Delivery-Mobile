/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/widgets/custom_text_field.dart';
import 'package:storeus_delivery/features/login/presentation/cubit/login_cubit.dart';

class PhoneTextField extends StatefulWidget {
  const PhoneTextField({super.key});

  @override
  State<PhoneTextField> createState() => _PhoneTextFieldState();
}

class _PhoneTextFieldState extends State<PhoneTextField> {
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: LoginCubit.get(context).phoneController,
      maxLines: 1,
      maxLength: 11,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (number) {
        if (number?.trim() == null || (number?.trim().isEmpty ?? true)) {
          return context.strings.phone_number_is_required;
        }
        if (number!.trim().length != 11) {
          return context.strings.invalid_phone_number;
        }
        return null;
      },
      hint: context.strings.phone_number,
      textInputAction: TextInputAction.next,
    );
  }
}
*/
