import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';

import '../cubit/direct_sale_cubit.dart';
import '../cubit/direct_sale_state.dart';
import '../widgets/direct_sale_customer_form.dart';
import '../widgets/direct_sale_location_card.dart';
import '../widgets/direct_sale_notice.dart';
import '../widgets/direct_sale_page.dart';

class DirectSaleNewCustomerScreen extends StatelessWidget {
  const DirectSaleNewCustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<DirectSaleCubit>();
    final state = cubit.state;
    return DirectSalePage(
      newCustomer: true,
    footer: DirectSaleFooter(
      label: state.creatingCustomer
          ? context.strings.direct_sale_customer_saving
          : state.customerCreateError != null
              ? context.strings.current_trip_retry
              : context.strings.direct_sale_save_customer,
      onPressed: state.creatingCustomer ? null : cubit.createCustomer,
      secondaryLabel: context.strings.account_cancel,
      onSecondaryPressed: state.creatingCustomer ? null : cubit.goBack,
    ),
    child: ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(20),
      children: [
        const DirectSaleCustomerForm(),
        const SizedBox(height: 18),
        const DirectSaleLocationCard(),
        const SizedBox(height: 16),
        DirectSaleNotice(
          message: context.strings.direct_sale_customer_unsupported_fields,
        ),
        if (state.creatingCustomer) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
        if (state.customerCreateError != null) ...[
          const SizedBox(height: 16),
          DirectSaleNotice(
            error: true,
            message: _customerError(context, state),
          ),
        ],
        if (state.retryOriginalCustomerRequest) ...[
          const SizedBox(height: 8),
          DirectSaleNotice(
            message: context.strings.direct_sale_customer_retry_same_request_notice,
          ),
        ],
      ],
    ),
  );
  }

  String _customerError(BuildContext context, DirectSaleState state) {
    return switch (state.customerCreateError) {
      'direct_sale_customer_invalid_fields' => context.strings.direct_sale_customer_invalid_fields,
      'direct_sale_customer_create_failed' => context.strings.direct_sale_customer_create_failed,
      'direct_sale_customer_missing_id' => context.strings.direct_sale_customer_missing_id,
      'direct_sale_customer_verify_before_retry' => context.strings.direct_sale_customer_verify_before_retry,
      'direct_sale_customer_retry_same_data' => context.strings.direct_sale_customer_retry_same_data,
      final message => message ?? context.strings.direct_sale_customer_create_failed,
    };
  }
}
