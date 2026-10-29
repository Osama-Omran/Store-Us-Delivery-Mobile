import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';

import '../cubit/direct_sale_cubit.dart';
import '../cubit/direct_sale_state.dart';

import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';

import 'direct_sale_page.dart';

class DirectSaleCustomerSelectionFooter extends StatelessWidget {
  const DirectSaleCustomerSelectionFooter({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DirectSaleCubit, DirectSaleState>(
        builder: (context, state) {
          final cubit = DirectSaleCubit.get(context);
          final customer = state.customer;
          return DirectSaleFooter(
            label: context.strings.direct_sale_continue_products,
            icon: Icons.chevron_left_rounded,
            trailingIcon: true,
            onPressed: customer?.isSaved != true || !state.vehicleStockLoaded
                ? null
                : cubit.continueToProducts,
          );
        },
      );
}

class DirectSaleNewCustomerFooter extends StatelessWidget {
  const DirectSaleNewCustomerFooter({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DirectSaleCubit, DirectSaleState>(
        builder: (context, state) {
          final cubit = DirectSaleCubit.get(context);

          return DirectSaleFooter(
            label: state.creatingCustomer
                ? context.strings.direct_sale_customer_saving
                : state.customerCreateError != null
                ? context.strings.current_trip_retry
                : context.strings.direct_sale_save_customer,
            onPressed:
                state.creatingCustomer ||
                    state.loadingCustomerOptions ||
                    !state.customerOptionsLoaded ||
                    state.territories.isEmpty
                ? null
                : cubit.createCustomer,
            secondaryLabel: context.strings.account_cancel,
            onSecondaryPressed: state.creatingCustomer ? null : cubit.goBack,
          );
        },
      );
}

class DirectSaleProductsFooter extends StatelessWidget {
  const DirectSaleProductsFooter({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DirectSaleCubit, DirectSaleState>(
        builder: (context, state) {
          final cubit = DirectSaleCubit.get(context);

          return DirectSaleFooter(
            label: context.strings.direct_sale_basket(
              state.itemCount,
              state.pricedTotalMinor == null
                  ? '—'
                  : formatTripAmount(context, state.totalMinor / 100),
            ),
            icon: Icons.shopping_cart_outlined,
            onPressed:
                state.inventoryAvailable &&
                    state.itemCount > 0 &&
                    state.vehicleStockLoaded &&
                    state.selectedProductsHavePrices
                ? cubit.continueToPayment
                : null,
          );
        },
      );
}

class DirectSalePaymentFooter extends StatelessWidget {
  const DirectSalePaymentFooter({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DirectSaleCubit, DirectSaleState>(
        builder: (context, state) {
          final cubit = DirectSaleCubit.get(context);

          return DirectSaleFooter(
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
          );
        },
      );
}
