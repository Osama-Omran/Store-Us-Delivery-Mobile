import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/core/widgets/custom_text_field.dart';

import '../cubit/direct_sale_cubit.dart';
import '../cubit/direct_sale_state.dart';
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
          const _TerritoryDropdown(),
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
              text: required ? ' *' : context.strings.optional_field_suffix,
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

class _TerritoryDropdown extends StatelessWidget {
  const _TerritoryDropdown();

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<DirectSaleCubit, DirectSaleState>(
    buildWhen: (previous, current) =>
        previous.territories != current.territories ||
        previous.selectedTerritory != current.selectedTerritory ||
        previous.loadingCustomerOptions != current.loadingCustomerOptions ||
        previous.customerOptionsLoaded != current.customerOptionsLoaded ||
        previous.customerOptionsError != current.customerOptionsError ||
        previous.creatingCustomer != current.creatingCustomer,
    builder: (context, state) {
      final cubit = DirectSaleCubit.get(context);
      final enabled =
          state.customerOptionsLoaded &&
          !state.loadingCustomerOptions &&
          !state.creatingCustomer &&
          state.territories.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              text: context.strings.direct_sale_territory,
              style: Styles.textStyle16.copyWith(color: AppColors.black1),
              children: [
                TextSpan(
                  text: ' *',
                  style: Styles.textStyle14.copyWith(color: AppColors.red1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            // Recreate the FormField when loading changes or selection resets.
            key: ValueKey(
              '${state.customerOptionsLoaded}:${state.selectedTerritory}',
            ),
            initialValue: state.selectedTerritory,
            isExpanded: true,
            menuMaxHeight: 320,
            decoration: InputDecoration(
              hintText: state.loadingCustomerOptions
                  ? context.strings.direct_sale_territory_loading
                  : context.strings.direct_sale_territory_hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              hintStyle: Styles.textStyle14,
              fillColor: AppColors.white0,
              filled: true,
              errorMaxLines: 3,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppColors.grey3),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppColors.grey3),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppColors.red0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppColors.red0),
              ),
            ),
            items: state.territories
                .map(
                  (territory) => DropdownMenuItem<String>(
                    value: territory,
                    child: Text(territory, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: enabled ? cubit.selectTerritory : null,
            validator: (value) =>
                value != null && state.territories.contains(value)
                ? null
                : context.strings.direct_sale_territory_required,
          ),
          if (state.loadingCustomerOptions) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
          ],
          if (state.customerOptionsError != null) ...[
            const SizedBox(height: 8),
            Text(
              state.customerOptionsError == 'empty'
                  ? context.strings.direct_sale_territory_empty
                  : context.strings.direct_sale_territory_load_failed,
              style: Styles.textStyle14.copyWith(color: AppColors.red1),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => cubit.loadCustomerOptions(force: true),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(context.strings.direct_sale_territory_retry),
              ),
            ),
          ],
        ],
      );
    },
  );
}
