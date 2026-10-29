import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_reasons_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_reasons_state.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_outcome_request_body.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_reasons_response.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_reason_dropdown.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_outcome_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_outcome_state.dart';

class DeliveryOutcomeSheet extends StatefulWidget {
  const DeliveryOutcomeSheet({
    super.key,
    required this.tripId,
    required this.orderId,
    required this.outcome,
  });

  final int tripId;
  final int orderId;
  final DeliveryOutcomeType outcome;

  @override
  State<DeliveryOutcomeSheet> createState() => DeliveryOutcomeSheetState();
}

class DeliveryOutcomeSheetState extends State<DeliveryOutcomeSheet> {
  String? _selectedReason;
  DateTime? _rescheduleDateTime;

  bool get _isReschedule => widget.outcome == DeliveryOutcomeType.rescheduled;

  bool get _canSubmit =>
      context.read<DeliveryOutcomeCubit>().reasonsCubit.containsReason(
        _isReschedule
            ? DeliveryReasonCategory.rescheduling
            : DeliveryReasonCategory.cancellation,
        _selectedReason,
      ) &&
      (!_isReschedule ||
          (_rescheduleDateTime != null &&
              _rescheduleDateTime!.isAfter(DateTime.now())));

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
          ? DeliveryOutcomeRequestBody.formatRescheduledFor(
              _rescheduleDateTime!,
            )
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
    return BlocBuilder<DeliveryReasonsCubit, DeliveryReasonsState>(
      bloc: context.read<DeliveryOutcomeCubit>().reasonsCubit,
      builder: (context, _) =>
          BlocConsumer<DeliveryOutcomeCubit, DeliveryOutcomeState>(
            listenWhen: (_, current) => current is DeliveryOutcomeSuccess,
            listener: (context, state) {
              // The parent screen shows the final status and refreshes the order.
              if (state is DeliveryOutcomeSuccess && mounted) {
                Navigator.of(context).pop();
              }
            },
            builder: (context, state) {
              final loading = state is DeliveryOutcomeLoading;
              final error = state is DeliveryOutcomeFailure
                  ? state.message
                  : null;

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
                                      ? context
                                            .strings
                                            .delivery_reschedule_title
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
                          Text(
                            context.strings.delivery_outcome_reason,
                            style: Styles.textStyle16.copyWith(
                              color: AppColors.black1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DeliveryReasonDropdown(
                            cubit: context
                                .read<DeliveryOutcomeCubit>()
                                .reasonsCubit,
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
                                    ? context
                                          .strings
                                          .delivery_reschedule_choose_date
                                    : DeliveryOutcomeRequestBody.formatRescheduledFor(
                                        _rescheduleDateTime!,
                                      ),
                              ),
                            ),
                            if (_rescheduleDateTime != null &&
                                !_rescheduleDateTime!.isAfter(DateTime.now()))
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  context.strings.delivery_outcome_invalid_date,
                                  style: Styles.base.copyWith(
                                    color: AppColors.red1,
                                  ),
                                ),
                              ),
                          ],
                          if (error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _errorLabel(context, error),
                              style: Styles.base.copyWith(
                                color: AppColors.red1,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: loading || !_canSubmit
                                  ? null
                                  : _submit,
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
                                          ? context
                                                .strings
                                                .delivery_reschedule_confirm
                                          : context
                                                .strings
                                                .delivery_cancel_confirm,
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
          ),
    );
  }
}
