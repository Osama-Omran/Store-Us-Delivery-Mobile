import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import '../widgets/stock_transfer_header.dart';
import '../widgets/stock_transfer_body.dart';

// LayoutScreen owns the Cubit shared by this screen and the drawer badge.
class StockTransferScreen extends StatelessWidget {
  const StockTransferScreen({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.grey0,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          StockTransferHeader(onBack: onBack),
          const Expanded(child: StockTransferBody()),
        ],
      ),
    ),
  );
}
