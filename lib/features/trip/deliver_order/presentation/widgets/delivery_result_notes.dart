import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class DeliveryResultNotes extends StatelessWidget {
  const DeliveryResultNotes({
    super.key,
    required this.controller,
    required this.onHideKeyboard,
  });
  final TextEditingController controller;
  final VoidCallback onHideKeyboard;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        context.strings.delivery_notes_title,
        style: Styles.textStyle17.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.black1,
        ),
      ),

      const SizedBox(height: 10),

      TextField(
        controller: controller,
        minLines: 3,
        maxLines: 4,

        onTapOutside: (_) {
          onHideKeyboard();
        },

        decoration: InputDecoration(
          hintText: context.strings.delivery_notes_hint,
          filled: true,
          fillColor: AppColors.white0,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),

      const SizedBox(height: 12),

      Text(
        context.strings.delivery_reason_not_sent,
        style: Styles.base.copyWith(fontSize: 12, color: AppColors.grey4),
      ),
    ],
  );
}
