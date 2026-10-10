
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import 'package:storeus_delivery/features/trip/cancel_delivery/presentation/cubit/cancel_delivery_cubit.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/presentation/cubit/cancel_delivery_state.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/presentation/widgets/cancel_delivery_confirmation_sheet.dart';

class CancelDeliverySheet extends StatefulWidget {
  const CancelDeliverySheet({
    super.key,
    required this.tripId,
    required this.orderId,
    required this.customerName,
    required this.salesOrder,
  });

  final int tripId;
  final int orderId;
  final String customerName;
  final String salesOrder;

  @override
  State<CancelDeliverySheet> createState() =>
      _CancelDeliverySheetState();
}

class _CancelDeliverySheetState
    extends State<CancelDeliverySheet> {
  final _otherReasonController = TextEditingController();
  final _notesController = TextEditingController();

  int? _selectedReasonIndex;

  List<String> _reasons(BuildContext context) => [
    context.strings.cancel_reason_customer_refused,
    context.strings.cancel_reason_customer_requested,
    context.strings.cancel_reason_shop_closed,
    context.strings.cancel_reason_cannot_contact,
    context.strings.cancel_reason_wrong_address,
    context.strings.cancel_reason_duplicate_order,
    context.strings.cancel_reason_other,
  ];

  String _selectedReason(BuildContext context) {
    final index = _selectedReasonIndex;

    if (index == null) return '';

    if (index == 6) {
      return _otherReasonController.text.trim();
    }

    return _reasons(context)[index];
  }

  bool _canSubmit(BuildContext context) =>
      _selectedReason(context).isNotEmpty;

  @override
  void dispose() {
    _otherReasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ======= Open Confirmation ======= //
  Future<void> _confirmCancellation() async {
    final reason = _selectedReason(context);

    if (reason.isEmpty) return;

    FocusScope.of(context).unfocus();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      backgroundColor: AppColors.white0,
      barrierColor:
      AppColors.black1.withValues(alpha: 0.45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (_) => CancelDeliveryConfirmationSheet(
        salesOrder: widget.salesOrder,
        reason: reason,
      ),
    );

    if (!mounted || confirmed != true) return;

    // ======= Execute Real API ======= //
    context.read<CancelDeliveryCubit>().cancelDelivery(
      tripId: widget.tripId,
      orderId: widget.orderId,
      reason: reason,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.red0,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocConsumer<CancelDeliveryCubit, CancelDeliveryState>(
      listenWhen: (_, current) =>
      current is CancelDeliverySuccess ||
          current is CancelDeliveryFailure,
      listener: (context, state) {
        if (state is CancelDeliveryFailure) {
          final message = switch (state.message) {
            'cancel_delivery_failed' =>
            context.strings.cancel_delivery_failed,
            'cancel_reason_required' =>
            context.strings.cancel_delivery_reason_required,
            final message => message,
          };

          _showError(message);
          return;
        }

        if (state is CancelDeliverySuccess) {
          // Only return a result after the API succeeds.
          Navigator.of(context).pop(<String, dynamic>{
            'trip_id': widget.tripId,
            'order_id': widget.orderId,
            'sales_order': widget.salesOrder,
            'customer_name': widget.customerName,
            'reason': _selectedReason(context),
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is CancelDeliveryLoading;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: PopScope(
            canPop: !isLoading,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: FractionallySizedBox(
                heightFactor: 0.76,
                child: Column(
                  children: [
                    // ======= Drag Handle ======= //
                    const SizedBox(height: 13),

                    Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.grey3,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          context.strings.cancel_delivery_title,
                          style: Styles.textStyle22.copyWith(
                            color: AppColors.red1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ======= Scrollable Form ======= //
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        children: [
                          // ======= Order Information ======= //
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.grey5,
                              borderRadius:
                              BorderRadius.circular(22),
                            ),
                            child: Column(
                              spacing: 12,
                              children: [
                                _CancelInfoRow(
                                  title: context.strings
                                      .order_customer_data,
                                  value: widget.customerName,
                                ),
                                _CancelInfoRow(
                                  title: context.strings.order,
                                  value: widget.salesOrder,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ======= Reasons ======= //
                          Text(
                            context.strings
                                .cancel_delivery_reason_required,
                            style: Styles.textStyle16.copyWith(
                              color: AppColors.black1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 8,
                            runSpacing: 9,
                            children: [
                              for (int i = 0;
                              i < _reasons(context).length;
                              i++)
                                ChoiceChip(
                                  showCheckmark: false,
                                  selected:
                                  _selectedReasonIndex == i,
                                  label: Text(
                                    _reasons(context)[i],
                                  ),
                                  onSelected: isLoading
                                      ? null
                                      : (_) => setState(() {
                                    _selectedReasonIndex = i;
                                  }),
                                  backgroundColor: AppColors.white0,
                                  selectedColor: AppColors.red0,
                                  side: BorderSide(
                                    color: _selectedReasonIndex == i
                                        ? AppColors.red1
                                        : AppColors.grey3,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(25),
                                  ),
                                  labelStyle: Styles.textStyle14.copyWith(
                                    color: _selectedReasonIndex == i
                                        ? AppColors.white0
                                        : AppColors.black1,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                            ],
                          ),

                          // ======= Other Reason ======= //
                          if (_selectedReasonIndex == 6) ...[
                            const SizedBox(height: 12),

                            TextField(
                              controller: _otherReasonController,
                              enabled: !isLoading,
                              onChanged: (_) => setState(() {}),
                              maxLines: 2,
                              decoration: _inputDecoration(
                                context.strings
                                    .cancel_delivery_other_reason_hint,
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // ======= Optional Notes ======= //
                          Text(
                            context.strings.order_optional_notes,
                            style: Styles.textStyle16.copyWith(
                              color: AppColors.black1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 10),

                          TextField(
                            controller: _notesController,
                            enabled: !isLoading,
                            minLines: 2,
                            maxLines: 3,
                            decoration: _inputDecoration(
                              context.strings
                                  .cancel_delivery_notes_hint,
                            ),
                          ),

                          const SizedBox(height: 7),

                          Text(
                            context.strings
                                .cancel_delivery_notes_not_sent,
                            style: Styles.textStyle12.copyWith(
                              color: AppColors.grey4,
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // ======= Confirm Button ======= //
                    Container(
                      padding: const EdgeInsets.fromLTRB(
                        20, 12, 20, 20,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white0,
                        border: Border(
                          top: BorderSide(
                            color: AppColors.grey3,
                          ),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 68,
                        child: ElevatedButton(
                          onPressed: isLoading ||
                              !_canSubmit(context)
                              ? null
                              : _confirmCancellation,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.red1,
                            disabledBackgroundColor:
                            AppColors.red1.withValues(
                              alpha: 0.4,
                            ),
                            foregroundColor: AppColors.white0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(25),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              color: AppColors.white0,
                              strokeWidth: 2.5,
                            ),
                          )
                              : Text(
                            context.strings
                                .cancel_delivery_confirm_button,
                            style: Styles.textStyle18.copyWith(
                              color: AppColors.white0,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.grey0,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.grey3),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.grey3),
      ),
    );
  }
}

class _CancelInfoRow extends StatelessWidget {
  const _CancelInfoRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Expanded(
          child: Text(
            title,
            style: Styles.textStyle14.copyWith(
              color: AppColors.grey4,
            ),
          ),
        ),

        Expanded(
          flex: 2,
          child: Text(
            value.isEmpty ? '—' : value,
            textAlign: TextAlign.start,
            style: Styles.textStyle16.copyWith(
              color: AppColors.black1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
