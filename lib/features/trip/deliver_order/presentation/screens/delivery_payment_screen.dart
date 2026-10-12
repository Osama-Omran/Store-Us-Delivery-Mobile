import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_flow_data.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/confirm_delivery_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/confirm_delivery_state.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/screens/delivery_proof_screen.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_flow_header.dart';

import '../widgets/delivery_payment_confirmation_sheet.dart';
import '../widgets/delivery_payment_content.dart';

class DeliveryPaymentScreen extends StatefulWidget {
  const DeliveryPaymentScreen({super.key, required this.flow});

  final DeliveryFlowData flow;

  @override
  State<DeliveryPaymentScreen> createState() => _DeliveryPaymentScreenState();
}

class _DeliveryPaymentScreenState extends State<DeliveryPaymentScreen> {
  final _amountController = TextEditingController();
  bool _collectPayment = true;

  void _changeCollectionMode(bool value) {
    setState(() {
      _collectPayment = value;
    });
  }
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

  bool get _canConfirm {
    if (widget.flow.hasMissingLineIds ||
        widget.flow.apiItems.isEmpty) {
      return false;
    }

    // Delivery without collecting any money.
    if (!_collectPayment) {
      return true;
    }

    // Existing full-collection validation.
    return _amountMatches &&
        _enteredAmount != null &&
        _enteredAmount! > 0 &&
        _paymentMethod == 'cash';
  }

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
        return DeliveryPaymentConfirmationSheet(
          flow: widget.flow,
          strings: context.strings,
          collectPayment: _collectPayment,
          expectedAmountText: _expectedAmount == null
              ? '—'
              : formatTripAmount(context, _expectedAmount!),
          enteredAmountText: _collectPayment
              ? formatTripAmount(context, _enteredAmount!)
              : context.strings.delivery_not_collected,
        );
      },
    );

    if (!mounted || confirmed != true) return;

    context.read<ConfirmDeliveryCubit>().confirmDelivery(
      tripId: widget.flow.tripId,
      orderId: widget.flow.orderId,
      items: widget.flow.apiItems,
      collectedAmount: _collectPayment
          ? _enteredAmount
          : null,
      paymentMethod: _collectPayment
          ? _paymentMethod
          : null,
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
              'collected_amount': _collectPayment
                  ? _enteredAmount
                  : null,
              'payment_method': _collectPayment
                  ? _paymentMethod
                  : null,
            },
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ConfirmDeliveryLoading;
        final entered = _enteredAmount;

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
                      title: _collectPayment
                          ? context.strings.delivery_payment_title
                          : context.strings.delivery_finalize_title,
                      subtitle:
                          '${widget.flow.salesOrder} • ${widget.flow.customerName}',
                    ),
                    Expanded(
                      child: DeliveryPaymentContent(
                        flow: widget.flow,
                        expected: expected,
                        amountController: _amountController,
                        isLoading: isLoading,
                        amountMatches: _amountMatches,
                        showMismatch: _collectPayment &&
                            entered != null &&
                            entered > 0 &&
                            !_amountMatches,
                        onAmountChanged: (_) => setState(() {}),
                        hasProof: _proof?.hasProof == true,
                        onOpenProof: _openProof,
                        collectPayment: _collectPayment,
                        onCollectionChanged: _changeCollectionMode,
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
                          ? CircularProgressIndicator(
                        color: AppColors.white0,
                      )
                          : Text(
                        _collectPayment
                            ? context.strings.delivery_confirm_button
                            : context.strings.delivery_confirm_without_collection,
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
