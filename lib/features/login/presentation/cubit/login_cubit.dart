import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/routing/app_router.dart';
import 'package:storeus_delivery/features/login/data/models/login_request_body.dart';
import 'package:storeus_delivery/features/login/domain/usecases/login_usecase.dart';
import 'package:storeus_delivery/features/login/presentation/cubit/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUsecase _usecase;
  LoginCubit(this._usecase) : super(LoginInitial());
  static LoginCubit get(BuildContext context) => BlocProvider.of(context);

  TextEditingController emailController = TextEditingController(),
      passwordController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  void validateToLogin() {
    if (formKey.currentState!.validate()) login();
  }

  static Future<String> getDeviceName() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;

      return '${info.manufacturer} ${info.model}'.trim();
    }

    if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;

      return info.name;
    }

    return 'Unknown Device';
  }

  Future<void> login() async {
    emit(LoginLoadingState());
    final LoginRequestBody body = LoginRequestBody(
      username: emailController.text.trim(),
      password: passwordController.text.trim(),
      deviceName: await getDeviceName(),
    );
    final response = await _usecase.call(body: body);
    response.when(
      success: (lResponse) {
        if (lResponse.data?.token != null) {
          PreferencesHelper.saveToken(lResponse.data!.token);
          token = lResponse.data!.token;
        }
        emit(LoginSuccessState());
      },
      failure: (f) => emit(LoginFailureState(f.apiErrorModel.message)),
    );
  }
}
