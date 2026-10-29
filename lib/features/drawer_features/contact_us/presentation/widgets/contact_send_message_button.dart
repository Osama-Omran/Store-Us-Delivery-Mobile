import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/contact_cubit.dart';
import 'contact_message_sheet.dart';
import 'contact_action_button.dart';

class ContactSendMessageButton extends StatelessWidget {
  const ContactSendMessageButton({super.key, this.tripId});
  final int? tripId;

  Future<void> _openMessageSheet(BuildContext context) async {
    final cubit = context.read<ContactCubit>();
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: AppColors.white0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: ContactMessageSheet(tripId: tripId),
      ),
    );

    if (!context.mounted || submitted != true) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.green0,
          content: Text(context.strings.contact_send_success),
        ),
      );
  }

  @override
  Widget build(BuildContext context) => ContactActionButton(
    title: context.strings.contact_send_message,
    backgroundColor: AppColors.white0,
    foregroundColor: AppColors.black1,
    outlined: true,
    onPressed: () => _openMessageSheet(context),
  );
}
