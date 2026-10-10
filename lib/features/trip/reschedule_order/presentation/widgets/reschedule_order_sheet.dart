
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import 'package:storeus_delivery/features/trip/reschedule_order/presentation/cubit/reschedule_order_cubit.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/presentation/cubit/reschedule_order_state.dart';

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
  State<RescheduleOrderSheet> createState() =>
      _RescheduleOrderSheetState();
}

class _RescheduleOrderSheetState
    extends State<RescheduleOrderSheet> {
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
      firstDate: DateTime(
        now.year,
        now.month,
        now.day,
      ),
      lastDate: DateTime(
        now.year + 1,
        now.month,
        now.day,
      ),
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
        SnackBar(
          content: Text(message),
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
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      children: [
                        // ======= Customer Summary ======= //
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.grey5,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            spacing: 10,
                            children: [
                              _RescheduleInfoRow(
                                label: context.strings
                                    .order_customer_data,
                                value: widget.customerName,
                              ),
                              _RescheduleInfoRow(
                                label: context.strings.order,
                                value: widget.salesOrder,
                              ),
                              _RescheduleInfoRow(
                                label: context.strings
                                    .order_correct_address,
                                value: widget.address.isNotEmpty
                                    ? widget.address
                                    : '—',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ======= Date & Time ======= //
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  Text(
                                    context.strings
                                        .reschedule_new_date,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.black1,
                                    ),
                                  ),

                                  OutlinedButton(
                                    onPressed:
                                    isLoading ? null : _selectDate,
                                    style: OutlinedButton.styleFrom(
                                      minimumSize:
                                      const Size.fromHeight(58),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                      side: BorderSide(
                                        color: AppColors.grey3,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _selectedDate == null
                                                ? 'dd/mm/yyyy'
                                                : _formatDate(
                                              _selectedDate!,
                                            ),
                                            textDirection:
                                            TextDirection.ltr,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: AppColors.black1,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 19,
                                          color: AppColors.black1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  Text(
                                    context.strings
                                        .reschedule_new_time,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.black1,
                                    ),
                                  ),

                                  OutlinedButton(
                                    onPressed:
                                    isLoading ? null : _selectTime,
                                    style: OutlinedButton.styleFrom(
                                      minimumSize:
                                      const Size.fromHeight(58),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                      side: BorderSide(
                                        color: AppColors.grey3,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _selectedTime == null
                                                ? '--:--'
                                                : MaterialLocalizations
                                                .of(context)
                                                .formatTimeOfDay(
                                              _selectedTime!,
                                            ),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: AppColors.black1,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.access_time_outlined,
                                          size: 19,
                                          color: AppColors.black1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        if (_selectedDateTime != null &&
                            !_selectedDateTime!.isAfter(
                              DateTime.now(),
                            ))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              context.strings
                                  .reschedule_date_must_be_future,
                              style: TextStyle(
                                color: AppColors.red1,
                                fontSize: 13,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // ======= Reason ======= //
                        Text(
                          context.strings.reschedule_reason,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black1,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 9,
                          runSpacing: 10,
                          children: [
                            for (final reason in _reasons)
                              ChoiceChip(
                                label: Text(reason),
                                selected: _selectedReason == reason,
                                onSelected: isLoading
                                    ? null
                                    : (_) {
                                  setState(() {
                                    _selectedReason = reason;
                                  });
                                },
                                selectedColor: AppColors.blue4,
                                backgroundColor: AppColors.white0,
                                side: BorderSide(
                                  color: _selectedReason == reason
                                      ? AppColors.primary
                                      : AppColors.grey3,
                                ),
                                showCheckmark: false,
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _selectedReason == reason
                                      ? AppColors.primary
                                      : AppColors.black1,
                                ),
                              ),
                          ],
                        ),

                        if (_selectedReason == 'سبب آخر') ...[
                          const SizedBox(height: 12),

                          TextField(
                            controller: _otherReasonController,
                            enabled: !isLoading,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: context.strings
                                  .reschedule_other_reason_hint,
                              filled: true,
                              fillColor: AppColors.grey0,
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 22),

                        // ======= Optional Notes ======= //
                        Text(
                          context.strings.order_optional_notes,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.black1,
                          ),
                        ),

                        const SizedBox(height: 9),

                        TextField(
                          controller: _notesController,
                          enabled: !isLoading,
                          minLines: 2,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: context.strings
                                .reschedule_notes_hint,
                            filled: true,
                            fillColor: AppColors.grey0,
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: AppColors.grey3,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          context.strings.reschedule_notes_not_sent,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey4,
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // ======= Fixed Confirm Button ======= //
                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      16,
                    ),
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
                        onPressed:
                        _canSubmit && !isLoading ? _submit : null,
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
                          context.strings
                              .reschedule_confirm,
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

// =====================================================
// Customer Information Row
// =====================================================

class _RescheduleInfoRow extends StatelessWidget {
  const _RescheduleInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.grey4,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            value.isNotEmpty ? value : '—',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.black1,
            ),
          ),
        ),
      ],
    );
  }
}
