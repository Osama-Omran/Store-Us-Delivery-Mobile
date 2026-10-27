import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:storeus_delivery/core/routing/app_router.dart';

extension MediaQueryValues on BuildContext {
  double get height => MediaQuery.of(this).size.height;
  double get width => MediaQuery.of(this).size.width;
  double get topPadding => MediaQuery.of(this).viewPadding.top;
  double get bottom => MediaQuery.of(this).viewInsets.bottom;
  AppLocalizations get strings => AppLocalizations.of(this)!;

  /// Local codes are resolved here; backend-authored prose is preserved.
  String localizedErrorMessage(String? message, {String? fallback}) {
    final value = message?.trim() ?? '';
    return switch (value) {
      '' => fallback ?? strings.an_error_occurred_try_again_later,
      'Unknown error' ||
      'api_unknown_error' ||
      'unknownError' ||
      'defaultError' ||
      'internalServerError' ||
      'api_server_error' => strings.an_error_occurred_try_again_later,
      'badRequestError' => strings.api_bad_request,
      'noContent' => strings.api_no_content,
      'forbiddenError' => strings.api_forbidden,
      'unauthorizedError' => strings.api_unauthorized,
      'notFoundError' => strings.api_not_found,
      'cacheError' => strings.api_cache_error,
      'api_no_internet' => strings.no_internet_please_try_again,
      'order_collection_in_progress' => strings.order_collection_in_progress,
      'order_collection_invalid_details' =>
        strings.order_collection_invalid_details,
      'order_collection_not_available' =>
        strings.order_collection_not_available,
      'order_collection_not_confirmed' =>
        strings.order_collection_not_confirmed,
      'order_collection_refresh_first' =>
        strings.order_collection_refresh_first,
      'order_collection_refresh_before_retry' =>
        strings.order_collection_refresh_before_retry,
      'order_collection_connection_uncertain' =>
        strings.order_collection_connection_uncertain,
      'top_rank_category_empty' => strings.top_rank_category_empty,
      'top_rank_load_failed' => strings.top_rank_load_failed,
      'top_rank_details_load_failed' => strings.top_rank_details_load_failed,
      'reports_load_failed' => strings.reports_load_failed,
      'offline_operation_queued' => strings.offline_operation_queued,
      'offline_operation_save_failed' => strings.offline_operation_save_failed,
      'account_load_failed' => strings.account_load_failed,
      'account_logout_failed' => strings.account_logout_failed,
      'contact_load_error' => strings.contact_load_error,
      'contact_send_error' => strings.contact_send_error,
      'cancel_delivery_failed' => strings.cancel_delivery_failed,
      'delivery_invalid_items' => strings.delivery_invalid_items,
      'delivery_invalid_amount' => strings.delivery_invalid_amount,
      'delivery_payment_not_supported' =>
        strings.delivery_payment_not_supported,
      'delivery_confirm_failed' => strings.delivery_confirm_failed,
      'order_location_save_failed' => strings.order_location_save_failed,
      'reschedule_order_failed' => strings.reschedule_order_failed,
      'notifications_mark_read_failed' =>
        strings.notifications_mark_read_failed,
      'direct_sale_customer_invalid_fields' =>
        strings.direct_sale_customer_invalid_fields,
      'direct_sale_customer_create_failed' =>
        strings.direct_sale_customer_create_failed,
      'direct_sale_customer_missing_id' =>
        strings.direct_sale_customer_missing_id,
      'direct_sale_customer_verify_before_retry' =>
        strings.direct_sale_customer_verify_before_retry,
      'trip_accept_failed' => strings.trip_accept_failed,
      'trip_customers_load_failed' => strings.trip_customers_load_failed,
      'trip_customers_orders_load_failed' =>
        strings.trip_customers_orders_load_failed,
      _ => message!,
    };
  }

  String localizedTripAcceptanceStatus(String? status) =>
      switch (status?.trim().toUpperCase()) {
        'PENDING' => strings.trip_acceptance_pending,
        'ACCEPTED' => strings.trip_tab_accepted,
        'OVERRIDDEN' => strings.trip_acceptance_admin_override,
        _ => strings.trip_tab_unknown_status,
      };

  String localizedUserRole(String? role) =>
      switch (role?.trim().toLowerCase()) {
        'delivery representative' => strings.account_delivery_representative,
        'driver' => strings.driver,
        'dispatcher' => strings.top_rank_dispatchers_label,
        'warehouse staff' => strings.top_rank_warehouse_staff,
        _ => strings.account_role_unknown,
      };

  String get language => Localizations.localeOf(this).languageCode;
  bool get isArabic => language == 'ar';
  void go(String location) => GoRouter.of(this).go(location);
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;
}

extension StringExtension on String? {
  bool isNullOrEmpty() => this == null || this == "";
}

extension NumberTranslation on String {
  /*String numTr() {
    final isArabic = navigatorKey.currentContext!.isArabic;

    String value = this;

    // 🔹 حذف .000
    if (value.contains('.')) {
      value = value.replaceAll(RegExp(r'\.0+$'), '');
    }

    if (!isArabic) {
      return value;
    }

    // 🔥 استبدال . بين أرقام بـ ,
    value = value.replaceAllMapped(RegExp(r'(?<=\d)\.(?=\d)'), (match) => ',');

    final arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    value = value.replaceAll('%', '٪');

    return value
        .replaceAllMapped(
          RegExp(r'\d'),
          (match) => arabicNumbers[int.parse(match[0]!)],
        )
        .replaceAll(',', '،'); // الفاصلة العربية
  }*/
  String handlePlusSymbol() {
    final isArabic = navigatorKey.currentContext!.isArabic;
    String value = this;
    if (value.startsWith('+') && isArabic) {
      value = value.replaceAll('+', '');
      value = '$value+';
    }
    return value;
  }

  String handleEgyptianNumber() {
    final String phone = trim();

    if (phone.startsWith("+201")) {
      return phone.substring(3); // remove +20
    } else if (phone.startsWith("201")) {
      return phone.substring(2); // remove 20
    } else if (phone.startsWith("0201")) {
      return phone.substring(3); // remove 020
    } else if (phone.startsWith("01")) {
      return phone.substring(1); // remove 0
    }

    return phone; // unchanged
  }
}

extension ListExtension<T> on List<T>? {
  bool isNullOrEmpty() => this == null || this!.isEmpty;
}

extension SplitDoubleExtension on double {
  List<String> splitDouble({int maxDecimalLength = 2}) {
    final parts = toString().split('.');

    final integerPart = parts[0];

    String decimalPart = parts.length > 1 ? parts[1] : '0';

    if (decimalPart.length > maxDecimalLength) {
      decimalPart = decimalPart.substring(0, maxDecimalLength);
    }

    return [integerPart, decimalPart];
  }
}
