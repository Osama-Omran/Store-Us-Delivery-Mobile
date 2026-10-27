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

import '../widgets/delivery_payment_confirmation_sheet.dart';
import '../widgets/delivery_payment_content.dart';

import 'package:storeus_delivery/core/theme/text_styles.dart';

class DeliveryPaymentScreen extends StatefulWidget {
  const DeliveryPaymentScreen({super.key, required this.flow});

  final DeliveryFlowData flow;

  @override
  State<DeliveryPaymentScreen> createState() => _DeliveryPaymentScreenState();
}

class _DeliveryPaymentScreenState extends State<DeliveryPaymentScreen> {
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
          SnackBar(content: Text(context.strings.delivery_receipt_select_failed)),
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
              SnackBar(
                content: Text(context.localizedErrorMessage(message)),
                backgroundColor: AppColors.red0,
              ),
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
                      child: DeliveryPaymentContent(
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
                        onRemoveReceipt: () => setState(() => _receiptPhoto = null),
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
                      onPressed: isLoading || _isPickingReceipt || !_canConfirm
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
                              style: Styles.textStyle19.copyWith(
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
