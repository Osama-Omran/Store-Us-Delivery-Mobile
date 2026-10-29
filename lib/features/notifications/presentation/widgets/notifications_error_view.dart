import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_state.dart';

class NotificationsErrorView extends StatelessWidget {
  const NotificationsErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final error = context.select<NotificationsCubit, String?>((cubit) {
      final state = cubit.state;
      return state is NotificationsFailureState ? state.errorMessage : null;
    });
    final message = error?.isNotEmpty == true
        ? error!
        : context.strings.notifications_load_failed;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 22, 20, 112),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 410),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 27),
          decoration: BoxDecoration(
            color: AppColors.white0,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: AppColors.grey3),
            boxShadow: [
              BoxShadow(
                color: AppColors.black1.withValues(alpha: 0.035),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.red1.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.notifications_off_outlined,
                  size: 35,
                  color: AppColors.red1,
                ),
              ),
              const SizedBox(height: 19),
              Text(
                context.localizedErrorMessage(message),
                textAlign: TextAlign.center,
                style: Styles.textStyle15.copyWith(
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey1,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      NotificationsCubit.get(context).getNotifications(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor: AppColors.blue5,
                    side: BorderSide(color: AppColors.blue3),
                    minimumSize: const Size(0, 49),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 21),
                  label: Text(
                    context.strings.current_trip_retry,
                    style: Styles.base.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
