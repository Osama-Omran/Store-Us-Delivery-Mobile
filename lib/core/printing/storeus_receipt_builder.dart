import 'package:storeus_delivery/core/printing/usb_esc_pos_printer.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';

/// Presentation-only receipts based on the existing order/trip APIs.
/// These are NOT tax invoices. Collection amounts are reported by the API.
class StoreusReceiptBuilder {
  const StoreusReceiptBuilder._();

  static ReceiptDocument order(
    OrderDetailsData order, {
    TripOrderModel? summary,
  }) {
    final currency = summary?.currency ?? 'EGP';
    final originalTotal = summary == null ? order.originalTotal : summary.orderAmount;
    final lines = <ReceiptLine>[
      ..._header('بيان الطلب', 'غير معتمد كفاتورة ضريبية'),
      ReceiptLine(order.salesOrder, kind: 'code', size: 22, bold: true, align: 'center', direction: 'ltr'),
      ReceiptLine.pair('تاريخ الطباعة', _printedAt()),
      if ((summary?.rawDeliveryStatus ?? order.deliveryStatus).trim().isNotEmpty)
        ReceiptLine.pair('حالة التسليم', _orderStatus(summary?.rawDeliveryStatus ?? order.deliveryStatus)),
      if (order.deliveryReason?.trim().isNotEmpty == true)
        ReceiptLine.pair('سبب حالة التسليم', order.deliveryReason!.trim()),
      const ReceiptLine('بيانات العميل', kind: 'section', bold: true),
    ];

    _appendPairIfPresent(lines, 'اسم العميل', order.customer?.name);
    _appendPairIfPresent(lines, 'رقم الهاتف', order.customer?.phone);
    if (order.customer?.address?.trim().isNotEmpty == true) {
      lines.add(const ReceiptLine('العنوان', kind: 'caption'));
      lines.add(ReceiptLine(order.customer!.address!.trim(), size: 21));
    }
    _appendPairIfPresent(lines, 'ملاحظات العميل', order.customer?.notes);

    lines.addAll([
      const ReceiptLine('الأصناف المطلوبة', kind: 'section', bold: true),
      ReceiptLine.pair('عدد الأصناف', '${order.items.length}'),
    ]);

    if (order.items.isEmpty) {
      lines.add(const ReceiptLine('لا توجد أصناف في الاستجابة', kind: 'note', align: 'center'));
    } else {
      for (var index = 0; index < order.items.length; index++) {
        final item = order.items[index];
        final name = item.itemName.trim().isEmpty ? item.itemCode : item.itemName;
        lines.add(ReceiptLine('${index + 1}. $name', kind: 'item', bold: true, size: 24));
        _appendPairIfPresent(lines, 'الكود', item.itemCode);
        lines.add(ReceiptLine.pair(
          'الكمية المطلوبة',
          '${_qty(item.orderedQty)} ${item.uom}'.trim(),
        ));
        if (item.rate != null) {
          lines.add(ReceiptLine.pair('سعر الوحدة', _amount(item.rate!, currency)));
          if (item.orderedQty != null) {
            final lineValue = item.orderedQty! * item.rate!;
            lines.add(ReceiptLine.pair('قيمة الصنف المحسوبة', _amount(lineValue, currency), bold: true));
          }
        }
        if (index < order.items.length - 1) {
          lines.add(const ReceiptLine.divider());
        }
      }
    }

    lines.add(const ReceiptLine('ملخص قيمة الطلب', kind: 'section', bold: true));
    lines.add(ReceiptLine.total(
      'القيمة الأصلية',
      originalTotal == null ? 'غير متاحة' : _amount(originalTotal, currency),
    ));
    if (summary != null) _appendCollectedAmount(lines, summary);
    lines.addAll(const <ReceiptLine>[
      ReceiptLine.spacer(),
      ReceiptLine('المبالغ والكميات النهائية للتسليم قد تختلف', kind: 'note', size: 18, align: 'center'),
      ReceiptLine('عن بيانات الطلب الأصلية', kind: 'note', size: 18, align: 'center'),
      ReceiptLine('هذا البيان ليس فاتورة ضريبية', kind: 'note', size: 18, align: 'center'),
      ReceiptLine.spacer(),
      ReceiptLine('STORE US  •  DELIVERY', kind: 'footer', align: 'center', direction: 'ltr', size: 18),
    ]);
    return ReceiptDocument(lines);
  }

  static ReceiptDocument trip({
    required String tripNumber,
    required List<TripOrderModel> orders,
  }) {
    final sorted = [...orders]..sort((a, b) => a.stopNumber.compareTo(b.stopNumber));
    final delivered = sorted.where((e) => e.status == TripOrderStatus.delivered).length;
    final partial = sorted.where((e) => e.status == TripOrderStatus.partiallyDelivered).length;
    final pending = sorted.where((e) => e.status == TripOrderStatus.pending).length;
    final other = sorted.length - delivered - partial - pending;

    final lines = <ReceiptLine>[
      ..._header('كشف أوردرات الرحلة', 'ليس فاتورة ضريبية'),
      ReceiptLine(tripNumber, kind: 'code', size: 22, bold: true, align: 'center', direction: 'ltr'),
      ReceiptLine.pair('تاريخ الطباعة', _printedAt()),
      const ReceiptLine('ملخص الرحلة', kind: 'section', bold: true),
      ReceiptLine.pair('عدد الأوردرات', '${sorted.length}', bold: true),
      ReceiptLine.pair('تم التسليم', '$delivered'),
      if (partial > 0) ReceiptLine.pair('تسليم جزئي', '$partial'),
      if (pending > 0) ReceiptLine.pair('قيد التسليم', '$pending'),
      if (other > 0) ReceiptLine.pair('حالات أخرى', '$other'),
      const ReceiptLine('تفاصيل الأوردرات', kind: 'section', bold: true),
    ];

    if (sorted.isEmpty) {
      lines.add(const ReceiptLine('لا توجد أوردرات في الرحلة', kind: 'note', align: 'center'));
    }

    for (var index = 0; index < sorted.length; index++) {
      final order = sorted[index];
      lines.add(ReceiptLine('${order.stopNumber}. ${order.id}', kind: 'item', bold: true, size: 23));
      _appendPairIfPresent(lines, 'العميل', order.customerName);
      lines.add(ReceiptLine.pair('حالة التسليم', _status(order.status)));
      lines.add(ReceiptLine.pair(
        'القيمة الأصلية',
        order.orderAmount == null
            ? 'غير متاحة'
            : _amount(order.orderAmount!, order.currency),
      ));
      _appendCollectedAmount(lines, order);
      if (index < sorted.length - 1) lines.add(const ReceiptLine.divider());
    }

    lines.add(const ReceiptLine('ملخص القيم', kind: 'section', bold: true));
    // Never combine different currencies or treat absent amounts as zero.
    final currencies = sorted.map((order) => order.currency).toSet();
    for (final currency in currencies) {
      final group = sorted.where((order) => order.currency == currency).toList();
      _appendTotal(
        lines,
        amounts: group.map((order) => order.orderAmount),
        currency: currency,
        completeLabel: 'إجمالي القيم الأصلية',
        incompleteLabel: 'مجموع القيم المتاحة فقط',
      );
      _appendTotal(
        lines,
        amounts: group.map((order) => order.reportedCollectedAmount),
        currency: currency,
        completeLabel: 'إجمالي المحصل فعليًا',
        incompleteLabel: 'مجموع التحصيل المتاح فقط',
      );
    }
    lines.addAll(const <ReceiptLine>[
      ReceiptLine.spacer(),
      ReceiptLine('القيم الأصلية منفصلة عن التحصيل الفعلي', kind: 'note', size: 18, align: 'center'),
      ReceiptLine('الكشف يشمل جميع أوردرات الرحلة', kind: 'note', size: 18, align: 'center'),
      ReceiptLine('STORE US  •  DELIVERY', kind: 'footer', align: 'center', direction: 'ltr', size: 18),
    ]);
    return ReceiptDocument(lines);
  }

  static void _appendCollectedAmount(
    List<ReceiptLine> lines,
    TripOrderModel order,
  ) {
    final amount = order.reportedCollectedAmount;
    if (amount == null) {
      lines.add(ReceiptLine.pair('المحصل فعليًا', 'غير متاح'));
    } else if (amount > 0) {
      lines.add(ReceiptLine.pair(
        'المحصل فعليًا',
        _amount(amount, order.currency),
        bold: true,
      ));
    }
  }

  static void _appendTotal(
    List<ReceiptLine> lines, {
    required Iterable<num?> amounts,
    required String currency,
    required String completeLabel,
    required String incompleteLabel,
  }) {
    final known = amounts.whereType<num>().toList();
    if (known.isEmpty) {
      lines.add(ReceiptLine.pair(completeLabel, 'غير متاح ($currency)'));
      return;
    }
    final total = known.fold<num>(0, (sum, amount) => sum + amount);
    lines.add(ReceiptLine.total(
      known.length == amounts.length ? completeLabel : incompleteLabel,
      _amount(total, currency),
    ));
  }

  static String _amount(num value, String currency) =>
      '${_money(value)} ${currency == 'EGP' ? 'ج.م' : currency}';

  static List<ReceiptLine> _header(String title, String disclaimer) => [
        const ReceiptLine('STORE US', kind: 'brand', size: 37, bold: true, align: 'center', direction: 'ltr'),
        const ReceiptLine('DELIVERY OPERATIONS', kind: 'eyebrow', size: 17, align: 'center', direction: 'ltr'),
        const ReceiptLine.divider(),
        ReceiptLine(title, kind: 'title', size: 30, bold: true, align: 'center'),
        ReceiptLine(disclaimer, kind: 'note', size: 18, align: 'center'),
        const ReceiptLine.spacer(),
      ];

  static void _appendPairIfPresent(List<ReceiptLine> lines, String label, String? value) {
    if (value != null && value.trim().isNotEmpty) {
      lines.add(ReceiptLine.pair(label, value.trim()));
    }
  }

  static String _printedAt() {
    final date = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)} '
        '${two(date.hour)}:${two(date.minute)}';
  }

  static String _qty(num? value) =>
      value == null ? '—' : value.toString().replaceFirst(RegExp(r'\.0$'), '');

  static String _money(num value) {
    final parts = value.toStringAsFixed(2).split('.');
    final negative = parts[0].startsWith('-');
    final digits = negative ? parts[0].substring(1) : parts[0];
    final buffer = StringBuffer();
    final reversed = digits.split('').reversed.toList();
    for (var index = 0; index < reversed.length; index++) {
      if (index > 0 && index % 3 == 0) buffer.write(',');
      buffer.write(reversed[index]);
    }
    final whole = buffer.toString().split('').reversed.join();
    return '${negative ? '-' : ''}$whole.${parts[1]}';
  }

  static String _orderStatus(String status) => switch (status.trim().toUpperCase()) {
        'DELIVERED' || 'COMPLETED' => 'تم التسليم',
        'PARTIAL' || 'PARTIALLY_DELIVERED' => 'تسليم جزئي',
        'PENDING' => 'قيد التسليم',
        'RESCHEDULED' => 'إعادة جدولة',
        'CANCELLED' || 'CANCELED' => 'ملغي',
        _ => status,
      };

  static String _status(TripOrderStatus status) => switch (status) {
        TripOrderStatus.delivered => 'تم التسليم',
        TripOrderStatus.partiallyDelivered => 'تسليم جزئي',
        TripOrderStatus.pending => 'قيد التسليم',
        TripOrderStatus.rescheduled => 'إعادة جدولة',
        TripOrderStatus.cancelled => 'ملغي',
        TripOrderStatus.unknown => 'غير معروف',
      };
}
