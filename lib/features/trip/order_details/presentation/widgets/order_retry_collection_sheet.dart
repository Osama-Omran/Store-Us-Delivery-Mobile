import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';
import 'package:storeus_delivery/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_cubit.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/utils/order_collection_policy.dart';

/// Result: true = accepted by backend; false = refresh required; null = cancelled.
class OrderRetryCollectionSheet extends StatefulWidget {
  const OrderRetryCollectionSheet({
    super.key,
    required this.cubit,
    required this.tripId,
    required this.order,
    required this.salesOrder,
    this.orderTotal,
  });

  final OrderDetailsCubit cubit;
  final int tripId;
  final TripOrderData order;
  final String salesOrder;
  final num? orderTotal;

  @override
  State<OrderRetryCollectionSheet> createState() =>
      _OrderRetryCollectionSheetState();
}

class _OrderRetryCollectionSheetState extends State<OrderRetryCollectionSheet> {
  final _notesController = TextEditingController();
  bool _submitting = false;
  bool _mustRefreshBeforeRetry = false;
  String? _error;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // This API response exposes order_total, not an invoice-specific amount.
  // Only permit full collection when one pending operation is identifiable.
  double? get _requiredAmount {
    final amount = widget.orderTotal?.toDouble();
    if (amount == null || amount <= 0 || !amount.isFinite) {
      return null;
    }
    return amount;
  }

  List<TripPendingCollection> get _pendingOperations {
    final seen = <String>{};
    return widget.order.pendingCollections.where((item) {
      final id = item.clientOperationId.trim();
      return id.isNotEmpty && seen.add(id);
    }).toList();
  }

  bool get _canCollect =>
      widget.order.canRetryCollection &&
      OrderCollectionPolicy.showCollectButton(widget.order.paymentStatus) &&
      _requiredAmount != null &&
      _pendingOperations.length == 1;

  Future<void> _send() async {
    if (_submitting || _mustRefreshBeforeRetry || !_canCollect) return;
    final requiredAmount = _requiredAmount!;
    final operationId = _pendingOperations.single.clientOperationId.trim();

    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.strings.retry_collection_confirm_full_amount),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.strings.order_number_label(widget.salesOrder)),
            const SizedBox(height: 8),
            Text(
              context.strings.order_required_amount_label(
                formatTripAmount(context, requiredAmount),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.strings.payment_method_label(
                context.strings.delivery_cash,
              ),
            ),
            const SizedBox(height: 12),
            Text(context.strings.retry_collection_confirm_notice),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.strings.retry_collection_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.strings.retry_collection_confirm),
          ),
        ],
      ),
    );
    if (!mounted || approved != true) return;

    setState(() {
      _submitting = true;
      _error = null;
    });
    final error = await widget.cubit.retryCollection(
      tripId: widget.tripId,
      orderId: widget.order.id,
      clientOperationId: operationId,
      collectedAmount: requiredAmount,
      notes: _notesController.text.trim(),
    );
    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      // Never allow a blind repeated payment after a timeout/unknown result.
      setState(() {
        _submitting = false;
        _mustRefreshBeforeRetry = true;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final requiredAmount = _requiredAmount;
    final operationCount = _pendingOperations.length;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: !_submitting,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * .86,
            ),
            decoration: BoxDecoration(
              color: AppColors.grey0,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.grey3,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.of(context)
                                .pop(_mustRefreshBeforeRetry ? false : null),
                      child: Text(context.strings.retry_collection_close),
                    ),
                  ),
                  Text(
                    context.strings.retry_collection_screen_title,
                    style: Styles.textStyle22.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.salesOrder,
                    style: Styles.base.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.white0,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.grey3),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.strings.retry_collection_full_amount_label,
                          style: Styles.textStyle14.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.grey4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          requiredAmount == null
                              ? context
                                    .strings
                                    .retry_collection_amount_unavailable
                              : formatTripAmount(context, requiredAmount),
                          style: Styles.textStyle24.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          context.strings.retry_collection_full_amount_notice,
                          style: Styles.textStyle13.copyWith(
                            color: AppColors.grey4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (requiredAmount == null || operationCount != 1) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.red1.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        requiredAmount == null
                            ? context
                                  .strings
                                  .retry_collection_amount_missing_error
                            : operationCount == 0
                            ? context.strings.retry_collection_no_pending_error
                            : context
                                  .strings
                                  .retry_collection_multiple_pending_error,
                        style: Styles.base.copyWith(
                          color: AppColors.red1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    context.strings.delivery_payment_method,
                    style: Styles.textStyle17.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.blue4,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.payments_outlined, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(
                          context.strings.delivery_cash,
                          style: Styles.base.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.check_circle, color: AppColors.primary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    context.strings.retry_collection_notes_label,
                    style: Styles.textStyle15.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    enabled: !_submitting && !_mustRefreshBeforeRetry,
                    minLines: 2,
                    maxLines: 3,
                    maxLength: 400,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.white0,
                      hintText: context.strings.retry_collection_notes_hint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.red1.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        context.localizedErrorMessage(_error!),
                        style: Styles.base.copyWith(
                          color: AppColors.red1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _mustRefreshBeforeRetry
                          ? () => Navigator.of(context).pop(false)
                          : _submitting || !_canCollect
                          ? null
                          : _send,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(19),
                        ),
                      ),
                      child: _submitting
                          ? SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                color: AppColors.white0,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _mustRefreshBeforeRetry
                                  ? context
                                        .strings
                                        .retry_collection_close_refresh
                                  : context
                                        .strings
                                        .retry_collection_confirm_full_amount,
                              style: Styles.textStyle16.copyWith(
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
      ),
    );
  }
}
