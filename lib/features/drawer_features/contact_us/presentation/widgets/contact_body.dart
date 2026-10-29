import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import 'contact_intro.dart';
import 'contact_support_actions.dart';
import 'contact_send_message_button.dart';

class ContactBody extends StatelessWidget {
  const ContactBody({super.key, this.tripId});
  final int? tripId;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.grey0,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.grey3)),
              ),
              child: Text(
                context.strings.contact_us,
                textAlign: TextAlign.center,
                style: Styles.textStyle20.copyWith(
                  fontSize: 22,
                  color: AppColors.black1,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 125),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ContactIntro(),
                    const SizedBox(height: 22),
                    const ContactSupportActions(),
                    const SizedBox(height: 18),
                    ContactSendMessageButton(tripId: tripId),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
