import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';

import '../cubit/direct_sale_cubit.dart';
import '../cubit/direct_sale_state.dart';

class DirectSaleAmountField extends StatelessWidget {
  const DirectSaleAmountField({super.key});

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<DirectSaleCubit, DirectSaleState>(
    buildWhen: (previous, current) =>
        previous.amountText != current.amountText ||
        previous.products != current.products ||
        previous.quantities != current.quantities ||
        previous.submittingPos != current.submittingPos ||
        previous.posRetryOriginal != current.posRetryOriginal,
    builder: (context, state) {
      final cubit = DirectSaleCubit.get(context);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Text(
            context.strings.direct_sale_counted_amount,
            style: Styles.textStyle16.copyWith(color: AppColors.black1),
          ),
          TextField(
            key: const ValueKey('direct-sale-amount'),
            controller: cubit.amountController,
            enabled: !state.submittingPos && !state.posRetryOriginal,
            onChanged: cubit.changeAmount,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.right,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9٠-٩۰-۹.,٫]')),
            ],
            textInputAction: TextInputAction.done,
            style: Styles.textStyle24.copyWith(color: AppColors.black1),
            decoration: InputDecoration(
              hintText: context.strings.direct_sale_amount_hint,
              hintStyle: Styles.textStyle24.copyWith(color: AppColors.grey4),
              filled: true,
              fillColor: AppColors.white0,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: _border(
                state.amountMatches ? AppColors.green0 : AppColors.grey3,
              ),
              focusedBorder: _border(
                state.amountMatches ? AppColors.green0 : AppColors.black1,
              ),
            ),
          ),
          if (state.showAmountMismatch || state.amountMatches)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: state.amountMatches ? AppColors.green1 : AppColors.red2,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                state.amountMatches
                    ? context.strings.direct_sale_amount_matches
                    : context.strings.direct_sale_amount_mismatch(
                        state.pricedTotalMinor == null
                            ? '—'
                            : formatTripAmount(context, state.totalMinor / 100),
                      ),
                textAlign: TextAlign.center,
                style: Styles.textStyle14.copyWith(
                  fontWeight: FontWeight.w700,
                  color: state.amountMatches
                      ? AppColors.green0
                      : AppColors.red1,
                ),
              ),
            ),
        ],
      );
    },
  );

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(22),
    borderSide: BorderSide(color: color, width: 2),
  );
}
