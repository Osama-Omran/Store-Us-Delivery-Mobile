import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.validator,
    this.maxLines,
    this.maxLength,
    this.inputFormatters,
    this.prefixIcon,
    this.controller,
  });
  final String? label, hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final int? maxLines, maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        if (label != null) Text(label!),
        TextFormField(
          controller: controller,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          textInputAction: textInputAction,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            hintText: hint,
            hintStyle: Styles.textStyle14,
            fillColor: AppColors.white0,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: AppColors.grey2, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: AppColors.grey2, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: AppColors.black0, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: AppColors.red0, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: AppColors.red0, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
