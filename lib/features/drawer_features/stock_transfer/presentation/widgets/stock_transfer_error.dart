import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import '../cubit/stock_transfer_cubit.dart';

class StockTransferError extends StatelessWidget {
  const StockTransferError({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.strings.stock_transfer_load_failed,
              textAlign: TextAlign.center,
              style: Styles.textStyle14.copyWith(color: AppColors.grey4),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: StockTransferCubit.get(context).load,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.strings.stock_transfer_retry),
            ),
          ],
        ),
      ),
    );
  }
}
