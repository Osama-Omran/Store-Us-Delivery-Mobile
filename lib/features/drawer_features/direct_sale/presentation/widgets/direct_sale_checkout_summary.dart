import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';

import '../cubit/direct_sale_cubit.dart';
import 'direct_sale_card.dart';

class DirectSaleCheckoutSummary extends StatelessWidget {
  const DirectSaleCheckoutSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DirectSaleCubit>().state;
    return DirectSaleCard(
      child: Column(
        spacing: 8,
        children: [
          for (final product in state.selectedProducts)
            _SummaryRow(
              label: '${product.name} × ${state.quantityFor(product)}',
              amount: product.unitPriceMinor == null
                  ? '—'
                  : formatTripAmount(
                      context,
                      product.unitPriceMinor! * state.quantityFor(product) / 100,
                    ),
            ),
          Divider(height: 8, color: AppColors.grey3),
          _SummaryRow(
            label: context.strings.direct_sale_total_required,
            amount: state.pricedTotalMinor == null
                ? '—'
                : formatTripAmount(context, state.totalMinor / 100),
            total: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.amount,
    this.total = false,
  });

  final String label;
  final String amount;
  final bool total;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final style = (total ? Styles.textStyle18 : Styles.textStyle14).copyWith(
        color: AppColors.black1,
      );
      final labelWidget = Text(label, style: style);
      final amountWidget = Text(
        amount,
        textAlign: TextAlign.end,
        style: style.copyWith(fontWeight: FontWeight.w700),
      );
      if (constraints.maxWidth < 300 ||
          MediaQuery.textScalerOf(context).scale(16) > 20) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: [labelWidget, amountWidget],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Expanded(child: labelWidget),
          Flexible(child: amountWidget),
        ],
      );
    },
  );
}
