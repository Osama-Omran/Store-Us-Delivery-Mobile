import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import '../cubit/direct_sale_cubit.dart';
import '../widgets/direct_sale_customer_card.dart';
import '../widgets/direct_sale_customer_choice.dart';
import '../widgets/direct_sale_page.dart';

class DirectSaleCustomerSelectionScreen extends StatelessWidget {
  const DirectSaleCustomerSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<DirectSaleCubit>();
    final customer = cubit.state.customer;
    return DirectSalePage(
      footer: DirectSaleFooter(
        label: context.strings.direct_sale_continue_products,
        icon: Icons.chevron_left_rounded,
        trailingIcon: true,
        onPressed: customer == null ? null : cubit.continueToProducts,
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            context.strings.direct_sale_choose_customer,
            style: Styles.textStyle18.copyWith(color: AppColors.black1),
          ),
          const SizedBox(height: 14),
          DirectSaleCustomerChoice(
            title: context.strings.direct_sale_cash_customer,
            subtitle: context.strings.direct_sale_cash_customer_hint,
            saved: false,
            selected: customer != null && !customer.isSaved,
            onTap: cubit.selectCashCustomer,
          ),
          const SizedBox(height: 12),
          DirectSaleCustomerChoice(
            title: context.strings.direct_sale_new_customer,
            subtitle: context.strings.direct_sale_new_customer_hint,
            saved: true,
            onTap: cubit.openNewCustomer,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.grey5,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              context.strings.direct_sale_customer_guidance,
              style: Styles.textStyle12.copyWith(
                color: AppColors.grey4,
                fontWeight: FontWeight.w400,
                height: 1.7,
              ),
            ),
          ),
          if (customer != null) ...[
            const SizedBox(height: 14),
            DirectSaleCustomerCard(customer: customer),
          ],
        ],
      ),
    );
  }
}
