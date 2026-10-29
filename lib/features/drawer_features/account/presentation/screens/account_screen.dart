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
  const AccountScreen({super.key, this.isOnTrip = false});

  final bool isOnTrip;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountCubit, AccountState>(
      listenWhen: (_, state) => state is AccountLoggedOutState,
      listener: (_, state) => GoRouter.of(context).go(RoutesNames.login),
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
