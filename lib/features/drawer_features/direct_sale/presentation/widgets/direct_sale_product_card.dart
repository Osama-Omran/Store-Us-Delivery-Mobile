import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';

import '../../data/models/direct_sale_models.dart';
import '../cubit/direct_sale_cubit.dart';
import 'direct_sale_card.dart';

class DirectSaleProductCard extends StatelessWidget {
  const DirectSaleProductCard({super.key, required this.product});
  final DirectSaleProduct product;

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<DirectSaleCubit>();
    final quantity = cubit.state.quantityFor(product);
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 3,
      children: [
        Text(
          product.name,
          style: Styles.textStyle16.copyWith(
            color: AppColors.black1,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          product.unitPriceMinor == null
              ? '${product.code} · ${product.unit}'
              : '${product.code} · ${formatTripAmount(context, product.unitPriceMinor! / 100)} / ${product.unit}',
          style: Styles.textStyle12.copyWith(color: AppColors.grey4),
        ),
        Text(
          context.strings.direct_sale_available(product.availableQuantity),
          style: Styles.textStyle12.copyWith(color: AppColors.green0),
        ),
      ],
    );
    final quantityControl = Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(
            icon: Icons.add,
            primary: true,
            tooltip: context.strings.direct_sale_increase,
            onPressed: quantity < product.availableQuantity
                ? () => cubit.setQuantity(product, quantity + 1)
                : null,
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: Styles.textStyle16.copyWith(color: AppColors.black1),
              ),
            ),
          ),
          _QuantityButton(
            icon: Icons.remove,
            tooltip: context.strings.direct_sale_decrease,
            onPressed: quantity > 0
                ? () => cubit.setQuantity(product, quantity - 1)
                : null,
          ),
        ],
      ),
    );
    return DirectSaleCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 300 ||
              MediaQuery.textScalerOf(context).scale(16) > 20) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                details,
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: quantityControl,
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: details),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth / 2),
                child: quantityControl,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.tooltip,
    this.primary = false,
    this.onPressed,
  });
  final IconData icon;
  final String tooltip;
  final bool primary;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      backgroundColor: primary ? AppColors.primary : AppColors.white0,
      foregroundColor: primary ? AppColors.white0 : AppColors.black1,
      disabledBackgroundColor: primary ? AppColors.blue0 : AppColors.white0,
      disabledForegroundColor: primary ? AppColors.white0 : AppColors.grey4,
      side: primary ? BorderSide.none : BorderSide(color: AppColors.grey3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      fixedSize: const Size(48, 48),
      padding: EdgeInsets.zero,
    ),
    icon: Icon(icon, size: 20),
  );
}
