import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import '../cubit/direct_sale_cubit.dart';
import '../widgets/direct_sale_customer_card.dart';
import '../widgets/direct_sale_customer_choice.dart';
import '../widgets/direct_sale_notice.dart';
import '../widgets/direct_sale_page.dart';

class DirectSaleCustomerSelectionScreen extends StatelessWidget {
  const DirectSaleCustomerSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<DirectSaleCubit>();
    final state = cubit.state;
    final customer = state.customer;
    // A newly created customer may not yet appear in a cached POS options list.
    final selectedId = state.existingCustomers.any((c) => c.id == customer?.id)
        ? customer!.id
        : null;

    return DirectSalePage(
      footer: DirectSaleFooter(
        label: context.strings.direct_sale_continue_products,
        icon: Icons.chevron_left_rounded,
        trailingIcon: true,
        onPressed: customer?.isSaved != true || !state.vehicleStockLoaded
            ? null
            : cubit.continueToProducts,
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            context.strings.direct_sale_choose_customer,
            style: Styles.textStyle18.copyWith(color: AppColors.black1),
          ),
          const SizedBox(height: 12),
          if (state.loadingVehicleStock)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (state.vehicleStockError != null) ...[
            DirectSaleNotice(
              error: true,
              message: context.strings.direct_sale_pos_customers_load_failed,
            ),
            TextButton.icon(
              onPressed: () => cubit.loadVehicleStock(force: true),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.strings.direct_sale_vehicle_stock_retry),
            ),
          ] else if (!state.vehicleStockLoaded)
            DirectSaleNotice(
              message: context.strings.direct_sale_pos_customers_load_failed,
            )
          else if (state.existingCustomers.isEmpty)
            DirectSaleNotice(
              message: context.strings.direct_sale_pos_customers_empty,
            )
          else
            DropdownButtonFormField<String>(
              key: const ValueKey('direct-sale-existing-customer'),
              initialValue: selectedId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: context.strings.direct_sale_pos_select_customer,
                filled: true,
                fillColor: AppColors.white0,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              items: state.existingCustomers
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option.id,
                      child: Text(
                        option.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: cubit.selectExistingCustomer,
            ),
          const SizedBox(height: 14),
          DirectSaleCustomerChoice(
            title: context.strings.direct_sale_new_customer,
            subtitle: context.strings.direct_sale_new_customer_hint,
            saved: true,
            onTap: cubit.openNewCustomer,
          ),
          const SizedBox(height: 14),
          DirectSaleNotice(
            message: context.strings.direct_sale_pos_existing_only,
          ),
          if (customer != null && customer.isSaved) ...[
            const SizedBox(height: 14),
            DirectSaleCustomerCard(customer: customer),
          ],
        ],
      ),
    );
  }
}
