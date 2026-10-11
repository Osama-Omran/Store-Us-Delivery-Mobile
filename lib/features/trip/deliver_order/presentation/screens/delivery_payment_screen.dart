import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_flow_data.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/screens/delivery_proof_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/confirm_delivery_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/confirm_delivery_state.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_flow_header.dart';

class DeliveryPaymentScreen extends StatefulWidget {
  const DeliveryPaymentScreen({super.key, required this.flow});

  final DeliveryFlowData flow;

  @override
  State<DeliveryPaymentScreen> createState() => _DeliveryPaymentScreenState();
}

class _DeliveryPaymentScreenState extends State<DeliveryPaymentScreen> {
  final _amountController = TextEditingController();
  DeliveryProofDraft? _proof;

  Future<void> _openProof() async {
    final proof = await context.pushNamed<DeliveryProofDraft>(
      RoutesNames.deliveryProof,
    );

    if (!mounted || proof == null) return;

    setState(() => _proof = proof);
  }

  // Only confirmed API value.
  final String _paymentMethod = 'cash';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? get _enteredAmount {
    String value = _amountController.text.trim();

    if (value.isEmpty) return null;

    // ======= Convert Arabic Digits To English ======= //
    const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
    const persianDigits = '۰۱۲۳۴۵۶۷۸۹';

    for (int i = 0; i < 10; i++) {
      value = value.replaceAll(arabicDigits[i], '$i');
      value = value.replaceAll(persianDigits[i], '$i');
    }

    // ======= Normalize Decimal Separator ======= //
    value = value.replaceAll('٫', '.');
    value = value.replaceAll(',', '.');

    // ======= Validate Numeric Value ======= //
    final validAmount = RegExp(r'^\d+(\.\d{1,2})?$');

    if (!validAmount.hasMatch(value)) {
      return null;
    }

    return double.tryParse(value);
  }

  num? get _expectedAmount => widget.flow.estimatedTotal;

  bool get _amountMatches {
    final entered = _enteredAmount;
    final expected = _expectedAmount;

    if (entered == null || expected == null) return false;

    return entered >= 0 &&
        ((entered * 100).round() - (expected * 100).round()).abs() == 0;
  }

  bool get _canConfirm =>
      _amountMatches &&
      !widget.flow.hasMissingLineIds &&
      widget.flow.apiItems.isNotEmpty &&
      _paymentMethod == 'cash';

  // ======= Review Bottom Sheet ======= //
  Future<void> _reviewDelivery() async {
    if (!_canConfirm) return;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: AppColors.white0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 15,
              children: [
                Text(
                  context.strings.delivery_confirmation_summary,
                  style: TextStyle(
                    color: AppColors.black1,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                _ReviewRow(
                  label: context.strings.order_customer_data,
                  value: widget.flow.customerName,
                ),
                _ReviewRow(
                  label: context.strings.order,
                  value: widget.flow.salesOrder,
                ),
                _ReviewRow(
                  label: context.strings.delivery_status_label,
                  value: widget.flow.isPartial
                      ? context.strings.delivery_partial_draft
                      : context.strings.delivery_full_draft,
                ),
                _ReviewRow(
                  label: context.strings.delivery_selected_items_value,
                  value: formatTripAmount(context, _expectedAmount!),
                ),
                _ReviewRow(
                  label: context.strings.delivery_collected_amount,
                  value: formatTripAmount(context, _enteredAmount!),
                ),
                _ReviewRow(
                  label: context.strings.delivery_payment_method,
                  value: context.strings.delivery_cash,
                ),
                Text(
                  context.strings.delivery_confirmation_warning,
                  style: TextStyle(color: AppColors.grey4),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green0,
                          foregroundColor: AppColors.white0,
                          minimumSize: const Size.fromHeight(58),
                        ),
                        child: Text(
                          context.strings.delivery_confirm_button,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(58),
                        ),
                        child: Text(context.strings.back),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || confirmed != true) return;

    // ======= Real POST ======= //
    context.read<ConfirmDeliveryCubit>().confirmDelivery(
      tripId: widget.flow.tripId,
      orderId: widget.flow.orderId,
      items: widget.flow.apiItems,
      collectedAmount: _enteredAmount!,
      paymentMethod: _paymentMethod,
    );
  }

  @override
  Widget build(BuildContext context) {
    final expected = _expectedAmount;

    return BlocConsumer<ConfirmDeliveryCubit, ConfirmDeliveryState>(
      listenWhen: (_, current) =>
          current is ConfirmDeliveryFailure ||
          current is ConfirmDeliverySuccess,
      listener: (context, state) {
        if (state is ConfirmDeliveryFailure) {
          final message = switch (state.message) {
            'delivery_invalid_items' => context.strings.delivery_invalid_items,
            'delivery_invalid_amount' =>
              context.strings.delivery_invalid_amount,
            'delivery_payment_not_supported' =>
              context.strings.delivery_payment_not_supported,
            'delivery_confirm_failed' =>
              context.strings.delivery_confirm_failed,
            final message => message,
          };

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(message), backgroundColor: AppColors.red0),
            );
        }

        if (state is ConfirmDeliverySuccess) {
          context.pushReplacementNamed(
            RoutesNames.deliverySuccess,
            extra: {
              'flow': widget.flow,
              'collected_amount': _enteredAmount!,
              'payment_method': _paymentMethod,
            },
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ConfirmDeliveryLoading;
        final entered = _enteredAmount;
        final showMismatch = entered != null && entered > 0 && !_amountMatches;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: PopScope(
            canPop: !isLoading,
            child: Scaffold(
              backgroundColor: AppColors.grey0,
              body: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    DeliveryFlowHeader(
                      title: context.strings.delivery_payment_title,
                      subtitle:
                          '${widget.flow.salesOrder} • ${widget.flow.customerName}',
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.white0,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(color: AppColors.grey3),
                            ),
                            child: Column(
                              spacing: 14,
                              children: [
                                _ReviewRow(
                                  label: context
                                      .strings
                                      .order_details_original_total,
                                  value: widget.flow.originalTotal == null
                                      ? '—'
                                      : formatTripAmount(
                                          context,
                                          widget.flow.originalTotal!,
                                        ),
                                ),
                                _ReviewRow(
                                  label: context
                                      .strings
                                      .delivery_selected_items_value,
                                  value: expected == null
                                      ? '—'
                                      : formatTripAmount(context, expected),
                                ),
                                Divider(color: AppColors.grey3),
                                _ReviewRow(
                                  label:
                                      context.strings.delivery_required_amount,
                                  value: expected == null
                                      ? '—'
                                      : formatTripAmount(context, expected),
                                  highlighted: true,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          Text(
                            context.strings.delivery_collected_amount,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 10),
                          TextField(
                            controller: _amountController,
                            enabled: !isLoading,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.right,
                            onChanged: (value) {
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              hintText: '0',
                              suffixText: context.strings.egp_currency,
                              filled: true,
                              fillColor: AppColors.white0,
                              contentPadding: const EdgeInsets.all(20),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(
                                  color: _amountMatches
                                      ? AppColors.green0
                                      : showMismatch
                                      ? AppColors.red1
                                      : AppColors.primary,
                                  width: 1.7,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.black1,
                              fontSize: 26,
                            ),
                          ),

                          const SizedBox(height: 10),

                          if (_amountMatches)
                            _StatusMessage(
                              message: context.strings.delivery_amount_matches,
                              success: true,
                            )
                          else if (showMismatch)
                            _StatusMessage(
                              message: context.strings.delivery_amount_mismatch,
                              success: false,
                            ),

                          if (widget.flow.hasMissingLineIds) ...[
                            const SizedBox(height: 12),
                            _StatusMessage(
                              message:
                                  context.strings.delivery_missing_line_ids,
                              success: false,
                            ),
                          ],

                          const SizedBox(height: 26),

                          Text(
                            context.strings.delivery_payment_method,
                            style: TextStyle(
                              color: AppColors.black1,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _PaymentMethodTile(
                                  icon: Icons.payments_outlined,
                                  title: context.strings.delivery_cash,
                                  selected: true,
                                  enabled: true,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: const _PaymentMethodTile(
                                  icon: Icons.phone_android,
                                  title: 'InstaPay',
                                  selected: false,
                                  enabled: false,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _PaymentMethodTile(
                                  icon: Icons.credit_card,
                                  title: context.strings.delivery_wallet,
                                  selected: false,
                                  enabled: false,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(
                            context.strings.delivery_payment_not_supported,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.grey4,
                            ),
                          ),

                          const SizedBox(height: 20),

                          OutlinedButton.icon(
                            onPressed: isLoading ? null : _openProof,
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: Text(
                              _proof?.hasProof == true
                                  ? context.strings.delivery_proof_prepared
                                  : context.strings.delivery_add_proof,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              bottomNavigationBar: SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  color: AppColors.white0,
                  child: SizedBox(
                    height: 68,
                    child: ElevatedButton(
                      onPressed: isLoading || !_canConfirm
                          ? null
                          : _reviewDelivery,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green0,
                        foregroundColor: AppColors.white0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(color: AppColors.white0)
                          : Text(
                              context.strings.delivery_confirm_button,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: highlighted ? AppColors.black1 : AppColors.grey4,
              fontWeight: highlighted ? FontWeight.w800 : FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: highlighted ? AppColors.primary : AppColors.black1,
              fontSize: highlighted ? 22 : 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.message, required this.success});

  final String message;
  final bool success;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: success
            ? AppColors.green1
            : AppColors.red1.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: success ? AppColors.green0 : AppColors.red1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.enabled,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : .45,
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: selected ? AppColors.blue4 : AppColors.white0,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.grey3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 7,
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.grey4),
            Text(
              title,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.black1,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
