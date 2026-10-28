import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';

import '../cubit/direct_sale_cubit.dart';
import '../widgets/direct_sale_amount_field.dart';
import '../widgets/direct_sale_checkout_summary.dart';
import '../widgets/direct_sale_customer_card.dart';
import '../widgets/direct_sale_notice.dart';
import '../widgets/direct_sale_page.dart';

class DirectSalePaymentScreen extends StatelessWidget {
  const DirectSalePaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<DirectSaleCubit>();
    final state = cubit.state;
    final customer = state.customer;
    return DirectSalePage(
      footer: DirectSaleFooter(
        label: state.submittingPos
            ? context.strings.direct_sale_pos_submitting
            : state.posRetryOriginal
                ? context.strings.direct_sale_pos_retry
                : context.strings.direct_sale_confirm,
        onPressed: state.submittingPos
            ? null
            : (state.canSubmitPos || state.posRetryOriginal)
                ? cubit.submitSale
                : null,
      ),
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(20),
        children: [
          if (customer != null) ...[
            DirectSaleCustomerCard(
              customer: customer,
              onChange: state.submittingPos || state.posRetryOriginal
                  ? null
                  : cubit.changeCustomer,
            ),
            const SizedBox(height: 18),
          ],
          const DirectSaleCheckoutSummary(),
          const SizedBox(height: 22),
          const DirectSaleAmountField(),
          const SizedBox(height: 18),
          DirectSaleNotice(
            message: context.strings.direct_sale_pos_confirm_hint,
          ),
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
  }

  String _posError(BuildContext context, String error) => switch (error) {
    'direct_sale_pos_failed' => context.strings.direct_sale_pos_failed,
    'direct_sale_pos_invalid' => context.strings.direct_sale_pos_invalid,
    'direct_sale_pos_verify_or_retry' =>
      context.strings.direct_sale_pos_verify_or_retry,
    _ => error,
  };
}
