import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';

import '../cubit/direct_sale_cubit.dart';
import '../cubit/direct_sale_state.dart';
import 'direct_sale_customer_form.dart';
import 'direct_sale_location_card.dart';
import 'direct_sale_notice.dart';

class DirectSaleNewCustomerBody extends StatelessWidget {
  const DirectSaleNewCustomerBody({super.key});
  @override
  Widget build(BuildContext context) => ListView(
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
      const _CustomerStatus(),
    ],
  );
}

class _CustomerStatus extends StatelessWidget {
  const _CustomerStatus();
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DirectSaleCubit, DirectSaleState>(
        buildWhen: (previous, current) =>
            previous.creatingCustomer != current.creatingCustomer ||
            previous.customerCreateError != current.customerCreateError ||
            previous.retryOriginalCustomerRequest !=
                current.retryOriginalCustomerRequest,
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                message: context
                    .strings
                    .direct_sale_customer_retry_same_request_notice,
              ),
            ],
          ],
        ),
      );

  String _customerError(BuildContext context, DirectSaleState state) {
    return switch (state.customerCreateError) {
      'direct_sale_customer_invalid_fields' =>
        context.strings.direct_sale_customer_invalid_fields,
      'direct_sale_customer_create_failed' =>
        context.strings.direct_sale_customer_create_failed,
      'direct_sale_customer_missing_id' =>
        context.strings.direct_sale_customer_missing_id,
      'direct_sale_customer_verify_before_retry' =>
        context.strings.direct_sale_customer_verify_before_retry,
      'direct_sale_customer_retry_same_data' =>
        context.strings.direct_sale_customer_retry_same_data,
      final message =>
        message ?? context.strings.direct_sale_customer_create_failed,
    };
  }
}
