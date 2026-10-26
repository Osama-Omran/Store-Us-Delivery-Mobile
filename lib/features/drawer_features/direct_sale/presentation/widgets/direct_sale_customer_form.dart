import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/core/widgets/custom_text_field.dart';

import '../cubit/direct_sale_cubit.dart';
import '../utils/direct_sale_input.dart';

class DirectSaleCustomerForm extends StatelessWidget {
  const DirectSaleCustomerForm({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = DirectSaleCubit.get(context);
    return Form(
      key: cubit.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        spacing: 18,
        children: [
          _CustomerField(
            label: context.strings.direct_sale_name,
            required: true,
            controller: cubit.nameController,
            hint: context.strings.direct_sale_name_hint,
            validator: (value) => value?.trim().isNotEmpty == true
                ? null
                : context.strings.direct_sale_name_required,
          ),
          _CustomerField(
            label: context.strings.direct_sale_phone,
            required: true,
            controller: cubit.phoneController,
            hint: context.strings.direct_sale_phone_hint,
            phone: true,
            validator: (value) => isValidDirectSalePhone(value ?? '')
                ? null
                : context.strings.direct_sale_phone_invalid,
          ),
          _CustomerField(
            label: context.strings.direct_sale_address,
            controller: cubit.addressController,
          ),
          _CustomerField(
            label: context.strings.direct_sale_territory,
            controller: cubit.areaController,
            required: true,
            hint: context.strings.direct_sale_territory_hint,
            validator: (value) => value?.trim().isNotEmpty == true
                ? null
                : context.strings.direct_sale_territory_required,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              context.strings.direct_sale_customer_defaults,
              style: Styles.textStyle14.copyWith(color: AppColors.grey4),
            ),
          ),
          _CustomerField(
            label: context.strings.direct_sale_notes,
            controller: cubit.notesController,
            last: true,
          ),
        ],
      ),
    );
  }
}

class _CustomerField extends StatelessWidget {
  const _CustomerField({
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.required = false,
    this.phone = false,
    this.last = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final bool required;
  final bool phone;
  final bool last;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 8,
    children: [
      Text.rich(
        TextSpan(
          text: label,
          style: Styles.textStyle16.copyWith(color: AppColors.black1),
          children: [
            TextSpan(
              text: required
                  ? ' *'
                  : ' ${context.strings.direct_sale_optional}',
              style: Styles.textStyle14.copyWith(
                color: required ? AppColors.red1 : AppColors.grey4,
              ),
            ),
          ],
        ),
      ),
      Directionality(
        textDirection: phone ? TextDirection.ltr : TextDirection.rtl,
        child: CustomTextField(
          controller: controller,
          hint: hint,
          validator: validator,
          maxLines: 1,
          keyboardType: phone ? TextInputType.phone : TextInputType.text,
          inputFormatters: phone
              ? [FilteringTextInputFormatter.allow(RegExp('[0-9٠-٩۰-۹]'))]
              : null,
          textInputAction: last ? TextInputAction.done : TextInputAction.next,
        ),
      ),
    ],
  );
}
