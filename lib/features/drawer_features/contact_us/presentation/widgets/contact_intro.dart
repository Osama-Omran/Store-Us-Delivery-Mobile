import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class ContactIntro extends StatelessWidget {
  const ContactIntro({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Center(
        child: Container(
          width: 100,
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.blue4,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.headset_mic_outlined,
            size: 49,
            color: AppColors.primary,
          ),
        ),
      ),
      const SizedBox(height: 20),
      Text(
        context.strings.contact_help_title,
        textAlign: TextAlign.center,
        style: Styles.textStyle24.copyWith(
          fontSize: 27,
          color: AppColors.black1,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        context.strings.contact_help_subtitle,
        textAlign: TextAlign.center,
        style: Styles.textStyle16.copyWith(color: AppColors.grey4),
      ),
    ],
  );
}
