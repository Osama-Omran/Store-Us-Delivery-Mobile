import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class OrderAddressFields extends StatelessWidget {
  const OrderAddressFields({
    super.key,
    required this.addressController,
    required this.phoneController,
    required this.cityController,
    required this.countryController,
    required this.notesController,
  });

  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController cityController;
  final TextEditingController countryController;
  final TextEditingController notesController;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // ======= Address Field ======= //
      Text(
        context.strings.order_correct_address,
        style: Styles.textStyle16.copyWith(
          color: AppColors.black1,
          fontWeight: FontWeight.w700,
        ),
      ),

      const SizedBox(height: 8),

      TextField(
        controller: addressController,
        textDirection: TextDirection.rtl,
        maxLines: 3,
        minLines: 2,
        decoration: _inputDecoration(),
      ),

      const SizedBox(height: 18),

      // ======= Shop Phone ======= //
      Text(
        context.strings.order_delivery_phone,
        style: Styles.textStyle16.copyWith(
          color: AppColors.black1,
          fontWeight: FontWeight.w700,
        ),
      ),

      const SizedBox(height: 8),

      TextField(
        controller: phoneController,
        keyboardType: TextInputType.phone,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
        decoration: _inputDecoration().copyWith(
          hintText: context.strings.order_phone_hint,
        ),
      ),

      const SizedBox(height: 18),

      // ======= City ======= //
      Text(
        context.strings.order_delivery_city,
        style: Styles.textStyle16.copyWith(
          color: AppColors.black1,
          fontWeight: FontWeight.w700,
        ),
      ),

      const SizedBox(height: 8),

      TextField(
        controller: cityController,
        textDirection: TextDirection.rtl,
        decoration: _inputDecoration().copyWith(
          hintText: context.strings.order_delivery_city_hint,
        ),
      ),

      const SizedBox(height: 18),

      // ======= Country ======= //
      Text(
        context.strings.order_delivery_country,
        style: Styles.textStyle16.copyWith(
          color: AppColors.black1,
          fontWeight: FontWeight.w700,
        ),
      ),

      const SizedBox(height: 8),

      TextField(
        controller: countryController,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
        decoration: _inputDecoration().copyWith(
          hintText: context.strings.order_country_hint,
        ),
      ),

      const SizedBox(height: 18),

      Text(
        context.strings.order_optional_notes,
        style: Styles.textStyle16.copyWith(
          color: AppColors.black1,
          fontWeight: FontWeight.w700,
        ),
      ),

      const SizedBox(height: 8),

      TextField(
        controller: notesController,
        textDirection: TextDirection.rtl,
        minLines: 2,
        maxLines: 3,
        decoration: _inputDecoration(),
      ),

      const SizedBox(height: 14),
    ],
  );

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.grey0,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: AppColors.grey3),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: AppColors.grey3),
      ),
    );
  }
}
