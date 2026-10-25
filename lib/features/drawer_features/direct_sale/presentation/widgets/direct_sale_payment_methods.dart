import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import '../../data/models/direct_sale_models.dart';
import '../cubit/direct_sale_cubit.dart';

extension DirectSalePaymentLabels on DirectSalePaymentMethod {
  String label(BuildContext context) => switch (this) {
    DirectSalePaymentMethod.cash => context.strings.delivery_cash,
    DirectSalePaymentMethod.instaPay => context.strings.direct_sale_insta_pay,
    DirectSalePaymentMethod.wallet => context.strings.direct_sale_wallet,
  };

  IconData get icon => switch (this) {
    DirectSalePaymentMethod.cash => Icons.payments_outlined,
    DirectSalePaymentMethod.instaPay => Icons.phone_android_outlined,
    DirectSalePaymentMethod.wallet => Icons.account_balance_wallet_outlined,
  };
}

class DirectSalePaymentMethods extends StatelessWidget {
  const DirectSalePaymentMethods({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<DirectSaleCubit>();
    final state = cubit.state;
    return Row(
      spacing: 8,
      children: [
        for (final method in DirectSalePaymentMethod.values)
          Expanded(
            child: _PaymentTile(
              method: method,
              selected: state.paymentMethod == method,
              enabled:
                  state.amountMatches &&
                  state.availablePaymentMethods.contains(method),
              onPressed: () => cubit.selectPaymentMethod(method),
            ),
          ),
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.enabled,
    required this.onPressed,
  });
  final DirectSalePaymentMethod method;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: enabled,
    selected: selected,
    child: Opacity(
      opacity: enabled ? 1 : .45,
      child: Material(
        color: selected ? AppColors.blue4 : AppColors.white0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.grey3,
          ),
        ),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            child: Column(
              spacing: 6,
              children: [
                Icon(
                  method.icon,
                  size: 22,
                  color: selected ? AppColors.primary : AppColors.grey4,
                ),
                Text(
                  method.label(context),
                  textAlign: TextAlign.center,
                  style: Styles.textStyle12.copyWith(
                    color: selected ? AppColors.primary : AppColors.black1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
