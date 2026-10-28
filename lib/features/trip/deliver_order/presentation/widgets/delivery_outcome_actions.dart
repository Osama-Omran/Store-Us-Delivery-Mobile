import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_outcome_request_body.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_reasons_response.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_reason_dropdown.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_outcome_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_outcome_state.dart';

/// Available for PENDING orders, regardless of selected delivery quantities.
class DeliveryOutcomeActions extends StatelessWidget {
  const DeliveryOutcomeActions({
    super.key,
    required this.tripId,
    required this.orderId,
  });

  final int tripId;
  final int orderId;

  void _openSheet(BuildContext context, DeliveryOutcomeType outcome) {
    final cubit = context.read<DeliveryOutcomeCubit>();
    if (cubit.state is DeliveryOutcomeLoading ||
        cubit.state is DeliveryOutcomeSuccess) {
      return;
    }
    cubit.resetFailure();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      backgroundColor: AppColors.white0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _DeliveryOutcomeSheet(
          tripId: tripId,
          orderId: orderId,
          outcome: outcome,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeliveryOutcomeCubit, DeliveryOutcomeState>(
      builder: (context, state) {
        final disabled = state is DeliveryOutcomeLoading ||
            state is DeliveryOutcomeSuccess;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white0,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.grey3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.strings.delivery_outcome_actions_title,
                style: Styles.textStyle17.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.black1,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: disabled
                          ? null
                          : () => _openSheet(
                              context,
                              DeliveryOutcomeType.rescheduled,
                            ),
                      icon: const Icon(Icons.event_repeat_rounded),
                      label: Text(context.strings.delivery_reschedule),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: disabled
                          ? null
                          : () => _openSheet(
                              context,
                              DeliveryOutcomeType.cancelled,
                            ),
                      icon: const Icon(Icons.cancel_outlined),
                      label: Text(context.strings.delivery_cancel),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.red1,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DeliveryOutcomeSheet extends StatefulWidget {
  const _DeliveryOutcomeSheet({
    required this.tripId,
    required this.orderId,
    required this.outcome,
  });

  final int tripId;
  final int orderId;
  final DeliveryOutcomeType outcome;

  @override
  State<_DeliveryOutcomeSheet> createState() => _DeliveryOutcomeSheetState();
}

class _DeliveryOutcomeSheetState extends State<_DeliveryOutcomeSheet> {
  String? _selectedReason;
  DateTime? _rescheduleDateTime;

  bool get _isReschedule => widget.outcome == DeliveryOutcomeType.rescheduled;

  bool get _canSubmit =>
      _selectedReason != null && _selectedReason!.isNotEmpty &&
      (!_isReschedule ||
          (_rescheduleDateTime != null &&
              _rescheduleDateTime!.isAfter(DateTime.now())));

  /// Explicitly append the selected local time-zone offset.
  /// Dart's local DateTime.toIso8601String() omits the offset.
  static String _toApiDateTime(DateTime local) {
    final wallTime = '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}T'
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}:00';
    final offset = local.timeZoneOffset;
    final minutes = offset.inMinutes;
    final sign = minutes < 0 ? '-' : '+';
    final absoluteMinutes = minutes.abs();
    final hh = (absoluteMinutes ~/ 60).toString().padLeft(2, '0');
    final mm = (absoluteMinutes % 60).toString().padLeft(2, '0');
    return '$wallTime$sign$hh:$mm';
  }

  Future<void> _chooseDateTime() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _rescheduleDateTime ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2, now.month, now.day),
    );
    if (!mounted || selectedDate == null) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _rescheduleDateTime == null
          ? TimeOfDay.fromDateTime(now.add(const Duration(hours: 1)))
          : TimeOfDay.fromDateTime(_rescheduleDateTime!),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (!mounted || selectedTime == null) return;

    setState(() {
      _rescheduleDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
  }

  void _submit() {
    if (!_canSubmit) return;
    FocusManager.instance.primaryFocus?.unfocus();
    context.read<DeliveryOutcomeCubit>().submit(
      tripId: widget.tripId,
      orderId: widget.orderId,
      outcome: widget.outcome,
      reason: _selectedReason!,
      rescheduledFor: _isReschedule
          ? _toApiDateTime(_rescheduleDateTime!)
          : null,
    );
  }

  String _errorLabel(BuildContext context, String error) {
    return switch (error) {
      'delivery_outcome_invalid_reason' =>
        context.strings.delivery_outcome_invalid_reason,
      'delivery_outcome_invalid_date' =>
        context.strings.delivery_outcome_invalid_date,
      'delivery_outcome_failed' => context.strings.delivery_outcome_failed,
      _ => context.localizedErrorMessage(error),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryOutcomeCubit, DeliveryOutcomeState>(
      listenWhen: (_, current) => current is DeliveryOutcomeSuccess,
      listener: (context, state) {
        // The parent screen shows the final status and refreshes the order.
        if (state is DeliveryOutcomeSuccess && mounted) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final loading = state is DeliveryOutcomeLoading;
        final error = state is DeliveryOutcomeFailure ? state.message : null;

        return PopScope(
          canPop: !loading,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                18,
                20,
                MediaQuery.viewInsetsOf(context).bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _isReschedule
                                ? context.strings.delivery_reschedule_title
                                : context.strings.delivery_cancel_title,
                            style: Styles.textStyle20.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.black1,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: loading
                              ? null
                              : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isReschedule
                          ? context.strings.delivery_reschedule_hint
                          : context.strings.delivery_cancel_warning,
                      style: Styles.base.copyWith(color: AppColors.grey4),
                    ),
                    const SizedBox(height: 18),
                    DeliveryReasonDropdown(
                      category: _isReschedule
                          ? DeliveryReasonCategory.rescheduling
                          : DeliveryReasonCategory.cancellation,
                      label: context.strings.delivery_outcome_reason,
                      value: _selectedReason,
                      enabled: !loading,
                      onChanged: (value) {
                        setState(() => _selectedReason = value);
                      },
                    ),
                    if (_isReschedule) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: loading ? null : _chooseDateTime,
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: Text(
                          _rescheduleDateTime == null
                              ? context.strings.delivery_reschedule_choose_date
                              : _toApiDateTime(_rescheduleDateTime!),
                        ),
                      ),
                      if (_rescheduleDateTime != null &&
                          !_rescheduleDateTime!.isAfter(DateTime.now()))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            context.strings.delivery_outcome_invalid_date,
                            style: Styles.base.copyWith(color: AppColors.red1),
                          ),
                        ),
                    ],
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorLabel(context, error),
                        style: Styles.base.copyWith(color: AppColors.red1),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: loading || !_canSubmit ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isReschedule
                              ? AppColors.primary
                              : AppColors.red1,
                          foregroundColor: AppColors.white0,
                        ),
                        child: loading
                            ? CircularProgressIndicator(
                                color: AppColors.white0,
                              )
                            : Text(
                                _isReschedule
                                    ? context.strings.delivery_reschedule_confirm
                                    : context.strings.delivery_cancel_confirm,
                                style: Styles.textStyle17.copyWith(
                                  fontWeight: FontWeight.w800,
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
}
