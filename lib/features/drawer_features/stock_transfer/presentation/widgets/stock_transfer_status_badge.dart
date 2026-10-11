import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/data/models/stock_transfer_model.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/widgets/stock_transfer_filters.dart';

class StockTransferStatusBadge extends StatelessWidget {
  const StockTransferStatusBadge({super.key, required this.status});

  final StockTransferStatus status;

  Color get _foreground => switch (status) {
    StockTransferStatus.awaitingReceipt => AppColors.black1,
    StockTransferStatus.onVehicle => AppColors.primary,
    StockTransferStatus.awaitingWarehouse => AppColors.orange0,
    StockTransferStatus.completed => AppColors.green0,
    StockTransferStatus.receiptDiscrepancy => AppColors.red1,
  };

  Color get _background => switch (status) {
    StockTransferStatus.awaitingReceipt => AppColors.grey5,
    StockTransferStatus.onVehicle => AppColors.lightPrimary,
    StockTransferStatus.awaitingWarehouse => AppColors.orange1,
    StockTransferStatus.completed => AppColors.green1,
    StockTransferStatus.receiptDiscrepancy => AppColors.red2,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        status == StockTransferStatus.receiptDiscrepancy
            ? context.strings.stock_transfer_receipt_discrepancy
            : status.filter.label(context),
        style: Styles.textStyle14.copyWith(
          color: _foreground,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
      ),
    );
  }
}
