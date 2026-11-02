import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/routing/app_router.dart';

import 'package:storeus_delivery/features/drawer_features/account/data/models/me_response.dart';
import 'package:storeus_delivery/features/drawer_features/account/data/models/update_profile_request_body.dart';
import 'package:storeus_delivery/features/drawer_features/account/data/models/change_password_request_body.dart';

import 'package:storeus_delivery/features/drawer_features/account/domain/usecases/get_me_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/usecases/logout_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/usecases/update_profile_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/usecases/change_password_usecase.dart';

import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final GetMeUsecase _getMeUsecase;
  final LogoutUsecase _logoutUsecase;
  final UpdateProfileUsecase _updateProfileUsecase;
  final ChangePasswordUsecase _changePasswordUsecase;

  AccountCubit(
      this._getMeUsecase,
      this._logoutUsecase,
      this._updateProfileUsecase,
      this._changePasswordUsecase,
      ) : super(AccountInitial());

  static AccountCubit get(BuildContext context) =>
      BlocProvider.of<AccountCubit>(context);

  AccountUser? get currentUser {
    final current = state;

    if (current is AccountSuccessState) {
      return current.user;
    }

    if (current is AccountLoggingOutState) {
      return current.user;
    }

    if (current is AccountLogoutFailureState) {
      return current.user;
    }

    if (current is AccountProfileUpdatingState) {
      return current.user;
    }

    if (current is AccountProfileUpdateSuccessState) {
      return current.user;
    }

    if (current is AccountProfileUpdateFailureState) {
      return current.user;
    }

    if (current is AccountPasswordChangingState) {
      return current.user;
    }

    if (current is AccountPasswordChangeFailureState) {
      return current.user;
    }

    return null;
  }

  //======= Get Account =======//

  Future<void> getMe() async {
    if (isClosed ||
        state is AccountLoadingState ||
        state is AccountLoggingOutState ||
        state is AccountLoggedOutState ||
        state is AccountProfileUpdatingState ||
        state is AccountPasswordChangingState) {
      return;
    }

    emit(AccountLoadingState());

    final result = await _getMeUsecase.call();

    if (isClosed) return;

    result.when(
      success: (response) {
        if (response.success && response.data != null) {
          final user = response.data!;

          PreferencesHelper.saveUserName(user.name);

          emit(AccountSuccessState(user));
        } else {
          emit(
            AccountFailureState(
              response.message ?? 'account_load_failed',
            ),
          );
        }
      },
      failure: (error) {
        emit(
          AccountFailureState(
            error.apiErrorModel.message,
          ),
        );
      },
    );
  }

  //======= Update Profile =======//

  Future<void> updateProfile(
      UpdateProfileRequestBody body,
      ) async {
    if (isClosed ||
        state is AccountProfileUpdatingState ||
        state is AccountPasswordChangingState ||
        state is AccountLoggingOutState ||
        state is AccountLoggedOutState) {
      return;
    }

    final user = currentUser;

    if (body.toJson().isEmpty && body.photo == null) {
      emit(
        AccountProfileUpdateFailureState(
          user: user,
          errorMessage: 'account_no_profile_changes',
        ),
      );
      return;
    }

    emit(AccountProfileUpdatingState(user));

    final result = await _updateProfileUsecase.call(body);

    if (isClosed) return;

    dynamic profileResponse;
    String? failureMessage;

    result.when(
      success: (response) {
        profileResponse = response;
      },
      failure: (error) {
        failureMessage = error.apiErrorModel.message;
      },
    );

    if (failureMessage != null) {
      emit(
        AccountProfileUpdateFailureState(
          user: user,
          errorMessage: failureMessage!,
        ),
      );
      return;
    }

    if (profileResponse is Map &&
        profileResponse['success'] == false) {
      emit(
        AccountProfileUpdateFailureState(
          user: user,
          errorMessage:
          profileResponse['message']?.toString() ??
              'account_profile_update_failed',
        ),
      );
      return;
    }

    // Refresh account data after successful update.
    AccountUser? updatedUser;

    final refreshResult = await _getMeUsecase.call();

    if (isClosed) return;

    refreshResult.when(
      success: (response) {
        if (response.success && response.data != null) {
          updatedUser = response.data!;
        }
      },
      failure: (_) {},
    );

    updatedUser ??= user;

    if (updatedUser == null) {
      emit(
        AccountProfileUpdateFailureState(
          user: null,
          errorMessage: 'account_profile_refresh_failed',
        ),
      );
      return;
    }

    PreferencesHelper.saveUserName(updatedUser!.name);

    emit(
      AccountProfileUpdateSuccessState(updatedUser!),
    );
  }

  //======= Change Password =======//

  Future<void> changePassword(
      ChangePasswordRequestBody body,
      ) async {
    if (isClosed ||
        state is AccountPasswordChangingState ||
        state is AccountProfileUpdatingState ||
        state is AccountLoggingOutState ||
        state is AccountLoggedOutState) {
      return;
    }

    final user = currentUser;

    if (body.password.length < 12) {
      emit(
        AccountPasswordChangeFailureState(
          user: user,
          errorMessage: 'password_min_12_chars',
        ),
      );
      return;
    }

    if (body.currentPassword == body.password) {
      emit(
        AccountPasswordChangeFailureState(
          user: user,
          errorMessage: 'password_must_be_different',
        ),
      );
      return;
    }

    if (body.password != body.passwordConfirmation) {
      emit(
        AccountPasswordChangeFailureState(
          user: user,
          errorMessage: 'password_confirmation_mismatch',
        ),
      );
      return;
    }

    emit(AccountPasswordChangingState(user));

    final result = await _changePasswordUsecase.call(body);

    if (isClosed) return;

    dynamic response;
    String? failureMessage;

    result.when(
      success: (data) {
        response = data;
      },
      failure: (error) {
        failureMessage = error.apiErrorModel.message;
      },
    );

    if (failureMessage != null) {
      emit(
        AccountPasswordChangeFailureState(
          user: user,
          errorMessage: failureMessage!,
        ),
      );
      return;
    }

    final success = response is Map &&
        response['success'] == true;

    final data = response is Map ? response['data'] : null;

    final requiresLogin = data is Map &&
        data['requires_login'] == true;

    if (!success || !requiresLogin) {
      emit(
        AccountPasswordChangeFailureState(
          user: user,
          errorMessage: 'account_password_change_failed',
        ),
      );
      return;
    }

    // The API revoked the tokens.
    // Do not call the logout endpoint again.
    try {
      await PreferencesHelper.removeToken();
    } catch (_) {
      // Continue to the login screen because the server
      // has already revoked the current token.
    }

    token = null;

    PreferencesHelper.saveUserName('');

    if (!isClosed) {
      emit(AccountLoggedOutState());
    }
  }

  //======= Logout =======//

  Future<void> logout() async {
    if (isClosed ||
        state is AccountLoggingOutState ||
        state is AccountLoggedOutState) {
      return;
    }

    final user = currentUser;

    emit(AccountLoggingOutState(user));

    final result = await _logoutUsecase.call();

    if (isClosed) return;

    bool succeeded = false;
    String? failureMessage;

    result.when(
      success: (response) {
        if (response is Map && response['success'] == false) {
          failureMessage =
              response['message']?.toString() ??
                  'account_logout_failed';
        } else {
          succeeded = true;
        }
      },
      failure: (error) {
        failureMessage = error.apiErrorModel.message;
      },
    );

    if (!succeeded) {
      emit(
        AccountLogoutFailureState(
          user: user,
          errorMessage: failureMessage ?? 'account_logout_failed',
        ),
      );
      return;
    }

    try {
      await PreferencesHelper.removeToken();

      token = null;

      PreferencesHelper.saveUserName('');

      if (!isClosed) {
        emit(AccountLoggedOutState());
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          AccountLogoutFailureState(
            user: user,
            errorMessage: 'account_logout_failed',
          ),
        );
      }
    }
  }
}