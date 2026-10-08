import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';

String formatTripAmount(BuildContext context, num amount) {
  final locale = Localizations.localeOf(context).languageCode;
  final number = NumberFormat.decimalPattern(locale).format(amount);
  return '$number ${context.strings.egp_currency}';
}
