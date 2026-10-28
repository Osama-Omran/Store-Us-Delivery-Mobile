import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';

import '../cubit/direct_sale_cubit.dart';
import '../widgets/direct_sale_customer_card.dart';
import '../widgets/direct_sale_notice.dart';
import '../widgets/direct_sale_page.dart';
import '../widgets/direct_sale_product_card.dart';

class DirectSaleProductsScreen extends StatelessWidget {
  const DirectSaleProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<DirectSaleCubit>();
    final state = cubit.state;
    return DirectSalePage(
      footer: DirectSaleFooter(
        label: context.strings.direct_sale_basket(
          state.itemCount,
          state.pricedTotalMinor == null
              ? '—'
              : formatTripAmount(context, state.totalMinor / 100),
        ),
        icon: Icons.shopping_cart_outlined,
        onPressed: state.inventoryAvailable && state.itemCount > 0 &&
                state.vehicleStockLoaded && state.selectedProductsHavePrices
            ? cubit.continueToPayment
            : null,
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (state.customer != null) ...[
            DirectSaleCustomerCard(
              customer: state.customer!,
              onChange: cubit.changeCustomer,
            ),
            const SizedBox(height: 20),
          ],
          Text.rich(
            TextSpan(
              text: context.strings.direct_sale_choose_products,
              style: Styles.textStyle18.copyWith(color: AppColors.black1),
              children: [
                TextSpan(
                  text: context.strings.inline_secondary_label(
                    context.strings.direct_sale_vehicle_only,
                  ),
                  style: Styles.textStyle12.copyWith(color: AppColors.grey4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (state.loadingVehicleStock)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            ))
          else if (state.vehicleStockError != null) ...[
            DirectSaleNotice(
              error: true,
              message: state.vehicleStockError == 'fractional'
                  ? context.strings.direct_sale_vehicle_stock_fractional
                  : context.strings.direct_sale_vehicle_stock_load_failed,
            ),
            TextButton.icon(
              onPressed: () => cubit.loadVehicleStock(force: true),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.strings.direct_sale_vehicle_stock_retry),
            ),
          ]
          else if (!state.vehicleStockLoaded)
            DirectSaleNotice(message: context.strings.direct_sale_vehicle_stock_load_failed)
          else if (!state.inventoryAvailable)
            DirectSaleNotice(
              message: context.strings.direct_sale_vehicle_stock_empty,
            )
          else if (state.products.isEmpty)
            DirectSaleNotice(message: context.strings.direct_sale_no_products)
          else
            for (final product in state.products) ...[
              DirectSaleProductCard(
                key: ValueKey(product.code),
                product: product,
              ),
              const SizedBox(height: 12),
            ],
          if (state.vehicleStockLoaded && state.inventoryAvailable) ...[
            const SizedBox(height: 8),
            if (state.selectedProducts.any((product) =>
                product.unitPriceMinor == 0))
              DirectSaleNotice(
                message: context.strings.direct_sale_pos_zero_rate_warning,
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => cubit.loadVehicleStock(force: true),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(context.strings.direct_sale_vehicle_stock_refresh),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
