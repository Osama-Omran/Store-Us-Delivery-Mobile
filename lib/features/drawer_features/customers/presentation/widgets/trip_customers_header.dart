import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import '../cubit/trip_customers_cubit.dart';
import '../cubit/trip_customers_state.dart';

class TripCustomersHeader extends StatelessWidget {
  const TripCustomersHeader({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TripCustomersCubit, TripCustomersState>(
        builder: (context, state) {
          final loading = state.status == TripCustomersStatus.loading;
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            decoration: const BoxDecoration(
              color: AppColors.grey0,
              border: Border(bottom: BorderSide(color: AppColors.grey3)),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: onBack,
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 19,
                        ),
                        tooltip: context.strings.trip_customers_back,
                      ),
                      Expanded(
                        child: Text(
                          context.strings.trip_customers_title,
                          textAlign: TextAlign.center,
                          style: Styles.textStyle22.copyWith(
                            color: AppColors.black1,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: loading
                            ? null
                            : () => context.read<TripCustomersCubit>().load(),
                        icon: const Icon(Icons.refresh_rounded, size: 23),
                        tooltip: context.strings.trip_customers_refresh,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    state.tripNumber.isEmpty
                        ? context.strings.trip_customers_count(
                            state.customers.length,
                          )
                        : context.strings.trip_customers_summary(
                            context.strings.trip_customers_count(
                              state.customers.length,
                            ),
                            state.tripNumber,
                          ),
                    textAlign: TextAlign.center,
                    style: Styles.textStyle12.copyWith(color: AppColors.grey4),
                  ),
                ],
              ),
            ),
          );
        },
      );
}
