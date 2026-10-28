import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/direct_sale_models.dart';
import '../cubit/direct_sale_cubit.dart';
import '../cubit/direct_sale_state.dart';
import '../widgets/direct_sale_page.dart';
import 'direct_sale_customer_selection_screen.dart';
import 'direct_sale_new_customer_screen.dart';
import 'direct_sale_products_screen.dart';
import 'direct_sale_payment_screen.dart';
import 'direct_sale_success_screen.dart';

class DirectSaleScreen extends StatelessWidget {
  const DirectSaleScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DirectSaleCubit, DirectSaleState>(
        builder: (context, state) => PopScope<Object?>(
          canPop:
              !state.submittingPos && !state.posRetryOriginal &&
              (state.step == DirectSaleStep.customer ||
               state.step == DirectSaleStep.success),
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) goBackFromDirectSale(context);
          },
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: switch (state.step) {
              DirectSaleStep.customer =>
                const DirectSaleCustomerSelectionScreen(),
              DirectSaleStep.newCustomer => const DirectSaleNewCustomerScreen(),
              DirectSaleStep.products => const DirectSaleProductsScreen(),
              DirectSaleStep.payment => const DirectSalePaymentScreen(),
              DirectSaleStep.success =>
                state.receipt == null
                    ? const DirectSaleCustomerSelectionScreen()
                    : DirectSaleSuccessScreen(receipt: state.receipt!),
            },
          ),
        ),
      );
}
