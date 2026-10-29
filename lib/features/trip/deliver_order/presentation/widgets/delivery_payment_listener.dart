import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import '../cubit/confirm_delivery_cubit.dart';
import '../cubit/confirm_delivery_state.dart';

class DeliveryPaymentListener extends StatelessWidget {
  const DeliveryPaymentListener({
    super.key,
    required this.onConfirmed,
    required this.child,
  });
  final VoidCallback onConfirmed;
  final Widget child;
  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<ConfirmDeliveryCubit, ConfirmDeliveryState>(
    listenWhen: (_, current) =>
        current is ConfirmDeliveryFailure || current is ConfirmDeliverySuccess,
    listener: (context, state) {
      if (state is ConfirmDeliveryFailure) {
        final message = switch (state.message) {
          'delivery_invalid_items' => context.strings.delivery_invalid_items,
          'delivery_invalid_amount' => context.strings.delivery_invalid_amount,
          'delivery_payment_not_supported' =>
            context.strings.delivery_payment_not_supported,
          'delivery_confirm_failed' => context.strings.delivery_confirm_failed,
          final message => message,
        };

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(context.localizedErrorMessage(message)),
              backgroundColor: AppColors.red0,
            ),
          );
      }

      if (state is ConfirmDeliverySuccess) {
        onConfirmed();
      }
    },

    child: child,
  );
}

class DeliveryPaymentBackGuard extends StatelessWidget {
  const DeliveryPaymentBackGuard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      BlocSelector<ConfirmDeliveryCubit, ConfirmDeliveryState, bool>(
        selector: (state) => state is ConfirmDeliveryLoading,
        builder: (context, loading) => PopScope(canPop: !loading, child: child),
      );
}
