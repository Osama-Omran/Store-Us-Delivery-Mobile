import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/custom_app_bar.dart';

import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_state.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/widgets/account_body.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({
    super.key,
    this.isOnTrip = false,
  });

  final bool isOnTrip;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AccountCubit, AccountState>(
          listenWhen: (_, state) =>
          state is AccountLoggedOutState,
          listener: (context, state) {
            GoRouter.of(context).go(RoutesNames.login);
          },
        ),

        BlocListener<AccountCubit, AccountState>(
          listenWhen: (_, state) =>
          state is AccountProfileUpdateSuccessState ||
              state is AccountProfileUpdateFailureState ||
              state is AccountPasswordChangeFailureState,
          listener: (context, state) {
            String message;
            bool isSuccess = false;

            if (state is AccountProfileUpdateSuccessState) {
              message = 'تم تحديث بيانات الحساب بنجاح';
              isSuccess = true;
            } else if (state is AccountProfileUpdateFailureState) {
              message = context.localizedErrorMessage(
                state.errorMessage,
              );
            } else {
              message = context.localizedErrorMessage(
                (state as AccountPasswordChangeFailureState)
                    .errorMessage,
              );
            }

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: isSuccess
                      ? AppColors.primary
                      : AppColors.red1,
                ),
              );
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.grey0,
        appBar: CustomAppBar(
          title: context.strings.account,
          withBackButton: true,
        ),
        body: AccountBody(isOnTrip: isOnTrip),
      ),
    );
  }
}