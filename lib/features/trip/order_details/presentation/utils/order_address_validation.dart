import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';

/// Client-side validation for the delivery address update form.
///
/// Phone is required by UpdateDeliveryLocationBody. City, country, and notes
/// remain optional to match the existing API contract.
class OrderAddressValidation {
  const OrderAddressValidation._();

  static String _message(
    BuildContext context, {
    required String ar,
    required String en,
  }) {
    return Localizations.localeOf(context).languageCode == 'ar' ? ar : en;
  }

  static String? address(BuildContext context, String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return context.strings.order_address_required;
    if (text.length < 5) {
      return _message(
        context,
        ar: 'العنوان يجب أن يحتوي على 5 أحرف على الأقل.',
        en: 'Address must contain at least 5 characters.',
      );
    }
    if (text.length > 500) {
      return _message(
        context,
        ar: 'العنوان يجب ألا يتجاوز 500 حرف.',
        en: 'Address must not exceed 500 characters.',
      );
    }
    return null;
  }

  static String? phone(BuildContext context, String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return _message(
        context,
        ar: 'رقم هاتف العميل مطلوب.',
        en: 'Customer phone number is required.',
      );
    }

    // Accept local and international numbers, including +20 and 0020,
    // with optional spaces, parentheses, or hyphens.
    final normalized = text.replaceAll(RegExp(r'[\s()\-]'), '');
    final digits = normalized.startsWith('+')
        ? normalized.substring(1)
        : normalized;
    final valid = RegExp(r'^\+?[0-9]+$').hasMatch(normalized) &&
        digits.length >= 8 &&
        digits.length <= 15 &&
        !RegExp(r'^0+$').hasMatch(digits);

    if (!valid) {
      return _message(
        context,
        ar: 'أدخل رقم هاتف صحيح (من 8 إلى 15 رقمًا).',
        en: 'Enter a valid phone number (8–15 digits).',
      );
    }
    return null;
  }


  static String? city(BuildContext context, String? value) {
    final text = (value ?? '').trim();

    if (text.isEmpty) {
      return _message(
        context,
        ar: 'اسم المدينة مطلوب.',
        en: 'City name is required.',
      );
    }

    if (text.length < 2 || text.length > 100) {
      return _message(
        context,
        ar: 'اسم المدينة يجب أن يكون بين حرفين و100 حرف.',
        en: 'City must contain between 2 and 100 characters.',
      );
    }

    return null;
  }


  static String? country(BuildContext context, String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    if (text.length < 2 || text.length > 100) {
      return _message(
        context,
        ar: 'اسم الدولة يجب أن يكون بين حرفين و100 حرف.',
        en: 'Country must contain between 2 and 100 characters.',
      );
    }
    return null;
  }

  static String? notes(BuildContext context, String? value) {
    if ((value ?? '').trim().length > 500) {
      return _message(
        context,
        ar: 'الملاحظات يجب ألا تتجاوز 500 حرف.',
        en: 'Notes must not exceed 500 characters.',
      );
    }
    return null;
  }

  static bool hasValidCoordinates(double? latitude, double? longitude) {
    return latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }
}
