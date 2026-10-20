import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';

/// Separate payment state from delivery state: DELIVERED != PAID.
class OrderCollectionStatusCard extends StatelessWidget {
  const OrderCollectionStatusCard({super.key, required this.order});

  final TripOrderData order;

  @override
  Widget build(BuildContext context) {
    final payment = order.paymentStatus.trim().toUpperCase();
    final paid = const {'PAID', 'COLLECTED', 'FULLY_PAID'}.contains(payment);
    final partial = const {
      'PARTIAL', 'PARTIALLY_PAID', 'PARTIAL_PAID', 'PARTIALLY_COLLECTED',
    }.contains(payment);
    final noPayment = const {
      'PENDING', 'UNPAID', 'NOT_PAID', 'PAYMENT_PENDING',
    }.contains(payment) || order.operationStatus.toUpperCase() == 'PAYMENT_PENDING';

    final title = paid
        ? 'تم التحصيل بالكامل'
        : partial
            ? 'لم يكتمل التحصيل'
            : noPayment
                ? 'لم يتم التحصيل'
                : 'حالة التحصيل: ${payment.isEmpty ? 'غير متاحة' : payment}';
    final color = paid
        ? AppColors.green0
        : partial
            ? AppColors.orange0
            : noPayment
                ? AppColors.red1
                : AppColors.grey4;
    final tint = paid
        ? AppColors.green1
        : partial
            ? AppColors.orange1
            : noPayment
                ? AppColors.red1.withValues(alpha: .09)
                : AppColors.grey5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 23),
              const SizedBox(width: 8),
              Expanded(child: Text('حالة تحصيل الطلب', style: Styles.textStyle16.copyWith(
                color: AppColors.black1, fontWeight: FontWeight.w800,
              ))),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(15)),
            child: Row(children: [
              Icon(paid ? Icons.check_circle_outline_rounded :
                partial ? Icons.pie_chart_outline_rounded : Icons.info_outline_rounded,
                size: 22, color: color),
              const SizedBox(width: 9),
              Expanded(child: Text(title, style: Styles.textStyle14.copyWith(
                color: color, fontWeight: FontWeight.w800,
              ))),
            ]),
          ),
          if (!paid && order.canRetryCollection && order.pendingCollections.isNotEmpty) ...[
            const SizedBox(height: 9),
            Text('يمكن إكمال التحصيل من الزر الموجود أسفل الشاشة، من غير إعادة تسليم الطلب.',
              style: Styles.textStyle14.copyWith(color: AppColors.grey4)),
          ] else if (!paid && noPayment) ...[
            const SizedBox(height: 9),
            Text('إكمال التحصيل غير متاح حاليًا. اسحب لتحديث حالة الطلب أو تواصل مع الإدارة.',
              style: Styles.textStyle14.copyWith(color: AppColors.grey4)),
          ],
        ],
      ),
    );
  }
}
