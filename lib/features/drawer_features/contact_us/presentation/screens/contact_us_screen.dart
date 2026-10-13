import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/presentation/widgets/contact_action_button.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/presentation/widgets/contact_support_info_card.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/data/models/support_contact_response.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/presentation/cubit/contact_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/presentation/cubit/contact_state.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/presentation/widgets/contact_message_sheet.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key, this.tripId});

  // Pass a genuine trip ID only when this page is opened for a specific trip.
  final int? tripId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ContactCubit>()..load(),
      child: _ContactUsContent(tripId: tripId),
    );
  }
}

class _ContactUsContent extends StatelessWidget {
  const _ContactUsContent({this.tripId});

  final int? tripId;

  Future<void> _launch(
    BuildContext context,
    Uri? uri,
  ) async {
    if (uri == null) {
      _showLaunchError(context);
      return;
    }

    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {
      // Show a localized error if no app can handle the URI.
    }

    if (context.mounted) _showLaunchError(context);
  }

  Future<void> _openDialer(
    BuildContext context,
    SupportContactData data,
  ) {
    final url = data.phoneUrl.trim();
    final phone = data.phone.trim();
    final uri = url.startsWith('tel:')
        ? Uri.tryParse(url)
        : phone.isEmpty
            ? null
            : Uri.tryParse('tel:$phone');
    return _launch(context, uri);
  }

  Future<void> _openWhatsApp(
    BuildContext context,
    SupportContactData data,
  ) async {
    final number = data.whatsapp.replaceAll(RegExp(r'\D'), '');
    final appUri = number.isEmpty
        ? null
        : Uri(scheme: 'whatsapp', host: 'send', queryParameters: {
            'phone': number,
          });

    if (appUri != null) {
      try {
        if (await launchUrl(appUri, mode: LaunchMode.externalApplication)) {
          return;
        }
      } catch (_) {
        // WhatsApp may not be installed. Try the server-provided web link.
      }
    }

    final fallback = Uri.tryParse(data.whatsappUrl);
    if (fallback != null &&
        fallback.hasScheme &&
        fallback.scheme == 'https') {
      try {
        if (await launchUrl(
          fallback,
          mode: LaunchMode.externalApplication,
        )) {
          return;
        }
      } catch (_) {
        // Handled below.
      }
    }

    if (context.mounted) _showLaunchError(context);
  }

  void _showLaunchError(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        backgroundColor: AppColors.red0,
        content: Text(context.strings.contact_action_unavailable),
      ));
  }

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
      ..showSnackBar(SnackBar(
        backgroundColor: AppColors.green0,
        content: Text(context.strings.contact_send_success),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
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
                        style: Styles.textStyle16.copyWith(
                          color: AppColors.grey4,
                        ),
                      ),
                      const SizedBox(height: 22),
                      BlocBuilder<ContactCubit, ContactState>(
                        buildWhen: (a, b) =>
                            a.contact != b.contact ||
                            a.loading != b.loading ||
                            a.loadError != b.loadError,
                        builder: (context, state) {
                          if (state.loading && state.contact == null) {
                            return const Padding(
                              padding: EdgeInsets.all(30),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final contact = state.contact;
                          if (contact == null) {
                            return Column(
                              children: [
                                Text(
                                  context.strings.contact_load_error,
                                  textAlign: TextAlign.center,
                                  style: Styles.textStyle14.copyWith(
                                    color: AppColors.grey4,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed: () => context.read<ContactCubit>().load(),
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: Text(context.strings.contact_retry),
                                ),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              ContactSupportInfoCard(phone: contact.phone),
                              const SizedBox(height: 20),
                              ContactActionButton(
                                title: context.strings.contact_call_support,
                                icon: Icons.call_outlined,
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white0,
                                onPressed: () => _openDialer(context, contact),
                              ),
                              const SizedBox(height: 18),
                              ContactActionButton(
                                title: context.strings.contact_whatsapp,
                                icon: Icons.chat_bubble_outline_rounded,
                                backgroundColor: AppColors.green0,
                                foregroundColor: AppColors.white0,
                                onPressed: () => _openWhatsApp(context, contact),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      ContactActionButton(
                        title: context.strings.contact_send_message,
                        backgroundColor: AppColors.white0,
                        foregroundColor: AppColors.black1,
                        outlined: true,
                        onPressed: () => _openMessageSheet(context),
                      ),
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
}
