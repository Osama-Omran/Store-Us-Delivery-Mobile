import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/reports/data/models/reports_models.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';

import 'reports_card.dart';

class ReportsFinancialCard extends StatelessWidget {
  const ReportsFinancialCard({super.key, required this.summary});

  final ReportsSummary summary;

  @override
  Widget build(BuildContext context) => ReportsCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 15,
      children: [
        Text(
          context.strings.reports_financial_summary,
          style: Styles.textStyle18.copyWith(color: AppColors.black1),
        ),
        _AmountRow(
          label: context.strings.reports_invoiced_amount,
          amount: summary.invoicedAmount,
        ),
        _AmountRow(
          label: context.strings.reports_outstanding_amount,
          amount: summary.outstandingAmount,
        ),
        _AmountRow(
          label: context.strings.reports_received_warehouse,
          amount: summary.receivedByWarehouse,
        ),
        _AmountRow(
          label: context.strings.reports_custody_balance,
          amount: summary.custodyBalance,
        ),
      ],
    ),
  );
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.amount});

  final String label;
  final num? amount;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final labelWidget = Text(
        label,
        style: Styles.textStyle14.copyWith(color: AppColors.grey4),
      );
      final amountWidget = Text(
        amount == null ? '—' : formatTripAmount(context, amount!),
        textAlign: TextAlign.end,
        style: Styles.textStyle16.copyWith(color: AppColors.black1),
      );
      if (constraints.maxWidth < 300 ||
          MediaQuery.textScalerOf(context).scale(16) > 20) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 6,
          children: [labelWidget, amountWidget],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Expanded(child: labelWidget),
          Flexible(child: amountWidget),
        ],
      );
    },
  );
}
