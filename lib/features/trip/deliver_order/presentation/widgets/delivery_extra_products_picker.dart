import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_extra_product.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_draft_cubit.dart';

/// Staged picker: Cancel discards edits; Confirm updates the delivery draft.
class DeliveryExtraProductsPicker extends StatefulWidget {
  const DeliveryExtraProductsPicker({
    super.key,
    required this.products,
    required this.initialQuantities,
  });

  final List<DeliveryExtraProduct> products;
  final Map<String, int> initialQuantities;

  @override
  State<DeliveryExtraProductsPicker> createState() =>
      _DeliveryExtraProductsPickerState();
}

class _DeliveryExtraProductsPickerState
    extends State<DeliveryExtraProductsPicker> {
  late final Map<String, int> _quantities;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _quantities = Map.of(widget.initialQuantities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _quantity(DeliveryExtraProduct product) =>
      _quantities[product.itemCode] ?? 0;

  void _changeQuantity(DeliveryExtraProduct product, int next) {
    if (next < 0 ||
        (next > product.availableQuantity && next >= _quantity(product))) {
      return;
    }
    setState(() {
      if (next == 0) {
        _quantities.remove(product.itemCode);
      } else {
        _quantities[product.itemCode] = next;
      }
    });
  }

  bool get _valid {
    final byCode = {
      for (final product in widget.products) product.itemCode: product,
    };
    for (final entry in _quantities.entries) {
      final product = byCode[entry.key];
      if (product == null ||
          entry.value < 0 ||
          entry.value > product.availableQuantity) {
        return false;
      }
    }
    return true;
  }

  num get _total {
    int minor = 0;
    for (final product in widget.products) {
      minor += product.rateMinor * _quantity(product);
    }
    return minor / 100;
  }

  void _confirm() {
    if (!_valid) return;
    final saved = context.read<DeliveryDraftCubit>().setExtraQuantities(
      _quantities,
    );
    if (saved) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.products
        .where((product) {
          if (_query.isEmpty) return true;
          final text = '${product.itemName} ${product.itemCode}'.toLowerCase();
          return text.contains(_query);
        })
        .toList(growable: false);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: FractionallySizedBox(
            heightFactor: .86,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.strings.delivery_extra_products,
                          style: Styles.textStyle21.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.black1,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) =>
                        setState(() => _query = value.trim().toLowerCase()),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: context.strings.direct_sale_choose_products,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(context.strings.direct_sale_no_products),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final product = filtered[index];
                            final quantity = _quantity(product);
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.white0,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.grey3),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.itemName,
                                    style: Styles.textStyle15.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${product.itemCode} • '
                                    '${formatTripAmount(context, product.rate)} / ${product.uom}',
                                    style: Styles.textStyle12.copyWith(
                                      color: AppColors.grey4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    context.strings.direct_sale_available(
                                      product.availableQuantity,
                                    ),
                                    style: Styles.textStyle12.copyWith(
                                      color: AppColors.green0,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        tooltip: context
                                            .strings
                                            .direct_sale_decrease,
                                        onPressed: quantity > 0
                                            ? () => _changeQuantity(
                                                product,
                                                quantity - 1,
                                              )
                                            : null,
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 42,
                                        child: Text(
                                          '$quantity',
                                          textAlign: TextAlign.center,
                                          style: Styles.textStyle17,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: context
                                            .strings
                                            .direct_sale_increase,
                                        onPressed:
                                            quantity < product.availableQuantity
                                            ? () => _changeQuantity(
                                                product,
                                                quantity + 1,
                                              )
                                            : null,
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                  decoration: BoxDecoration(
                    color: AppColors.white0,
                    border: Border(top: BorderSide(color: AppColors.grey3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.strings.delivery_extra_products,
                            ),
                          ),
                          Text(
                            formatTripAmount(context, _total),
                            style: Styles.textStyle18.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      if (!_valid)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            context.strings.delivery_invalid_items,
                            style: TextStyle(color: AppColors.red0),
                          ),
                        ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _valid ? _confirm : null,
                        child: Text(context.strings.delivery_confirm_button),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
