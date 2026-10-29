import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_flow_data.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_reasons_response.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_reason_dropdown.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/widgets/delivery_flow_header.dart';

import 'delivery_financial_result_card.dart';
import 'delivery_result_summary_card.dart';

import 'delivery_result_notes.dart';

class DeliveryResultForm extends StatefulWidget {
  const DeliveryResultForm({super.key, required this.flow});

  final DeliveryFlowData flow;

  @override
  State<DeliveryResultForm> createState() => _DeliveryResultFormState();
}

class _DeliveryResultFormState extends State<DeliveryResultForm> {
  String? _selectedReason;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _continue() {
    if (widget.flow.isPartial && _selectedReason == null) {
      return;
    }

    _hideKeyboard();

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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _hideKeyboard,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ======= Header ======= //
            DeliveryFlowHeader(
              title: context.strings.delivery_result_title,
              subtitle: '${flow.salesOrder} • ${flow.customerName}',
            ),

            // ======= Scrollable Content ======= //
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ======= Delivery Status ======= //
                  DeliveryResultSummaryCard(flow: flow),

                  const SizedBox(height: 18),

                  DeliveryFinancialResultCard(
                    original: flow.originalTotal,
                    estimated: amount,
                  ),

                  const SizedBox(height: 20),

                  // ======= Partial Delivery Reason ======= //
                  if (partial) ...[
                    Text(
                      context.strings.delivery_partial_reason_required,
                      style: Styles.textStyle17.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.black1,
                      ),
                    ),

                    const SizedBox(height: 10),

                    DeliveryReasonDropdown(
                      category: DeliveryReasonCategory.partialDelivery,
                      value: _selectedReason,
                      label: context.strings.delivery_partial_reason_required,
                      onChanged: (reason) {
                        setState(() => _selectedReason = reason);
                      },
                    ),

                    const SizedBox(height: 20),
                  ],

                  // ======= Notes ======= //
                  DeliveryResultNotes(
                    controller: _notesController,
                    onHideKeyboard: _hideKeyboard,
                  ),
                ],
              ),
            ),

            // ======= Fixed Bottom Button ======= //
            // Remains visible above the keyboard.
            SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: BoxDecoration(
                  color: AppColors.grey0,
                  border: Border(
                    top: BorderSide(color: AppColors.grey3, width: 1),
                  ),
                ),
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: partial && _selectedReason == null
                        ? null
                        : _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      context.strings.delivery_continue_finalization,
                      style: Styles.textStyle18.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
