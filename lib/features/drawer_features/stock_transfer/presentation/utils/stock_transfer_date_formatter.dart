import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';

String formatStockTransferDate(
  BuildContext context,
  DateTime date,
  DateTime referenceDate,
) {
  final local = date.toLocal();
  final reference = referenceDate.toLocal();
  final daysAgo = DateTime.utc(
    reference.year,
    reference.month,
    reference.day,
  ).difference(DateTime.utc(local.year, local.month, local.day)).inDays;

  if (daysAgo == 2) return context.strings.stock_transfer_two_days_ago;

  final day = switch (daysAgo) {
    0 => context.strings.stock_transfer_today,
    1 => context.strings.yesterday,
    _ => DateFormat('dd/MM/yyyy', 'en').format(local),
  };
  final time = DateFormat('hh:mm', 'en').format(local);
  final period = local.hour < 12
      ? context.strings.stock_transfer_am
      : context.strings.stock_transfer_pm;
  return '$day $time $period';
}
