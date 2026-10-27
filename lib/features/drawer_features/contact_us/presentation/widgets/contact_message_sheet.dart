import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/presentation/cubit/contact_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/presentation/cubit/contact_state.dart';

class ContactMessageSheet extends StatefulWidget {
  const ContactMessageSheet({super.key, this.tripId});

  final int? tripId;

  @override
  State<ContactMessageSheet> createState() => _ContactMessageSheetState();
}

class _ContactMessageSheetState extends State<ContactMessageSheet> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _message = TextEditingController();

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<ContactCubit>().sendMessage(
      subject: _subject.text,
      message: _message.text,
      tripId: widget.tripId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactCubit, ContactState>(
      listenWhen: (previous, current) => !previous.sent && current.sent,
      listener: (context, _) => Navigator.of(context).pop(true),
      child: BlocBuilder<ContactCubit, ContactState>(
        buildWhen: (a, b) =>
            a.sending != b.sending || a.sendError != b.sendError,
        builder: (context, state) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: PopScope(
              canPop: !state.sending,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  MediaQuery.viewInsetsOf(context).bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.strings.contact_send_message,
                          style: Styles.textStyle20.copyWith(
                            color: AppColors.black1,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _subject,
                          enabled: !state.sending,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: context.strings.contact_subject,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? context.strings.contact_subject_required
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _message,
                          enabled: !state.sending,
                          minLines: 4,
                          maxLines: 7,
                          decoration: InputDecoration(
                            labelText: context.strings.contact_message,
                            alignLabelWithHint: true,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? context.strings.contact_message_required
                              : null,
                        ),
                        if (state.sendError != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            state.sendError == 'contact_send_error'
                                ? context.strings.contact_send_error
                                : context.localizedErrorMessage(
                                    state.sendError,
                                  ),
                            style: Styles.textStyle14.copyWith(
                              color: AppColors.red0,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: state.sending ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white0,
                            ),
                            child: state.sending
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white0,
                                    ),
                                  )
                                : Text(context.strings.contact_send),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
