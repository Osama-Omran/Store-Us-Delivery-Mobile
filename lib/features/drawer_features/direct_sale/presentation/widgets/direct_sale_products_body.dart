import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';

import '../cubit/direct_sale_cubit.dart';
import '../cubit/direct_sale_state.dart';

import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import 'direct_sale_selected_customer.dart';
import 'direct_sale_notice.dart';
import 'direct_sale_product_card.dart';
import 'direct_sale_stock_shimmer.dart';

class DirectSaleProductsBody extends StatelessWidget {
  const DirectSaleProductsBody({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const DirectSaleSelectedCustomer(
        allowChange: true,
        padding: EdgeInsets.only(bottom: 20),
      ),
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
      const _ProductsList(),
    ],
  );
}

class _ProductsList extends StatelessWidget {
  const _ProductsList();
  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<DirectSaleCubit, DirectSaleState>(
    buildWhen: (previous, current) =>
        previous.products != current.products ||
        previous.loadingVehicleStock != current.loadingVehicleStock ||
        previous.vehicleStockLoaded != current.vehicleStockLoaded ||
        previous.vehicleStockError != current.vehicleStockError ||
        previous.inventoryAvailable != current.inventoryAvailable,
    builder: (context, state) {
      final cubit = DirectSaleCubit.get(context);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.loadingVehicleStock)
            const DirectSaleStockShimmer()
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
          ] else if (!state.vehicleStockLoaded)
            DirectSaleNotice(
              message: context.strings.direct_sale_vehicle_stock_load_failed,
            )
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
            const _ZeroRateWarning(),
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
      );
    },
  );
}

class _ZeroRateWarning extends StatelessWidget {
  const _ZeroRateWarning();
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DirectSaleCubit, DirectSaleState>(
        buildWhen: (previous, current) =>
            previous.products != current.products ||
            previous.quantities != current.quantities,
        builder: (context, state) =>
            state.selectedProducts.any((product) => product.unitPriceMinor == 0)
            ? DirectSaleNotice(
                message: context.strings.direct_sale_pos_zero_rate_warning,
              )
            : const SizedBox.shrink(),
      );
}
