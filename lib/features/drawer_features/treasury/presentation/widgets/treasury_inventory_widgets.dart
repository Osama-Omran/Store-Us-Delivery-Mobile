import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/data/models/treasury_models.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/widgets/treasury_card.dart';

class TreasuryInventorySummary extends StatelessWidget {
  const TreasuryInventorySummary({
    super.key,
    required this.data,
    required this.remainingUnits,
  });

  final TreasuryData data;
  final int remainingUnits;

  @override
  Widget build(BuildContext context) {
    return TreasuryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(
            context.strings.treasury_current_goods,
            style: Styles.textStyle16.copyWith(color: AppColors.grey4),
          ),
          Row(
            spacing: 12,
            children: [
              Text(
                context.strings.treasury_vehicle,
                style: Styles.textStyle14.copyWith(color: AppColors.grey4),
              ),
              Expanded(
                child: Text(
                  data.vehicleName,
                  textAlign: TextAlign.end,
                  style: Styles.textStyle16.copyWith(color: AppColors.black1),
                ),
              ),
            ],
          ),
          Row(
            spacing: 12,
            children: [
              Text(
                context.strings.trip,
                style: Styles.textStyle14.copyWith(color: AppColors.grey4),
              ),
              Expanded(
                child: Text(
                  data.tripNumber,
                  textAlign: TextAlign.end,
                  style: Styles.textStyle16.copyWith(color: AppColors.black1),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.lightPrimary,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              spacing: 12,
              children: [
                Expanded(
                  child: Text(
                    context.strings.treasury_remaining_units,
                    style: Styles.textStyle18.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Text(
                  '$remainingUnits',
                  style: Styles.textStyle24.copyWith(
                    color: AppColors.primary,
                    fontSize: 30,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TreasuryInventorySearch extends StatelessWidget {
  const TreasuryInventorySearch({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(26),
      borderSide: BorderSide(color: AppColors.grey3),
    );

    return TextField(
      key: const ValueKey('treasury-product-search'),
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: Styles.textStyle16.copyWith(color: AppColors.black1),
      decoration: InputDecoration(
        hintText: context.strings.treasury_product_search,
        hintStyle: Styles.textStyle14.copyWith(color: AppColors.grey4),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: AppColors.grey4,
          size: 28,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                key: const ValueKey('treasury-clear-search'),
                tooltip: context.strings.treasury_clear_search,
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: AppColors.white0,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class TreasuryInventoryCard extends StatelessWidget {
  const TreasuryInventoryCard({super.key, required this.item});

  final TreasuryInventoryItem item;

  @override
  Widget build(BuildContext context) {
    final extra = item.source == TreasuryItemSource.extra;

    return TreasuryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Styles.textStyle20.copyWith(
                        color: AppColors.black1,
                        height: 1.5,
                      ),
                    ),
                    Text(
                      '${item.code} · ${context.strings.treasury_product_unit}: ${item.unit}',
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.grey4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: extra ? AppColors.primary : AppColors.grey5,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      extra
                          ? context.strings.treasury_extra_product
                          : context.strings.treasury_trip_order_goods,
                      textAlign: TextAlign.center,
                      style: Styles.textStyle10.copyWith(
                        color: extra ? AppColors.white0 : AppColors.grey4,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                Expanded(
                  child: _QuantityTile(
                    title: context.strings.treasury_loaded,
                    quantity: item.loadedQuantity,
                  ),
                ),
                Expanded(
                  child: _QuantityTile(
                    title: context.strings.treasury_delivered,
                    quantity: item.deliveredQuantity,
                  ),
                ),
                Expanded(
                  child: _QuantityTile(
                    title: context.strings.treasury_remaining,
                    quantity: item.remainingQuantity,
                    highlighted: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityTile extends StatelessWidget {
  const _QuantityTile({
    required this.title,
    required this.quantity,
    this.highlighted = false,
  });

  final String title;
  final int quantity;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primary : AppColors.grey5,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 4,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: Styles.textStyle12.copyWith(
              color: highlighted ? AppColors.white0 : AppColors.grey4,
              fontWeight: highlighted ? FontWeight.w700 : FontWeight.w400,
              height: 1.5,
            ),
          ),
          Text(
            '$quantity',
            style: Styles.textStyle24.copyWith(
              color: highlighted ? AppColors.white0 : AppColors.black1,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class TreasuryEmptyInventory extends StatelessWidget {
  const TreasuryEmptyInventory({super.key, required this.preview});

  final TreasuryPreview preview;

  @override
  Widget build(BuildContext context) {
    return TreasuryCard(
      key: const ValueKey('treasury-empty-inventory'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      child: Column(
        spacing: 16,
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.grey4),
          Text(
            context.strings.treasury_no_inventory,
            textAlign: TextAlign.center,
            style: Styles.textStyle20.copyWith(color: AppColors.black1),
          ),
          Text(
            preview == TreasuryPreview.settled
                ? context.strings.treasury_goods_returned
                : context.strings.treasury_no_active_trip,
            textAlign: TextAlign.center,
            style: Styles.textStyle14.copyWith(color: AppColors.grey4),
          ),
        ],
      ),
    );
  }
}
