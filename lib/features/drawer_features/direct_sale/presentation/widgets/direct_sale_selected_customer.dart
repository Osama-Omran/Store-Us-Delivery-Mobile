import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/direct_sale_cubit.dart';
import '../cubit/direct_sale_state.dart';
import 'direct_sale_customer_card.dart';

class DirectSaleSelectedCustomer extends StatelessWidget {
  const DirectSaleSelectedCustomer({
    super.key,
    this.allowChange = false,
    this.padding = EdgeInsets.zero,
  });
  final bool allowChange;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DirectSaleCubit, DirectSaleState>(
        buildWhen: (previous, current) =>
            previous.customer != current.customer ||
            previous.submittingPos != current.submittingPos ||
            previous.posRetryOriginal != current.posRetryOriginal,
        builder: (context, state) {
          final customer = state.customer;
          if (customer == null || (!allowChange && !customer.isSaved)) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: padding,
            child: DirectSaleCustomerCard(
              customer: customer,
              onChange:
                  allowChange && !state.submittingPos && !state.posRetryOriginal
                  ? DirectSaleCubit.get(context).changeCustomer
                  : null,
            ),
          );
        },
      );
}
