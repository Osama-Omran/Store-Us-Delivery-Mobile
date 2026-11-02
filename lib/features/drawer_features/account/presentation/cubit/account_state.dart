import 'package:storeus_delivery/features/drawer_features/account/data/models/me_response.dart';

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

//======= Logout =======//

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

//======= Update Profile =======//

final class AccountProfileUpdatingState extends AccountState {
  final AccountUser? user;

  AccountProfileUpdatingState(this.user);
}

final class AccountProfileUpdateSuccessState extends AccountState {
  final AccountUser user;

  AccountProfileUpdateSuccessState(this.user);
}

final class AccountProfileUpdateFailureState extends AccountState {
  final AccountUser? user;
  final String errorMessage;

  AccountProfileUpdateFailureState({
    required this.user,
    required this.errorMessage,
  });
}

//======= Change Password =======//

final class AccountPasswordChangingState extends AccountState {
  final AccountUser? user;

  AccountPasswordChangingState(this.user);
}

final class AccountPasswordChangeFailureState extends AccountState {
  final AccountUser? user;
  final String errorMessage;

  AccountPasswordChangeFailureState({
    required this.user,
    required this.errorMessage,
  });
}