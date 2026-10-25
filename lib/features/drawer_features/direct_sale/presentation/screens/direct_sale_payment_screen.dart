import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';

import '../cubit/direct_sale_cubit.dart';
import '../widgets/direct_sale_amount_field.dart';
import '../widgets/direct_sale_checkout_summary.dart';
import '../widgets/direct_sale_customer_card.dart';
import '../widgets/direct_sale_notice.dart';
import '../widgets/direct_sale_page.dart';
import '../widgets/direct_sale_payment_methods.dart';

class DirectSalePaymentScreen extends StatelessWidget {
  const DirectSalePaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<DirectSaleCubit>();
    final customer = cubit.state.customer;
    return DirectSalePage(
      footer: DirectSaleFooter(label: context.strings.direct_sale_confirm),
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(20),
        children: [
          if (customer != null) ...[
            DirectSaleCustomerCard(
              customer: customer,
              onChange: cubit.changeCustomer,
            ),
            const SizedBox(height: 18),
          ],
          const DirectSaleCheckoutSummary(),
          const SizedBox(height: 22),
          const DirectSaleAmountField(),
          const SizedBox(height: 14),
          const DirectSalePaymentMethods(),
          const SizedBox(height: 20),
          DirectSaleNotice(
            message: context.strings.direct_sale_confirmation_unavailable,
          ),
        ],
      ),
    );
  }
}
