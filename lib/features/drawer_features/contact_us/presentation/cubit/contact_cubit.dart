import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/data/models/send_support_message_body.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/domain/usecases/get_support_contact_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/domain/usecases/send_support_message_usecase.dart';

import 'contact_state.dart';

class ContactCubit extends Cubit<ContactState> {
  ContactCubit(this._getContact, this._sendMessage)
      : super(const ContactState());

  final GetSupportContactUsecase _getContact;
  final SendSupportMessageUsecase _sendMessage;

  Future<void> load() async {
    if (isClosed || state.loading) return;

    emit(state.copyWith(loading: true));

    try {
      final result = await _getContact();
      if (isClosed) return;

      result.when(
        success: (contact) {
          emit(state.copyWith(contact: contact, loading: false));
        },
        failure: (error) {
          emit(state.copyWith(
            loading: false,
            loadError: error.apiErrorModel.message,
          ));
        },
      );
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(loading: false, loadError: 'contact_load_error'));
      }
    }
  }

  Future<void> sendMessage({
    required String subject,
    required String message,
    int? tripId,
  }) async {
    if (isClosed || state.sending) return;

    final cleanSubject = subject.trim();
    final cleanMessage = message.trim();

    if (cleanSubject.isEmpty || cleanMessage.isEmpty) return;

    emit(state.copyWith(sending: true, sent: false));

    try {
      final result = await _sendMessage(
        SendSupportMessageBody(
          subject: cleanSubject,
          message: cleanMessage,
          tripId: tripId,
        ),
      );

      if (isClosed) return;

      result.when(
        success: (_) {
          emit(state.copyWith(sending: false, sent: true));
        },
        failure: (error) {
          emit(state.copyWith(
            sending: false,
            sendError: error.apiErrorModel.message,
          ));
        },
      );
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(sending: false, sendError: 'contact_send_error'));
      }
    }
  }
}
