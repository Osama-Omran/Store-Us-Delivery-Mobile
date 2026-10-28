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

import 'reschedule_date_time_fields.dart';
import 'reschedule_order_form.dart';

import 'package:storeus_delivery/core/theme/text_styles.dart';

class RescheduleOrderSheet extends StatefulWidget {
  const RescheduleOrderSheet({
    super.key,
    required this.tripId,
    required this.orderId,
    required this.salesOrder,
    required this.customerName,
    required this.address,
  });

  final int tripId;
  final int orderId;
  final String salesOrder;
  final String customerName;
  final String address;

  @override
  State<RescheduleOrderSheet> createState() => _RescheduleOrderSheetState();
}

class _RescheduleOrderSheetState extends State<RescheduleOrderSheet> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedReason;

  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  DateTime? get _selectedDateTime {
    if (_selectedDate == null || _selectedTime == null) {
      return null;
    }

    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  bool get _canSubmit {
    final dateTime = _selectedDateTime;

    return dateTime != null &&
        dateTime.isAfter(DateTime.now()) &&
        context.read<DeliveryOutcomeCubit>().reasonsCubit.containsReason(
          DeliveryReasonCategory.rescheduling,
          _selectedReason,
        );
  }

  // ======= Date Picker ======= //
  Future<void> _selectDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1, now.month, now.day),
    );

    if (!mounted || date == null) return;

    setState(() => _selectedDate = date);
  }

  // ======= Time Picker ======= //
  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (!mounted || time == null) return;

    setState(() => _selectedTime = time);
  }

  // ======= Submit Reschedule ======= //
  void _submit() {
    final dateTime = _selectedDateTime;

    if (!_canSubmit || dateTime == null) return;

    context.read<DeliveryOutcomeCubit>().submit(
      outcome: DeliveryOutcomeType.rescheduled,
      tripId: widget.tripId,
      orderId: widget.orderId,
      reason: _selectedReason!,
      rescheduledFor: DeliveryOutcomeRequestBody.formatRescheduledFor(dateTime),
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

  String _formatDate(DateTime date) {
    String pad(int value) => value.toString().padLeft(2, '0');

    return '${pad(date.day)}/${pad(date.month)}/${date.year}';
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
                _showError(
                  state.message == 'delivery_outcome_failed'
                      ? context.strings.reschedule_order_failed
                      : state.message == 'delivery_outcome_invalid_date'
                      ? context.strings.reschedule_date_must_be_future
                      : state.message == 'delivery_outcome_invalid_reason'
                      ? context.strings.delivery_reasons_select
                      : state.message,
                );
                return;
              }

              if (state is DeliveryOutcomeSuccess) {
                final scheduledAt = _selectedDateTime!;

                // Return data to OrderActionBar after API success.
                Navigator.of(context).pop({
                  'trip_id': widget.tripId,
                  'order_id': widget.orderId,
                  'sales_order': widget.salesOrder,
                  'customer_name': widget.customerName,
                  'rescheduled_for':
                      DeliveryOutcomeRequestBody.formatRescheduledFor(
                        scheduledAt,
                      ),
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
                      heightFactor: 0.9,
                      child: Column(
                        children: [
                          // ======= Drag Handle ======= //
                          const SizedBox(height: 14),

                          Container(
                            width: 60,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.grey3,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          const SizedBox(height: 18),

                          Text(
                            context.strings.reschedule_order_title,
                            style: Styles.textStyle23.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.black1,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ======= Scrollable Form ======= //
                          Expanded(
                            child: RescheduleOrderForm(
                              customerName: widget.customerName,
                              salesOrder: widget.salesOrder,
                              address: widget.address,
                              dateTimeFields: RescheduleDateTimeFields(
                                dateLabel: _selectedDate == null
                                    ? context.strings.reschedule_date_hint
                                    : _formatDate(_selectedDate!),
                                timeLabel: _selectedTime == null
                                    ? '--:--'
                                    : MaterialLocalizations.of(context)
                                          .formatTimeOfDay(_selectedTime!),
                                isLoading: isLoading,
                                onSelectDate: _selectDate,
                                onSelectTime: _selectTime,
                              ),
                              dateIsPast:
                                  _selectedDateTime != null &&
                                  !_selectedDateTime!.isAfter(DateTime.now()),
                              reasonDropdown: DeliveryReasonDropdown(
                                cubit: context
                                    .read<DeliveryOutcomeCubit>()
                                    .reasonsCubit,
                                category: DeliveryReasonCategory.rescheduling,
                                value: _selectedReason,
                                label: context.strings.reschedule_reason,
                                enabled: !isLoading,
                                onChanged: (reason) =>
                                    setState(() => _selectedReason = reason),
                              ),
                              notesController: _notesController,
                              isLoading: isLoading,
                            ),
                          ),

                          // ======= Fixed Confirm Button ======= //
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                            decoration: BoxDecoration(
                              color: AppColors.white0,
                              border: Border(
                                top: BorderSide(color: AppColors.grey3),
                              ),
                            ),
                            child: SizedBox(
                              height: 66,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _canSubmit && !isLoading
                                    ? _submit
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  disabledBackgroundColor: AppColors.blue0,
                                  foregroundColor: AppColors.white0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(23),
                                  ),
                                ),
                                child: isLoading
                                    ? CircularProgressIndicator(
                                        color: AppColors.white0,
                                      )
                                    : Text(
                                        context.strings.reschedule_confirm,
                                        style: Styles.textStyle18.copyWith(
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
