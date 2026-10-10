
import 'package:storeus_delivery/features/account/data/models/me_response.dart';

sealed class AccountState {}

final class AccountInitial extends AccountState {}

final class AccountLoadingState extends AccountState {}

final class AccountSuccessState extends AccountState {
  final AccountUser user;

  AccountSuccessState(this.user);
}

final class AccountFailureState extends AccountState {
  final String errorMessage;

  AccountFailureState(this.errorMessage);
}

final class AccountLoggingOutState extends AccountState {
  final AccountUser? user;

  AccountLoggingOutState(this.user);
}

final class AccountLogoutFailureState extends AccountState {
  final AccountUser? user;
  final String errorMessage;

  AccountLogoutFailureState({
    required this.user,
    required this.errorMessage,
  });
}

final class AccountLoggedOutState extends AccountState {}
