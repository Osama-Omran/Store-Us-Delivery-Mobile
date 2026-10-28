import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_outcome_request_body.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_reasons_response.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_outcome_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_outcome_state.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_reasons_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_reasons_state.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_reason_dropdown.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/presentation/widgets/cancel_delivery_confirmation_sheet.dart';

import 'cancel_delivery_form.dart';

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
  State<CancelDeliverySheet> createState() => _CancelDeliverySheetState();
}

class _CancelDeliverySheetState extends State<CancelDeliverySheet> {
  final _notesController = TextEditingController();

  String? _selectedReason;

  bool get _canSubmit => context
      .read<DeliveryOutcomeCubit>()
      .reasonsCubit
      .containsReason(DeliveryReasonCategory.cancellation, _selectedReason);

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ======= Open Confirmation ======= //
  Future<void> _confirmCancellation() async {
    if (!_canSubmit) return;
    final reason = _selectedReason!;

    FocusScope.of(context).unfocus();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      backgroundColor: AppColors.white0,
      barrierColor: AppColors.black1.withValues(alpha: 0.45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => CancelDeliveryConfirmationSheet(
        salesOrder: widget.salesOrder,
        reason: reason,
      ),
    );

    if (!mounted || confirmed != true) return;

    // ======= Execute Real API ======= //
    context.read<DeliveryOutcomeCubit>().submit(
      outcome: DeliveryOutcomeType.cancelled,
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
          content: Text(context.localizedErrorMessage(message)),
          backgroundColor: AppColors.red0,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocBuilder<DeliveryReasonsCubit, DeliveryReasonsState>(
      bloc: context.read<DeliveryOutcomeCubit>().reasonsCubit,
      builder: (context, _) =>
          BlocConsumer<DeliveryOutcomeCubit, DeliveryOutcomeState>(
            listenWhen: (_, current) =>
                current is DeliveryOutcomeSuccess ||
                current is DeliveryOutcomeFailure,
            listener: (context, state) {
              if (state is DeliveryOutcomeFailure) {
                final message = switch (state.message) {
                  'delivery_outcome_failed' =>
                    context.strings.cancel_delivery_failed,
                  'delivery_outcome_invalid_reason' =>
                    context.strings.cancel_delivery_reason_required,
                  final message => message,
                };

                _showError(message);
                return;
              }

              if (state is DeliveryOutcomeSuccess) {
                // Only return a result after the API succeeds.
                Navigator.of(context).pop(<String, dynamic>{
                  'trip_id': widget.tripId,
                  'order_id': widget.orderId,
                  'sales_order': widget.salesOrder,
                  'customer_name': widget.customerName,
                  'reason': _selectedReason,
                });
              }
            },
            builder: (context, state) {
              final isLoading = state is DeliveryOutcomeLoading;

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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            child: CancelDeliveryForm(
                              customerName: widget.customerName,
                              salesOrder: widget.salesOrder,
                              reasonDropdown: DeliveryReasonDropdown(
                                cubit: context
                                    .read<DeliveryOutcomeCubit>()
                                    .reasonsCubit,
                                category: DeliveryReasonCategory.cancellation,
                                value: _selectedReason,
                                label: context
                                    .strings
                                    .cancel_delivery_reason_required,
                                enabled: !isLoading,
                                onChanged: (reason) =>
                                    setState(() => _selectedReason = reason),
                              ),
                              notesController: _notesController,
                              isLoading: isLoading,
                            ),
                          ),

                          // ======= Confirm Button ======= //
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                            decoration: BoxDecoration(
                              color: AppColors.white0,
                              border: Border(
                                top: BorderSide(color: AppColors.grey3),
                              ),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 68,
                              child: ElevatedButton(
                                onPressed: isLoading || !_canSubmit
                                    ? null
                                    : _confirmCancellation,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: AppColors.red1,
                                  disabledBackgroundColor: AppColors.red1
                                      .withValues(alpha: 0.4),
                                  foregroundColor: AppColors.white0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
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
                                        context
                                            .strings
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
          ),
    );
  }
}
