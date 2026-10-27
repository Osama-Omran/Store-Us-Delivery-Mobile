# Localization audit — Store Us Delivery

Completed against the working tree captured at the start of implementation. Arabic remains the only supported locale. All original catalog entries and metadata are preserved.

| Measure | Result |
| --- | --- |
| Application Dart files scanned | 357 (351 maintained; 6 generated) |
| Original string expressions inventoried | 1932 |
| Final UI text/message expressions traced | 843 |
| Audit files modified or added | 91 |
| Existing translation keys reused | 48 |
| New translation keys added by this audit | 109 |
| Hardcoded user-facing expressions replaced | 98 |
| Additional composed localized expressions migrated to ARB | 41 |
| Total localized/reworked string expressions | 139 |

Counts use Dart syntax-tree string expressions, including nested interpolation fragments and local error fallbacks. Seven predefined rescheduling reasons count as localized UI sites even though their original Arabic values remain as API compatibility constants. Reused keys are distinct original keys with new references in affected production files; metadata entries are not counted as translation keys.

The pre-existing collection changes and concurrent Direct Sale changes were retained. Two concurrent Direct Sale translation keys (`direct_sale_customer_retry_same_data`, `direct_sale_customer_retry_same_request_notice`) and four concurrently edited Direct Sale implementation files are excluded from this audit’s modification/key counts.

## Changes

- Widgets continue to use `context.strings`; no localization framework or dependency was added.
- Added typed dynamic messages and Arabic ICU plurals; kept existing amount formatting, bidi isolation, RTL layouts, styles, and widget structure.
- Local error identifiers flow through existing state fields and `ApiResult`; the existing context extension resolves them at presentation boundaries. Genuine backend prose remains unchanged.
- Background notifications load the same generated catalog with the saved supported locale and Arabic fallback, without using navigator context. Notification/channel IDs and replay storage are unchanged.
- Localized payment, delivery, trip acceptance, settlement/payment-method, account-role, stock-transfer, and ranking-label presentation. Unknown codes use Arabic fallbacks.

## Verification

- Baseline: `flutter analyze --no-pub` passed before implementation.
- `flutter gen-l10n`: passed using the existing `l10n.yaml`; generated localization files were never edited manually.
- `dart format lib`: completed. Formatting-only changes in unrelated files were restored to their pre-format contents; affected Dart files and both new tests are formatted.
- `flutter analyze`: passed after cleanup, with no issues (exit code 0).
- `flutter test --no-pub`: passed, all 57 tests (exit code 0), including 22 new localization/flow regression tests.
- Final syntax-tree scan and targeted searches found no remaining application-owned hardcoded UI prose outside the exclusions below.

Tests cover Arabic plural categories, placeholders and ARB integrity, locale fallback without a widget context, structured network errors, backend-message preservation, unknown-status fallbacks, ranking keys, loaded-goods errors, exact full collection amounts/original operation IDs, unchanged collection eligibility, uncertain-result refresh behavior, and canonical/custom rescheduling reason payloads.

Native OS notification rendering and device UI interactions were not exercised on an emulator or physical device. No production API calls were made.

## Justified exclusions

| Remaining literal/data category | Reason |
| --- | --- |
| Seven `_reasonValues` in the rescheduling sheet | Existing API reason values are preserved exactly. Choice labels use ARB translations; selection and custom-reason handling use indexes. |
| `Egypt` as the initial editable country value | Existing country payload value is preserved. The field hint is localized to مصر. |
| Customer/product/person/warehouse names, addresses, codes, vehicle plates and units in the two `data/sample/` files | Sample entity data, not interface copy; backend/user data is treated the same way. |
| Backend notification content, support data, ranking metric labels/units, winner descriptions, warnings and advice | Server-authored data is preserved. A missing metric label no longer exposes its machine key. |
| Numeric/symbol-only text such as `0`, `—`, `?`, `99+`, `±`, separators and progress percentages | Language-neutral values, numeric formatting or decorative notation. |
| Digit normalization tables, regexes, date patterns and locale identifiers | Technical formatting/input behavior. |
| Routes, URLs, endpoints, JSON/storage/database keys, status comparisons, SDK/channel IDs, assets, package names and constants such as `cash`, `Individual`, `Retail` | Technical contracts; display values are localized separately. |
| Logging-only messages and exceptions consumed by generic localized error handling; offline outbox diagnostic errors | Developer diagnostics, not displayed interface text. |
| InstaPay | Trademark retained through existing ARB entries, with no remaining hardcoded payment label. |

No deliberately untranslated application-owned prose remains in the Flutter UI. Genuine backend/user content may remain in its supplied language.

## Backend vocabulary requiring documentation

No live backend status sampling was performed. The implementation maps values evidenced in the repository and safely hides unknown codes. An authoritative API vocabulary is still needed for future payment/collection aliases, trip and delivery statuses, acceptance and warehouse-transfer states, account roles, payment methods, and ranking metric keys/labels/units. Display fallbacks do not authorize operations: eligibility continues to follow existing policy, backend retry flags, original operation IDs, and validation.

Payment presentation includes paid/collected/full aliases, partial aliases, pending/unpaid aliases, failed aliases, and NOT_STARTED. Delivery presentation includes the existing full/partial aliases, pending, rescheduled, cancelled/canceled, and unknown. Existing business policy normalization and eligibility were not changed.

## Preserved behavior

The audit does not change API endpoints, JSON fields/request shapes, Retrofit services, GetIt registrations, authentication/logout, routing/redirects, offline queue scheduling/replay/idempotency, delivery operations, `canRetryCollection`, collection policy, amount validation, or the full-amount-only collection requirement. Existing authentication, offline-session and treasury repository tests pass alongside the new localization/flow tests.

## Existing keys reused

`account_delivery_representative`, `account_load_failed`, `account_logout_failed`, `an_error_occurred_try_again_later`, `cancel_delivery_failed`, `cancel_reason_other`, `cancel_reason_shop_closed`, `contact_load_error`, `contact_send_error`, `delivery_confirm_failed`, `delivery_invalid_amount`, `delivery_invalid_items`, `delivery_not_collected`, `delivery_payment_not_supported`, `direct_sale_customer_create_failed`, `direct_sale_customer_invalid_fields`, `direct_sale_customer_missing_id`, `direct_sale_customer_verify_before_retry`, `driver`, `home_history_completed`, `no_internet_please_try_again`, `notifications_mark_read_failed`, `order_collection_not_started`, `order_latitude`, `order_location_save_failed`, `order_longitude`, `reports_status_cancelled`, `reschedule_order_failed`, `stock_transfer_receipt_discrepancy`, `store_us_delivery`, `top_rank`, `top_rank_approved_score`, `top_rank_data_incomplete`, `top_rank_data_insufficient`, `top_rank_details_refresh_failed`, `top_rank_improvement_opportunity`, `top_rank_provisional`, `top_rank_unavailable`, `top_rank_warehouse_staff`, `treasury_insta_pay`, `trip_accept_failed`, `trip_acceptance_admin_override`, `trip_acceptance_pending`, `trip_customers_load_failed`, `trip_customers_orders_load_failed`, `trip_customers_unknown_status`, `trip_tab_accepted`, `trip_tab_unknown_status`.

## Modified and added files

- [LOCALIZATION_AUDIT.md](LOCALIZATION_AUDIT.md)
- [lib/app/app_builder.dart](lib/app/app_builder.dart)
- [lib/core/helpers/apis/api_error_handler.dart](lib/core/helpers/apis/api_error_handler.dart)
- [lib/core/helpers/apis/api_error_model.dart](lib/core/helpers/apis/api_error_model.dart)
- [lib/core/helpers/functions/extensions.dart](lib/core/helpers/functions/extensions.dart)
- [lib/core/helpers/localization/gen_l10n/app_localizations.dart](lib/core/helpers/localization/gen_l10n/app_localizations.dart)
- [lib/core/helpers/localization/gen_l10n/app_localizations_ar.dart](lib/core/helpers/localization/gen_l10n/app_localizations_ar.dart)
- [lib/core/helpers/localization/intl_ar.arb](lib/core/helpers/localization/intl_ar.arb)
- [lib/core/helpers/offline_cache/offline_cache_banner.dart](lib/core/helpers/offline_cache/offline_cache_banner.dart)
- [lib/core/helpers/offline_sync/offline_sync_interceptor.dart](lib/core/helpers/offline_sync/offline_sync_interceptor.dart)
- [lib/core/helpers/offline_sync/offline_sync_notifications.dart](lib/core/helpers/offline_sync/offline_sync_notifications.dart)
- [lib/features/drawer_features/account/presentation/screens/account_screen.dart](lib/features/drawer_features/account/presentation/screens/account_screen.dart)
- [lib/features/drawer_features/account/presentation/widgets/account_dashboard_sections.dart](lib/features/drawer_features/account/presentation/widgets/account_dashboard_sections.dart)
- [lib/features/drawer_features/account/presentation/widgets/account_header_card.dart](lib/features/drawer_features/account/presentation/widgets/account_header_card.dart)
- [lib/features/drawer_features/contact_us/presentation/widgets/contact_message_sheet.dart](lib/features/drawer_features/contact_us/presentation/widgets/contact_message_sheet.dart)
- [lib/features/drawer_features/customers/presentation/cubit/trip_customers_cubit.dart](lib/features/drawer_features/customers/presentation/cubit/trip_customers_cubit.dart)
- [lib/features/drawer_features/customers/presentation/screens/trip_customer_orders_screen.dart](lib/features/drawer_features/customers/presentation/screens/trip_customer_orders_screen.dart)
- [lib/features/drawer_features/customers/presentation/screens/trip_customers_screen.dart](lib/features/drawer_features/customers/presentation/screens/trip_customers_screen.dart)
- [lib/features/drawer_features/customers/presentation/widgets/trip_customer_card.dart](lib/features/drawer_features/customers/presentation/widgets/trip_customer_card.dart)
- [lib/features/drawer_features/direct_sale/presentation/screens/direct_sale_products_screen.dart](lib/features/drawer_features/direct_sale/presentation/screens/direct_sale_products_screen.dart)
- [lib/features/drawer_features/direct_sale/presentation/widgets/direct_sale_customer_form.dart](lib/features/drawer_features/direct_sale/presentation/widgets/direct_sale_customer_form.dart)
- [lib/features/drawer_features/direct_sale/presentation/widgets/direct_sale_location_card.dart](lib/features/drawer_features/direct_sale/presentation/widgets/direct_sale_location_card.dart)
- [lib/features/drawer_features/direct_sale/presentation/widgets/direct_sale_notice.dart](lib/features/drawer_features/direct_sale/presentation/widgets/direct_sale_notice.dart)
- [lib/features/drawer_features/reports/presentation/cubit/reports_cubit.dart](lib/features/drawer_features/reports/presentation/cubit/reports_cubit.dart)
- [lib/features/drawer_features/reports/presentation/screens/reports_screen.dart](lib/features/drawer_features/reports/presentation/screens/reports_screen.dart)
- [lib/features/drawer_features/reports/presentation/widgets/reports_distribution_card.dart](lib/features/drawer_features/reports/presentation/widgets/reports_distribution_card.dart)
- [lib/features/drawer_features/stock_transfer/presentation/screens/stock_transfer_screen.dart](lib/features/drawer_features/stock_transfer/presentation/screens/stock_transfer_screen.dart)
- [lib/features/drawer_features/stock_transfer/presentation/widgets/stock_transfer_card.dart](lib/features/drawer_features/stock_transfer/presentation/widgets/stock_transfer_card.dart)
- [lib/features/drawer_features/stock_transfer/presentation/widgets/stock_transfer_filters.dart](lib/features/drawer_features/stock_transfer/presentation/widgets/stock_transfer_filters.dart)
- [lib/features/drawer_features/stock_transfer/presentation/widgets/stock_transfer_status_badge.dart](lib/features/drawer_features/stock_transfer/presentation/widgets/stock_transfer_status_badge.dart)
- [lib/features/drawer_features/top_rank/data/repo/concrete_top_rank_repo.dart](lib/features/drawer_features/top_rank/data/repo/concrete_top_rank_repo.dart)
- [lib/features/drawer_features/top_rank/presentation/cubit/top_rank_cubit.dart](lib/features/drawer_features/top_rank/presentation/cubit/top_rank_cubit.dart)
- [lib/features/drawer_features/top_rank/presentation/cubit/top_rank_details_cubit.dart](lib/features/drawer_features/top_rank/presentation/cubit/top_rank_details_cubit.dart)
- [lib/features/drawer_features/top_rank/presentation/screens/top_rank_screen.dart](lib/features/drawer_features/top_rank/presentation/screens/top_rank_screen.dart)
- [lib/features/drawer_features/top_rank/presentation/widgets/top_rank_details_sheet.dart](lib/features/drawer_features/top_rank/presentation/widgets/top_rank_details_sheet.dart)
- [lib/features/drawer_features/top_rank/presentation/widgets/top_rank_filters.dart](lib/features/drawer_features/top_rank/presentation/widgets/top_rank_filters.dart)
- [lib/features/drawer_features/top_rank/presentation/widgets/top_rank_header.dart](lib/features/drawer_features/top_rank/presentation/widgets/top_rank_header.dart)
- [lib/features/drawer_features/top_rank/presentation/widgets/top_rank_list.dart](lib/features/drawer_features/top_rank/presentation/widgets/top_rank_list.dart)
- [lib/features/drawer_features/top_rank/presentation/widgets/top_rank_metrics.dart](lib/features/drawer_features/top_rank/presentation/widgets/top_rank_metrics.dart)
- [lib/features/drawer_features/treasury/presentation/widgets/treasury_inventory_widgets.dart](lib/features/drawer_features/treasury/presentation/widgets/treasury_inventory_widgets.dart)
- [lib/features/drawer_features/treasury/presentation/widgets/treasury_wallet_cards.dart](lib/features/drawer_features/treasury/presentation/widgets/treasury_wallet_cards.dart)
- [lib/features/drawer_features/treasury/presentation/widgets/treasury_wallet_live.dart](lib/features/drawer_features/treasury/presentation/widgets/treasury_wallet_live.dart)
- [lib/features/home/presentation/screens/home_screen.dart](lib/features/home/presentation/screens/home_screen.dart)
- [lib/features/home/presentation/widgets/home_current_trip_card.dart](lib/features/home/presentation/widgets/home_current_trip_card.dart)
- [lib/features/home/presentation/widgets/home_message.dart](lib/features/home/presentation/widgets/home_message.dart)
- [lib/features/home/presentation/widgets/home_previous_trips_section.dart](lib/features/home/presentation/widgets/home_previous_trips_section.dart)
- [lib/features/layout/presentation/screens/layout_screen.dart](lib/features/layout/presentation/screens/layout_screen.dart)
- [lib/features/layout/presentation/widgets/app_menu_drawer.dart](lib/features/layout/presentation/widgets/app_menu_drawer.dart)
- [lib/features/login/presentation/widgets/login_failure_widget.dart](lib/features/login/presentation/widgets/login_failure_widget.dart)
- [lib/features/notifications/presentation/screens/notifications_screen.dart](lib/features/notifications/presentation/screens/notifications_screen.dart)
- [lib/features/notifications/presentation/widgets/notification_card.dart](lib/features/notifications/presentation/widgets/notification_card.dart)
- [lib/features/notifications/presentation/widgets/notifications_header.dart](lib/features/notifications/presentation/widgets/notifications_header.dart)
- [lib/features/trip/cancel_delivery/presentation/widgets/cancel_delivery_confirmation_sheet.dart](lib/features/trip/cancel_delivery/presentation/widgets/cancel_delivery_confirmation_sheet.dart)
- [lib/features/trip/cancel_delivery/presentation/widgets/cancel_delivery_sheet.dart](lib/features/trip/cancel_delivery/presentation/widgets/cancel_delivery_sheet.dart)
- [lib/features/trip/current_trip/presentation/screens/current_trip_screen.dart](lib/features/trip/current_trip/presentation/screens/current_trip_screen.dart)
- [lib/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart](lib/features/trip/current_trip/presentation/utils/trip_amount_formatter.dart)
- [lib/features/trip/current_trip/presentation/widgets/current_trip_header.dart](lib/features/trip/current_trip/presentation/widgets/current_trip_header.dart)
- [lib/features/trip/current_trip/presentation/widgets/current_trip_summary_card.dart](lib/features/trip/current_trip/presentation/widgets/current_trip_summary_card.dart)
- [lib/features/trip/current_trip/presentation/widgets/trip_order_card.dart](lib/features/trip/current_trip/presentation/widgets/trip_order_card.dart)
- [lib/features/trip/current_trip/presentation/widgets/trip_order_status.dart](lib/features/trip/current_trip/presentation/widgets/trip_order_status.dart)
- [lib/features/trip/deliver_order/presentation/screens/deliver_order_screen.dart](lib/features/trip/deliver_order/presentation/screens/deliver_order_screen.dart)
- [lib/features/trip/deliver_order/presentation/screens/delivery_payment_screen.dart](lib/features/trip/deliver_order/presentation/screens/delivery_payment_screen.dart)
- [lib/features/trip/deliver_order/presentation/screens/delivery_result_screen.dart](lib/features/trip/deliver_order/presentation/screens/delivery_result_screen.dart)
- [lib/features/trip/deliver_order/presentation/screens/delivery_success_screen.dart](lib/features/trip/deliver_order/presentation/screens/delivery_success_screen.dart)
- [lib/features/trip/deliver_order/presentation/widgets/delivery_order_item_card.dart](lib/features/trip/deliver_order/presentation/widgets/delivery_order_item_card.dart)
- [lib/features/trip/deliver_order/presentation/widgets/delivery_payment_content.dart](lib/features/trip/deliver_order/presentation/widgets/delivery_payment_content.dart)
- [lib/features/trip/order_details/data/repo/concrete_order_details_repo.dart](lib/features/trip/order_details/data/repo/concrete_order_details_repo.dart)
- [lib/features/trip/order_details/presentation/cubit/order_details_cubit.dart](lib/features/trip/order_details/presentation/cubit/order_details_cubit.dart)
- [lib/features/trip/order_details/presentation/screens/order_details_screen.dart](lib/features/trip/order_details/presentation/screens/order_details_screen.dart)
- [lib/features/trip/order_details/presentation/widgets/order_address_edit_sheet.dart](lib/features/trip/order_details/presentation/widgets/order_address_edit_sheet.dart)
- [lib/features/trip/order_details/presentation/widgets/order_address_fields.dart](lib/features/trip/order_details/presentation/widgets/order_address_fields.dart)
- [lib/features/trip/order_details/presentation/widgets/order_address_location_section.dart](lib/features/trip/order_details/presentation/widgets/order_address_location_section.dart)
- [lib/features/trip/order_details/presentation/widgets/order_address_review.dart](lib/features/trip/order_details/presentation/widgets/order_address_review.dart)
- [lib/features/trip/order_details/presentation/widgets/order_collection_status_card.dart](lib/features/trip/order_details/presentation/widgets/order_collection_status_card.dart)
- [lib/features/trip/order_details/presentation/widgets/order_customer_card.dart](lib/features/trip/order_details/presentation/widgets/order_customer_card.dart)
- [lib/features/trip/order_details/presentation/widgets/order_delivery_status_card.dart](lib/features/trip/order_details/presentation/widgets/order_delivery_status_card.dart)
- [lib/features/trip/order_details/presentation/widgets/order_retry_collection_sheet.dart](lib/features/trip/order_details/presentation/widgets/order_retry_collection_sheet.dart)
- [lib/features/trip/receive_trip/presentation/screens/receive_trip_screen.dart](lib/features/trip/receive_trip/presentation/screens/receive_trip_screen.dart)
- [lib/features/trip/receive_trip/presentation/widgets/loaded_items_section.dart](lib/features/trip/receive_trip/presentation/widgets/loaded_items_section.dart)
- [lib/features/trip/receive_trip/presentation/widgets/trip_data.dart](lib/features/trip/receive_trip/presentation/widgets/trip_data.dart)
- [lib/features/trip/receive_trip/presentation/widgets/trip_receiving_confirmation_sheet.dart](lib/features/trip/receive_trip/presentation/widgets/trip_receiving_confirmation_sheet.dart)
- [lib/features/trip/receive_trip/presentation/widgets/van_products.dart](lib/features/trip/receive_trip/presentation/widgets/van_products.dart)
- [lib/features/trip/reschedule_order/presentation/widgets/reschedule_order_form.dart](lib/features/trip/reschedule_order/presentation/widgets/reschedule_order_form.dart)
- [lib/features/trip/reschedule_order/presentation/widgets/reschedule_order_sheet.dart](lib/features/trip/reschedule_order/presentation/widgets/reschedule_order_sheet.dart)
- [lib/features/trip/trip_map/presentation/widgets/trip_map_stop_sheet.dart](lib/features/trip/trip_map/presentation/widgets/trip_map_stop_sheet.dart)
- [lib/features/trip/trip_map/presentation/widgets/trip_map_toolbar.dart](lib/features/trip/trip_map/presentation/widgets/trip_map_toolbar.dart)
- [lib/features/trip/trip_tap/presentation/screen/trip_screen.dart](lib/features/trip/trip_tap/presentation/screen/trip_screen.dart)
- [lib/features/trip/trip_tap/presentation/widgets/empty_trips.dart](lib/features/trip/trip_tap/presentation/widgets/empty_trips.dart)
- [lib/features/trip/trip_tap/presentation/widgets/trip_status_placeholder.dart](lib/features/trip/trip_tap/presentation/widgets/trip_status_placeholder.dart)
- [test/core/helpers/localization/localization_test.dart](test/core/helpers/localization/localization_test.dart)
- [test/features/trip/localized_delivery_flows_test.dart](test/features/trip/localized_delivery_flows_test.dart)
