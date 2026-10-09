
import 'package:flutter/cupertino.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/core/widgets/custom_text_field.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/loaded_items_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/custom_trip_container.dart';

class VanProducts extends StatefulWidget {
  const VanProducts({
    super.key,
    required this.items,
  });

  final List<LoadedTripItem> items;

  @override
  State<VanProducts> createState() => _VanProductsState();
}

class _VanProductsState extends State<VanProducts> {
  final TextEditingController _searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() => setState(() {});

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    final visibleItems = widget.items.where((item) {
      return item.itemName.toLowerCase().contains(query) ||
          item.itemCode.toLowerCase().contains(query);
    }).toList();

    return Column(
      spacing: 16,
      children: [
        CustomTextField(
          controller: _searchController,
          hint: context.strings.search_for_a_product,
          prefixIcon: const Icon(CupertinoIcons.search),
        ),

        if (visibleItems.isEmpty)
          CustomTripContainer(
            child: Center(
              child: Text(
                context.strings.loaded_items_no_search_results,
                textAlign: TextAlign.center,
                style: Styles.textStyle14.copyWith(
                  color: AppColors.grey4,
                ),
              ),
            ),
          )
        else
          ...visibleItems.map(
                (item) => ProductWidget(product: item),
          ),
      ],
    );
  }
}

class ProductWidget extends StatelessWidget {
  const ProductWidget({
    super.key,
    required this.product,
  });

  final LoadedTripItem product;

  @override
  Widget build(BuildContext context) {
    final sourceLabel = switch (product.source) {
      'sales_orders' => context.strings.from_trip_orders,
      'extra' => context.strings.loaded_items_extra_source,
      _ => '',
    };

    return CustomTripContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  product.itemName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.textStyle18.copyWith(
                    color: AppColors.black1,
                  ),
                ),
                Text(
                  '${product.itemCode} • ${context.strings.unit}: ${product.uom ?? '—'}',
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.grey4,
                  ),
                ),
                if (sourceLabel.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.grey5,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      sourceLabel,
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.grey4,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Text(
                context.strings.loaded_quantity,
                style: Styles.textStyle12.copyWith(
                  color: AppColors.grey4,
                ),
              ),
              Text(
                product.loadedQty.toString(),
                style: Styles.textStyle24.copyWith(
                  color: AppColors.black1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
