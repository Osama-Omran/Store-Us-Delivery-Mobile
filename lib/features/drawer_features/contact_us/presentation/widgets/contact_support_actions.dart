import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/support_contact_response.dart';
import '../cubit/contact_cubit.dart';
import '../cubit/contact_state.dart';
import 'contact_action_button.dart';
import 'contact_support_info_card.dart';
import 'contact_shimmer.dart';

class ContactSupportActions extends StatelessWidget {
  const ContactSupportActions({super.key});

  Future<void> _launch(BuildContext context, Uri? uri) async {
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

  Future<void> _openDialer(BuildContext context, SupportContactData data) {
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
        : Uri(
            scheme: 'whatsapp',
            host: 'send',
            queryParameters: {'phone': number},
          );

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
    if (fallback != null && fallback.hasScheme && fallback.scheme == 'https') {
      try {
        if (await launchUrl(fallback, mode: LaunchMode.externalApplication)) {
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
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.red0,
          content: Text(context.strings.contact_action_unavailable),
        ),
      );
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<ContactCubit, ContactState>(
    buildWhen: (a, b) =>
        a.contact != b.contact ||
        a.loading != b.loading ||
        a.loadError != b.loadError,
    builder: (context, state) {
      if (state.loading && state.contact == null) return const ContactShimmer();
      final contact = state.contact;
      if (contact == null) {
        return Column(
          children: [
            Text(
              context.strings.contact_load_error,
              textAlign: TextAlign.center,
              style: Styles.textStyle14.copyWith(color: AppColors.grey4),
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
  );
}
