import 'package:storeus_delivery/features/drawer_features/contact_us/data/models/support_contact_response.dart';

class ContactState {
  const ContactState({
    this.contact,
    this.loading = false,
    this.sending = false,
    this.sent = false,
    this.loadError,
    this.sendError,
  });

  final SupportContactData? contact;
  final bool loading;
  final bool sending;
  final bool sent;
  final String? loadError;
  final String? sendError;

  ContactState copyWith({
    SupportContactData? contact,
    bool? loading,
    bool? sending,
    bool? sent,
    String? loadError,
    String? sendError,
  }) =>
      ContactState(
        contact: contact ?? this.contact,
        loading: loading ?? this.loading,
        sending: sending ?? this.sending,
        sent: sent ?? this.sent,
        loadError: loadError,
        sendError: sendError,
      );
}
