import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_flow_data.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/confirm_delivery_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/confirm_delivery_state.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_flow_header.dart';

import 'delivery_payment_confirmation_sheet.dart';
import 'delivery_payment_content.dart';

import 'delivery_payment_listener.dart';
import 'delivery_payment_submit_button.dart';

class DeliveryPaymentForm extends StatefulWidget {
  const DeliveryPaymentForm({super.key, required this.flow});

  final DeliveryFlowData flow;

  @override
  State<DeliveryPaymentForm> createState() => _DeliveryPaymentFormState();
}

class _DeliveryPaymentFormState extends State<DeliveryPaymentForm> {
  final _amountController = TextEditingController();
  XFile? _receiptPhoto;
  bool _isPickingReceipt = false;

  // Only supported payment method in this application flow.
  static const String _paymentMethod = 'cash';

  @override
  void initState() {
    super.initState();
    final expected = widget.flow.estimatedTotal;
    if (expected != null && expected.isFinite && expected > 0) {
      _amountController.text = expected.toString();
    }
  }

  Future<void> _chooseReceipt() async {
    if (_isPickingReceipt) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(context.strings.delivery_receipt_camera),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.strings.delivery_receipt_gallery),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (!mounted || source == null) return;
    setState(() => _isPickingReceipt = true);
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );
      if (mounted && image != null) {
        setState(() => _receiptPhoto = image);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(context.strings.delivery_receipt_select_failed),
          ),
        );
    } finally {
      if (mounted) setState(() => _isPickingReceipt = false);
    }
  }

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

    if (entered == null || expected == null || expected <= 0) return false;

    return entered > 0 &&
        ((entered * 100).round() - (expected * 100).round()).abs() == 0;
  }

  bool get _canConfirm {
    if (widget.flow.hasMissingLineIds || widget.flow.apiItems.isEmpty) {
      return false;
    }

    // Full cash collection is required, never optional.
    return _amountMatches &&
        _enteredAmount != null &&
        _enteredAmount! > 0 &&
        _paymentMethod == 'cash';
  }

  // ======= Review Bottom Sheet ======= //
  Future<void> _reviewDelivery() async {
    if (!_canConfirm) return;

    // Keep the same selected receipt for the review and the API request.
    // Null means the optional receipt_photo field will be omitted.
    final selectedReceiptPhotoPath = _receiptPhoto?.path;

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
          expectedAmountText: _expectedAmount == null
              ? '—'
              : formatTripAmount(context, _expectedAmount!),
          enteredAmountText: formatTripAmount(context, _enteredAmount!),
          hasReceipt: selectedReceiptPhotoPath != null,
        );
      },
    );

    if (!mounted || confirmed != true) return;

    context.read<ConfirmDeliveryCubit>().confirmDelivery(
      tripId: widget.flow.tripId,
      orderId: widget.flow.orderId,
      items: widget.flow.apiItems,
      collectedAmount: _enteredAmount!,
      expectedAmount: _expectedAmount!,
      receiptPhotoPath: selectedReceiptPhotoPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    final expected = _expectedAmount;
    final entered = _enteredAmount;
    return DeliveryPaymentListener(
      onConfirmed: () => context.pushReplacementNamed(
        RoutesNames.deliverySuccess,
        extra: {
          'flow': widget.flow,
          'collected_amount': _enteredAmount!,
          'payment_method': _paymentMethod,
        },
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: DeliveryPaymentBackGuard(
          child: Scaffold(
            backgroundColor: AppColors.grey0,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  DeliveryFlowHeader(
                    title: context.strings.delivery_payment_title,
                    subtitle:
                        '${widget.flow.salesOrder} \u2022 ${widget.flow.customerName}',
                  ),
                  Expanded(
                    child:
                        BlocSelector<
                          ConfirmDeliveryCubit,
                          ConfirmDeliveryState,
                          bool
                        >(
                          selector: (state) => state is ConfirmDeliveryLoading,
                          builder: (context, isLoading) =>
                              DeliveryPaymentContent(
                                flow: widget.flow,
                                expected: expected,
                                amountController: _amountController,
                                isLoading: isLoading,
                                amountMatches: _amountMatches,
                                showMismatch:
                                    entered != null && !_amountMatches,
                                onAmountChanged: (_) => setState(() {}),
                                receiptPhoto: _receiptPhoto,
                                onChooseReceipt: _chooseReceipt,
                                onRemoveReceipt: () =>
                                    setState(() => _receiptPhoto = null),
                              ),
                        ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: DeliveryPaymentSubmitButton(
              isPickingReceipt: _isPickingReceipt,
              canConfirm: _canConfirm,
              onReview: _reviewDelivery,
            ),
          ),
        ),
      ),
    );
  }
}
