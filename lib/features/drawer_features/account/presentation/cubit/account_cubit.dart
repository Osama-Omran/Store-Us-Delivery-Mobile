import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';

import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/routing/app_router.dart';

import 'package:storeus_delivery/features/drawer_features/account/data/models/me_response.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/usecases/get_me_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/usecases/logout_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final GetMeUsecase _getMeUsecase;
  final LogoutUsecase _logoutUsecase;

  AccountCubit(this._getMeUsecase, this._logoutUsecase)
    : super(AccountInitial());

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

    return null;
  }

  Future<void> getMe() async {
    if (isClosed ||
        state is AccountLoadingState ||
        state is AccountLoggingOutState ||
        state is AccountLoggedOutState) {
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
          emit(AccountFailureState(response.message ?? 'account_load_failed'));
        }
      },

      failure: (error) {
        emit(AccountFailureState(error.apiErrorModel.message));
      },
    );
  }

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
              response['message']?.toString() ?? 'account_logout_failed';
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
