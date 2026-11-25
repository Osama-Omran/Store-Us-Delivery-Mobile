import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_draft_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_draft_state.dart';

import 'delivery_extra_products_picker.dart';

class DeliveryExtraProductsSection extends StatelessWidget {
  const DeliveryExtraProductsSection({super.key, required this.tripId});

  final int tripId;

  Future<void> _openPicker(BuildContext context) async {
    final cubit = context.read<DeliveryDraftCubit>();
    // Refresh every time the picker opens. Do not silently reduce selections
    // when available vehicle stock changes.
    await cubit.loadExtraProducts(tripId, force: true);
    if (!context.mounted) return;
    final state = cubit.state;
    if (state is! DeliveryDraftReady ||
        state.extraProductsError != null ||
        !state.extraProductsLoaded) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.white0,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: DeliveryExtraProductsPicker(
          products: state.extraProducts,
          initialQuantities: state.extraQuantities,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DeliveryDraftCubit, DeliveryDraftState>(
        builder: (context, state) {
          if (state is! DeliveryDraftReady) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.blue5,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppColors.blue3, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.strings.delivery_extra_products,
                        style: Styles.textStyle18.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                for (final product in state.selectedExtraProducts)
                  Row(
                    children: [
                      Expanded(child: Text(product.itemName)),
                      const SizedBox(width: 8),
                      Text('${state.extraQtyFor(product)} ${product.uom}'),
                      const SizedBox(width: 8),
                      Text(
                        formatTripAmount(
                          context,
                          state.extraQtyFor(product) * product.rate,
                        ),
                      ),
                    ],
                  ),
                if (state.hasExtraProducts) ...[
                  Divider(color: AppColors.blue3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.strings.delivery_extra_products,
                          style: Styles.textStyle14,
                        ),
                      ),
                      Text(
                        state.estimatedExtraProductsValue == null
                            ? '—'
                            : formatTripAmount(
                                context,
                                state.estimatedExtraProductsValue!,
                              ),
                        style: Styles.textStyle17.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
                if (!state.extraQuantitiesValid)
                  Text(
                    context.strings.delivery_invalid_items,
                    style: TextStyle(color: AppColors.red0),
                  ),
                if (state.extraProductsError != null)
                  Text(
                    state.extraProductsError == 'fractional'
                        ? context.strings.direct_sale_vehicle_stock_fractional
                        : context.strings.direct_sale_vehicle_stock_load_failed,
                    style: TextStyle(color: AppColors.red0),
                  ),
                SizedBox(
                  height: 58,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: state.loadingExtraProducts
                        ? null
                        : () => _openPicker(context),
                    icon: state.loadingExtraProducts
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add),
                    label: Text(
                      state.extraProductsError != null
                          ? context.strings.direct_sale_vehicle_stock_retry
                          : context.strings.delivery_add_extra_product,
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.white0,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
}
