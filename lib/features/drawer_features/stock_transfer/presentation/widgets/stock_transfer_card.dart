import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/data/models/stock_transfer_model.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/widgets/stock_transfer_status_badge.dart';

class StockTransferCard extends StatelessWidget {
  const StockTransferCard({
    super.key,
    required this.transfer,
    required this.referenceDate,
  });

  final StockTransferModel transfer;
  final DateTime referenceDate;

  @override
  Widget build(BuildContext context) {
    final dateText = transfer.createdAt == null
        ? '—'
        : DateFormat('dd/MM/yyyy', 'en').format(transfer.createdAt!);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.grey3),
        boxShadow: [
          BoxShadow(
            color: AppColors.black1.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                transfer.number,
                style: Styles.textStyle20.copyWith(color: AppColors.black1),
              ),
              StockTransferStatusBadge(transfer: transfer),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 4,
            children: [
              Icon(
                Icons.warehouse_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              Text(
                transfer.sourceWarehouse,
                style: Styles.textStyle18.copyWith(color: AppColors.black1),
              ),
              Icon(Icons.swap_horiz_rounded, color: AppColors.grey4, size: 22),
              Text(
                transfer.destinationWarehouse,
                style: Styles.textStyle18.copyWith(color: AppColors.black1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    _TransferField(
                      label: context.strings.stock_transfer_vehicle,
                      value: transfer.vehicle,
                    ),
                    _TransferField(
                      label: context.strings.stock_transfer_item_count,
                      value: '${transfer.itemCount}',
                      emphasizeValue: true,
                    ),
                    _TransferField(
                      label: context.strings.stock_transfer_created,
                      value: dateText,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    _TransferField(
                      label: context.strings.stock_transfer_representative,
                      // Only representative_id is supplied, not the name.
                      value: transfer.representative.isNotEmpty
                          ? transfer.representative
                          : transfer.representativeId == null
                          ? '—'
                          : '#${transfer.representativeId}',
                    ),
                    _TransferField(
                      label: context.strings.stock_transfer_total_quantity,
                      value: '${transfer.totalQuantity}',
                      emphasizeValue: true,
                    ),
                    if (transfer.expectedArrival != null)
                      _TransferField(
                        label: context.strings.stock_transfer_expected_arrival,
                        value: DateFormat(
                          'dd/MM/yyyy',
                          'en',
                        ).format(transfer.expectedArrival!),
                      ),
                  ],
                ),
              ];
              if (constraints.maxWidth < 300 ||
                  MediaQuery.textScalerOf(context).scale(16) > 20) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: columns,
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  for (final column in columns) Expanded(child: column),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TransferField extends StatelessWidget {
  const _TransferField({
    required this.label,
    required this.value,
    this.emphasizeValue = false,
  });

  final String label;
  final String value;
  final bool emphasizeValue;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: context.strings.label_with_colon(label)),
          TextSpan(
            text: value.trim().isEmpty ? '—' : value,
            style: emphasizeValue
                ? Styles.base.copyWith(
                    color: AppColors.black1,
                    fontWeight: FontWeight.w700,
                  )
                : null,
          ),
        ],
      ),
      style: Styles.textStyle14.copyWith(color: AppColors.grey4, height: 1.6),
    );
  }
}
