# Store Us Delivery cleanup report

## Baseline (2026-10-12)

- Flutter 3.47.6; Dart 3.13.5. Package namespace: `storeus_delivery`.
- Analyzer: `flutter analyze --no-pub` passed with no issues.
- Tests: `flutter test --no-pub` completed with 49 passing and one failing. The existing partial-delivery result test expected an item name that the current screen does not render. Its expectation is being replaced with checks for the existing quantities, financial totals, and partial-reason controls; production behavior stays unchanged.
- 254 handwritten Dart files and six generated Dart files. Formatter dry run identified 17 files needing formatting.
- Arabic localization: 530 distinct message keys, 532 declarations, 83 preliminary unreferenced candidates. Two duplicate keys have different values; the later values match the existing generated output.
- 15 Flutter assets (five SVG icons, one Lottie animation, nine Cairo fonts); zero byte-identical duplicate groups. 35 native image resources are protected.
- 34 runtime and six development dependencies. `integration_test/` is absent.
- An Android 16 emulator is available. iOS builds cannot be performed on this Windows host.
- `location.zip` and `vendor_profile.zip` were not found in the project, the inspected StudioProjects parent directory, or the Android Studio agents workspace. No claim of inspecting those references is made.
- Initial Git state contained only the deletion of `android/.kotlin/sessions/kotlin-compiler-788478504620134840.salive`. This unrelated change is preserved.
- Two initial audit command launches temporarily failed automatic approval review due to HTTP 429. Subsequent reviewed commands succeeded.

## Removal policy and audit ledger

SAFE requires evidence across source/import graphs, generated consumers, registrations, native configuration, build tooling, tests, and possible dynamic usage. REVIEW items stay in place. Protected configuration, fonts, branding, app icons, splash resources, unfinished requirements, and actively used sample-backed features stay unchanged.

| Item | Classification | Evidence / action |
| --- | --- | --- |
| `image`, `typed_data` direct dependencies | Candidate | No source imports; verify native/tooling consumers and dependency resolution before removal. |
| Cupertino icons | PROTECTED | `van_products.dart` uses `CupertinoIcons.search`; font packaging is a consumer without a package import. |
| ML Kit face detection | PROTECTED | `FaceValidator` and release-mode receiving photo validation consume it. |
| Firebase remote config | PROTECTED | Startup and force-update services consume it. |
| Retrofit, Freezed, JSON generation tooling | PROTECTED | Existing generation infrastructure; absence of ordinary runtime imports is not removal evidence. |
| `rank_crown.svg` / `AppAssets.rankCrown` | REVIEW | No current widget consumer; retained because branding/intentional retention is uncertain. |
| Commented `phone_text_field.dart` | REVIEW | Disabled phone form reference in `login_form.dart`; retain its translations. |
| Current-trip and map samples | REVIEW | Disconnected from app roots but contain demonstration/unfinished-implementation context; retain. |
| Notification mock model and builder | Candidate | Disconnected import subgraph; verify supported consumers before removal. |
| `delivery_review_sheet.dart` | REVIEW | Disconnected draft-preview UI; intentionally retain because unfinished usage cannot be ruled out. |
| Treasury, reports, stock-transfer sample data | PROTECTED | Actively consumed by feature Cubits and tests. |

## Implementation and verification

In progress. Final counts, exact removals, widget extractions, command outcomes, visual comparisons, and remaining manual QA will be recorded here after validation. No functional or visual equivalence is claimed before verification.

## Localization removal evidence

Removed 51 distinct keys after parsing all handwritten Dart files (identifiers and string-literal message codes), checking routes/registrations and native/build/configuration consumers, and inspecting the current history/Top Rank/notification implementations. There is no dynamic string-to-localization lookup. Generated getters are not consumers.

- Legacy `trip_history_*` display keys: the current Home history section uses `home_history_*`, `previous_today_trips`, and existing shared labels. No separate history route or registered screen consumes the older keys.
- Legacy Top Rank display keys: the current role/period selectors, winner/list, and detail/metric presentation use the newer keys or server-provided labels. No identifiers or literal error codes consume the removed entries. Unimplemented period/warehouse variants and uncertain error/special-state messages remain REVIEW.
- Notification mock-only messages: the removed mock builder and its model form an unreachable subgraph. The actual notification screen uses API notification titles/descriptions; no route, registration, native hook, or test uses these fixtures.
- Removed the earlier shadowed declarations of `confirm_receiving_warning` and `trip_tab_orders_not_loaded`; retained the later values that match the baseline generated Arabic getters. This removes two duplicate declarations without changing message values or consolidating distinct business keys.
- Remaining Arabic values and metadata were compared structurally against the baseline and are unchanged. Removed unused `top_rank_moved_up/down` placeholder metadata together with their messages.

Exact removed keys:

- `trip_history_title`
- `trip_history_completed`
- `trip_history_cancelled`
- `trip_history_date`
- `trip_history_orders_total`
- `trip_history_acceptance`
- `trip_history_acceptance_pending`
- `trip_history_completed_at`
- `trip_history_not_available`
- `trip_history_retry`
- `trip_history_empty`
- `top_rank_best_representatives`
- `top_rank_best_drivers`
- `top_rank_best_dispatchers`
- `top_rank_best_representative`
- `top_rank_best_driver`
- `top_rank_best_dispatcher`
- `top_rank_winner`
- `top_rank_delivery`
- `top_rank_collection`
- `top_rank_extra_sales`
- `top_rank_score`
- `top_rank_position`
- `top_rank_movement`
- `top_rank_unchanged`
- `top_rank_moved_up`
- `top_rank_moved_down`
- `top_rank_current_rank`
- `top_rank_score_label`
- `top_rank_breakdown_title`
- `top_rank_total_score`
- `top_rank_strengths_title`
- `top_rank_improvement_title`
- `top_rank_compare_leader`
- `top_rank_your_score`
- `top_rank_leader_score`
- `top_rank_gap`
- `top_rank_unchanged_label`
- `notification_new_trip_title`
- `notification_new_trip_description`
- `notification_route_updated_title`
- `notification_route_updated_description`
- `notification_order_updated_title`
- `notification_order_updated_description`
- `notification_payment_received_title`
- `notification_payment_received_description`
- `notification_trip_completed_title`
- `notification_trip_completed_description`
- `two_hours_ago`
- `one_hour_ago`
- `forty_five_minutes_ago`

Unreferenced keys deliberately retained for disabled/incomplete/uncertain functionality:

- `phone_number_is_required`
- `invalid_phone_number`
- `loading_time`
- `started_at`
- `driver_selfie_title`
- `selfie_capture_action`
- `selfie_capture_hint`
- `selfie_checking_photo`
- `selfie_no_face_error`
- `selfie_many_faces_error`
- `selfie_too_small_error`
- `selfie_not_centered_error`
- `selfie_not_frontal_error`
- `selfie_eyes_not_visible_error`
- `selfie_too_dark_error`
- `selfie_too_bright_error`
- `selfie_blurry_error`
- `selfie_invalid_image_error`
- `selfie_check_failed_error`
- `trip_map_wait_orders`
- `order_details_read_only`
- `order_details_items_title`
- `order_details_quantities_hint`
- `order_details_vehicle_available`
- `order_details_collected`
- `order_details_remaining`
- `order_details_payment_method`
- `order_details_financial_unavailable`
- `order_details_notes`
- `order_details_notes_unavailable`
- `order_address_not_saved_yet`
- `order_address_save_api_missing`
- `order_operation_not_connected`
- `order_notes_not_saved`
- `top_rank_today`
- `top_rank_week`
- `top_rank_previous_month`
- `top_rank_warehouse_october`
- `top_rank_warehouse_nasr_city`
- `top_rank_unqualified`
- `delivery_back_to_details`
- `top_rank_unavailable`
- `top_rank_approved_score`
- `top_rank_data_incomplete`
- `top_rank_details_refresh_failed`
- `top_rank_data_insufficient`
- `top_rank_improvement_opportunity`
