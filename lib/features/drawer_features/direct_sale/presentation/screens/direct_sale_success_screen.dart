import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/core/widgets/custom_button.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';

import '../../data/models/direct_sale_models.dart';
import '../cubit/direct_sale_cubit.dart';
import '../widgets/direct_sale_page.dart';
import '../widgets/direct_sale_payment_methods.dart';

class DirectSaleSuccessScreen extends StatelessWidget {
  const DirectSaleSuccessScreen({super.key, required this.receipt});
  final DirectSaleReceipt receipt;

  @override
  Widget build(BuildContext context) => DirectSalePage(
    footer: Container(
      decoration: BoxDecoration(
        color: AppColors.white0,
        border: Border(top: BorderSide(color: AppColors.grey3)),
      ),
      child: SafeArea(
        top: false,
        child: TextButton(
          onPressed: () => goBackFromDirectSale(context),
          style: TextButton.styleFrom(minimumSize: const Size.fromHeight(64)),
          child: Text(
            context.strings.back,
            style: Styles.textStyle18.copyWith(color: AppColors.primary),
          ),
        ),
      ),
    ),
    child: ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      children: [
        Center(
          child: CircleAvatar(
            radius: 42,
            backgroundColor: AppColors.green1,
            child: Icon(Icons.check_rounded, color: AppColors.green0, size: 48),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          context.strings.direct_sale_success,
          textAlign: TextAlign.center,
          style: Styles.textStyle24.copyWith(color: AppColors.black1),
        ),
        const SizedBox(height: 14),
        Text(
          context.strings.direct_sale_receipt_summary(
            receipt.customerName.trim().isEmpty
                ? context.strings.direct_sale_cash_customer
                : receipt.customerName,
            formatTripAmount(context, receipt.paidAmountMinor / 100),
            receipt.paymentMethod.label(context),
          ),
          textAlign: TextAlign.center,
          style: Styles.textStyle16.copyWith(color: AppColors.grey4),
        ),
        const SizedBox(height: 20),
        CustomButton(
          text: context.strings.direct_sale_new_transaction,
          radius: 24,
          withShadow: false,
          onPressed: DirectSaleCubit.get(context).newSale,
        ),
      ],
    ),
  );
}
