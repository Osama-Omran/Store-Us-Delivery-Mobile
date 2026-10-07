import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/features/login/presentation/cubit/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());
  static LoginCubit get(BuildContext context) => BlocProvider.of(context);

  var formKey = GlobalKey<FormState>();

  void validateToLogin() {
    if (formKey.currentState!.validate()) emit(LoginSuccessState());
  }
}
