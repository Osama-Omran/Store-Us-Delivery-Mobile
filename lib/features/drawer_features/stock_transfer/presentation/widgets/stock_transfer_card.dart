import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/data/models/stock_transfer_model.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/utils/stock_transfer_date_formatter.dart';
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
          // ======= Transfer Number and Status ======= //
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                transfer.number,
                textDirection: TextDirection.ltr,
                style: Styles.textStyle20.copyWith(color: AppColors.black1),
              ),
              StockTransferStatusBadge(status: transfer.status),
            ],
          ),
          const SizedBox(height: 16),

          // ======= Warehouse Route ======= //
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

          // ======= Transfer Information ======= //
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Expanded(
                child: Column(
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
                      value: formatStockTransferDate(
                        context,
                        transfer.createdAt,
                        referenceDate,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    _TransferField(
                      label: context.strings.stock_transfer_representative,
                      value: transfer.representative,
                    ),
                    _TransferField(
                      label: context.strings.stock_transfer_total_quantity,
                      value: '${transfer.totalQuantity}',
                      emphasizeValue: true,
                    ),
                    _TransferField(
                      label: context.strings.stock_transfer_expected_arrival,
                      value: formatStockTransferDate(
                        context,
                        transfer.expectedArrival,
                        referenceDate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: emphasizeValue
                ? TextStyle(
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
