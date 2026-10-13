import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';

import '../cubit/direct_sale_cubit.dart';
import '../widgets/direct_sale_customer_form.dart';
import '../widgets/direct_sale_location_card.dart';
import '../widgets/direct_sale_notice.dart';
import '../widgets/direct_sale_page.dart';

class DirectSaleNewCustomerScreen extends StatelessWidget {
  const DirectSaleNewCustomerScreen({super.key});

  @override
  Widget build(BuildContext context) => DirectSalePage(
    newCustomer: true,
    footer: DirectSaleFooter(
      label: context.strings.direct_sale_save_customer,
      secondaryLabel: context.strings.account_cancel,
      onSecondaryPressed: DirectSaleCubit.get(context).goBack,
    ),
    child: ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(20),
      children: [
        const DirectSaleCustomerForm(),
        const SizedBox(height: 18),
        const DirectSaleLocationCard(),
        const SizedBox(height: 16),
        DirectSaleNotice(
          message: context.strings.direct_sale_customer_save_unavailable,
        ),
      ],
    ),
  );
}
