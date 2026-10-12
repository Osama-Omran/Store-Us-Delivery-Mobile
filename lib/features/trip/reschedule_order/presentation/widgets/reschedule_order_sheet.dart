import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/presentation/cubit/reschedule_order_cubit.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/presentation/cubit/reschedule_order_state.dart';

import 'reschedule_date_time_fields.dart';
import 'reschedule_order_form.dart';

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
  final _otherReasonController = TextEditingController();

  final List<String> _reasons = const [
    'العميل طلب تغيير الموعد',
    'العميل غير متواجد',
    'المحل مغلق',
    'تعذر الوصول للعميل',
    'مشكلة في العنوان',
    'مشكلة في السيارة',
    'سبب آخر',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    _otherReasonController.dispose();
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

  String get _reason {
    if (_selectedReason == 'سبب آخر') {
      return _otherReasonController.text.trim();
    }

    return _selectedReason ?? '';
  }

  bool get _canSubmit {
    final dateTime = _selectedDateTime;

    return dateTime != null &&
        dateTime.isAfter(DateTime.now()) &&
        _reason.isNotEmpty;
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

    context.read<RescheduleOrderCubit>().rescheduleOrder(
      tripId: widget.tripId,
      orderId: widget.orderId,
      reason: _reason,
      rescheduledFor: dateTime,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.red0),
      );
  }

  String _formatDate(DateTime date) {
    String pad(int value) => value.toString().padLeft(2, '0');

    return '${pad(date.day)}/${pad(date.month)}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocConsumer<RescheduleOrderCubit, RescheduleOrderState>(
      listenWhen: (_, current) =>
          current is RescheduleOrderSuccess ||
          current is RescheduleOrderFailure,
      listener: (context, state) {
        if (state is RescheduleOrderFailure) {
          _showError(
            state.message == 'reschedule_order_failed'
                ? context.strings.reschedule_order_failed
                : state.message,
          );
          return;
        }

        if (state is RescheduleOrderSuccess) {
          final scheduledAt = _selectedDateTime!;

          // Return data to OrderActionBar after API success.
          Navigator.of(context).pop({
            'trip_id': widget.tripId,
            'order_id': widget.orderId,
            'sales_order': widget.salesOrder,
            'customer_name': widget.customerName,
            'rescheduled_for': scheduledAt.toIso8601String(),
            'reason': _reason,
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is RescheduleOrderLoading;

        return Directionality(
          textDirection: TextDirection.rtl,
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
                    style: TextStyle(
                      fontSize: 23,
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
                            ? 'dd/mm/yyyy'
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
                      reasons: _reasons,
                      selectedReason: _selectedReason,
                      otherReasonController: _otherReasonController,
                      notesController: _notesController,
                      isLoading: isLoading,
                      onReasonSelected: (reason) {
                        setState(() {
                          _selectedReason = reason;
                        });
                      },
                      onOtherReasonChanged: () {
                        setState(() {});
                      },
                    ),
                  ),

                  // ======= Fixed Confirm Button ======= //
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    decoration: BoxDecoration(
                      color: AppColors.white0,
                      border: Border(top: BorderSide(color: AppColors.grey3)),
                    ),
                    child: SizedBox(
                      height: 66,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canSubmit && !isLoading ? _submit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.blue0,
                          foregroundColor: AppColors.white0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(23),
                          ),
                        ),
                        child: isLoading
                            ? CircularProgressIndicator(color: AppColors.white0)
                            : Text(
                                context.strings.reschedule_confirm,
                                style: const TextStyle(
                                  fontSize: 18,
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
        );
      },
    );
  }
}
