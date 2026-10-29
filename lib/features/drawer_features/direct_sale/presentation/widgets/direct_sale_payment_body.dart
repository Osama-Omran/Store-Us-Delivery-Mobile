import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';

import '../cubit/direct_sale_cubit.dart';
import '../cubit/direct_sale_state.dart';
import 'direct_sale_selected_customer.dart';
import 'direct_sale_checkout_summary.dart';
import 'direct_sale_amount_field.dart';
import 'direct_sale_notice.dart';

class DirectSalePaymentBody extends StatelessWidget {
  const DirectSalePaymentBody({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    padding: const EdgeInsets.all(20),
    children: [
      const DirectSaleSelectedCustomer(
        allowChange: true,
        padding: EdgeInsets.only(bottom: 18),
      ),
      const DirectSaleCheckoutSummary(),
      const SizedBox(height: 22),
      const DirectSaleAmountField(),
      const SizedBox(height: 18),
      DirectSaleNotice(message: context.strings.direct_sale_pos_confirm_hint),
      const _PaymentStatus(),
    ],
  );
}

class _PaymentStatus extends StatelessWidget {
  const _PaymentStatus();
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DirectSaleCubit, DirectSaleState>(
        buildWhen: (previous, current) =>
            previous.submittingPos != current.submittingPos ||
            previous.posSubmitError != current.posSubmitError,
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.submittingPos) ...[
              const SizedBox(height: 18),
              const Center(child: CircularProgressIndicator()),
            ],
            if (state.posSubmitError != null) ...[
              const SizedBox(height: 14),
              DirectSaleNotice(
                error: true,
                message: _posError(context, state.posSubmitError!),
              ),
            ],
          ],
        ),
      );

  String _posError(BuildContext context, String error) => switch (error) {
    'direct_sale_pos_failed' => context.strings.direct_sale_pos_failed,
    'direct_sale_pos_invalid' => context.strings.direct_sale_pos_invalid,
    'direct_sale_pos_verify_or_retry' =>
      context.strings.direct_sale_pos_verify_or_retry,
    _ => error,
  };
}
