import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_flow_data.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_flow_header.dart';

class DeliveryResultScreen extends StatefulWidget {
  const DeliveryResultScreen({super.key, required this.flow});

  final DeliveryFlowData flow;

  @override
  State<DeliveryResultScreen> createState() => _DeliveryResultScreenState();
}

class _DeliveryResultScreenState extends State<DeliveryResultScreen> {
  int? _reasonIndex;

  final _otherReasonController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _otherReasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<String> _reasons(BuildContext context) => [
    context.strings.delivery_reason_customer_refused,
    context.strings.delivery_reason_stock_unavailable,
    context.strings.delivery_reason_customer_requested_less,
    context.strings.delivery_reason_damaged,
    context.strings.delivery_reason_other,
  ];

  String get _selectedReason {
    if (_reasonIndex == null) return '';

    if (_reasonIndex == 4) {
      return _otherReasonController.text.trim();
    }

    return _reasons(context)[_reasonIndex!];
  }

  void _continue() {
    if (widget.flow.isPartial && _selectedReason.isEmpty) {
      return;
    }

    context.pushNamed(
      RoutesNames.deliveryPayment,
      extra: widget.flow.copyWith(
        partialReason: widget.flow.isPartial ? _selectedReason : null,
        notes: _notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flow = widget.flow;
    final partial = flow.isPartial;
    final amount = flow.estimatedTotal;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.grey0,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              DeliveryFlowHeader(
                title: context.strings.delivery_result_title,
                subtitle: '${flow.salesOrder} • ${flow.customerName}',
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // ======= Delivery Status ======= //
                    Container(
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: partial ? AppColors.orange1 : AppColors.green1,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: partial ? AppColors.orange0 : AppColors.green0,
                        ),
                      ),
                      child: Column(
                        spacing: 13,
                        children: [
                          Row(
                            children: [
                              Icon(
                                partial
                                    ? Icons.warning_amber_rounded
                                    : Icons.check_circle_outline,
                                color: partial
                                    ? AppColors.orange0
                                    : AppColors.green0,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  partial
                                      ? context.strings.delivery_partial_draft
                                      : context.strings.delivery_full_draft,
                                  style: TextStyle(
                                    color: partial
                                        ? AppColors.orange0
                                        : AppColors.green0,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _QtyBox(
                                title: context.strings.delivery_ordered,
                                qty: flow.orderedQty,
                              ),
                              const SizedBox(width: 8),
                              _QtyBox(
                                title: context.strings.delivery_selected,
                                qty: flow.deliveredQty,
                              ),
                              const SizedBox(width: 8),
                              _QtyBox(
                                title: context.strings.delivery_not_delivered,
                                qty: flow.remainingQty,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    _FinancialResult(
                      original: flow.originalTotal,
                      estimated: amount,
                    ),

                    const SizedBox(height: 20),

                    if (partial) ...[
                      Text(
                        context.strings.delivery_partial_reason_required,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 9,
                        runSpacing: 9,
                        children: [
                          for (int i = 0; i < _reasons(context).length; i++)
                            ChoiceChip(
                              showCheckmark: false,
                              label: Text(_reasons(context)[i]),
                              selected: _reasonIndex == i,
                              onSelected: (_) {
                                setState(() => _reasonIndex = i);
                              },
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.white0,
                              labelStyle: TextStyle(
                                color: _reasonIndex == i
                                    ? AppColors.white0
                                    : AppColors.black1,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                      if (_reasonIndex == 4) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _otherReasonController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText:
                                context.strings.delivery_other_reason_hint,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],

                    Text(
                      context.strings.delivery_notes_title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _notesController,
                      minLines: 3,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: context.strings.delivery_notes_hint,
                        filled: true,
                        fillColor: AppColors.white0,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Text(
                      context.strings.delivery_reason_not_sent,
                      style: TextStyle(fontSize: 12, color: AppColors.grey4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 66,
              child: ElevatedButton(
                onPressed: partial && _selectedReason.isEmpty
                    ? null
                    : _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  context.strings.delivery_continue_payment,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QtyBox extends StatelessWidget {
  const _QtyBox({required this.title, required this.qty});

  final String title;
  final num qty;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white0,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          spacing: 4,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
            Text(
              '$qty',
              style: TextStyle(
                color: AppColors.black1,
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancialResult extends StatelessWidget {
  const _FinancialResult({required this.original, required this.estimated});

  final num? original;
  final num? estimated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        spacing: 16,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(context.strings.order_details_original_total),
              ),
              Text(
                original == null ? '—' : formatTripAmount(context, original!),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.strings.delivery_estimated_total,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                estimated == null ? '—' : formatTripAmount(context, estimated!),
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
