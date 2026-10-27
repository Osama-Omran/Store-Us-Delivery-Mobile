import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/data/models/stock_transfer_model.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/widgets/stock_transfer_filters.dart';

class StockTransferStatusBadge extends StatelessWidget {
  const StockTransferStatusBadge({super.key, required this.transfer});

  final StockTransferModel transfer;

  Color get _foreground => switch (transfer.status) {
    StockTransferStatus.awaitingReceipt => AppColors.black1,
    StockTransferStatus.onVehicle => AppColors.primary,
    StockTransferStatus.awaitingWarehouse => AppColors.orange0,
    StockTransferStatus.completed => AppColors.green0,
    StockTransferStatus.receiptDiscrepancy => AppColors.red1,
    StockTransferStatus.other => AppColors.grey4,
  };

  Color get _background => switch (transfer.status) {
    StockTransferStatus.awaitingReceipt => AppColors.grey5,
    StockTransferStatus.onVehicle => AppColors.lightPrimary,
    StockTransferStatus.awaitingWarehouse => AppColors.orange1,
    StockTransferStatus.completed => AppColors.green1,
    StockTransferStatus.receiptDiscrepancy => AppColors.red2,
    StockTransferStatus.other => AppColors.grey5,
  };

  @override
  Widget build(BuildContext context) {
    final text = switch (transfer.status) {
      StockTransferStatus.receiptDiscrepancy =>
        context.strings.stock_transfer_receipt_discrepancy,
      StockTransferStatus.other => context.strings.trip_tab_unknown_status,
      _ => transfer.status.filter.label(context),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        text,
        style: Styles.textStyle14.copyWith(
          color: _foreground,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
      ),
    );
  }
}
