import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import '../cubit/direct_sale_cubit.dart';
import 'direct_sale_customer_choice.dart';
import 'direct_sale_customer_picker.dart';
import 'direct_sale_notice.dart';

class DirectSaleCustomerSelectionBody extends StatelessWidget {
  const DirectSaleCustomerSelectionBody({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        context.strings.direct_sale_choose_customer,
        style: Styles.textStyle18.copyWith(color: AppColors.black1),
      ),
      const SizedBox(height: 12),
      const DirectSaleCustomerPicker(),
      const SizedBox(height: 14),
      DirectSaleCustomerChoice(
        title: context.strings.direct_sale_new_customer,
        subtitle: context.strings.direct_sale_new_customer_hint,
        saved: true,
        onTap: DirectSaleCubit.get(context).openNewCustomer,
      ),
      const SizedBox(height: 14),
      DirectSaleNotice(message: context.strings.direct_sale_pos_existing_only),
    ],
  );
}
