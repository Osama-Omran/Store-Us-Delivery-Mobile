# Direct-sale UI implementation

## Screens completed

The `بيع مباشر` drawer entry pushes `/directSaleScreen` using the existing GoRouter transition and a GetIt-created `DirectSaleCubit`. The previous layout remains underneath the route, preserving its selected tab and bottom navigation.

Implemented customer selection, new-customer entry, products, checkout, and receipt-based success views. These follow the eight screenshots supplied in the conversation. Customer selection and form/location interactions are available in the application. Populated inventory, checkout, saved-customer, and success states are exercised with isolated test fixtures; production does not simulate backend operations.

## Screen comparison and outcome

| Reference | Flutter counterpart | Initial status | Missing components | Visual differences addressed | Existing functionality / API | Implemented work |
| --- | --- | --- | --- | --- | --- | --- |
| Customer choice, unselected and selected | `DirectSaleCustomerSelectionScreen` | MISSING | Choices, badges, guidance, summary, continuation | White rounded cards, orange/blue accents, selection outline, fixed footer | Existing drawer callback was empty; selection requires no API | Cash selection, new-customer navigation, selection-dependent continuation |
| New customer, empty / invalid phone / captured location | `DirectSaleNewCustomerScreen` | BACKEND PENDING | Form and location display | RTL labels, required markers, validation, rounded fields, coordinates, disabled save and cancel | Existing Geolocator dependency; no customer-creation contract | Name/phone validation, optional fields, actual location/accuracy, draft preservation; saving disabled |
| Products and empty basket | `DirectSaleProductsScreen` | BACKEND PENDING | Customer summary, stock/prices, counters, basket | Product cards, green stock text, plus/minus controls, fixed basket footer | No verified current sellable inventory or pricing contract | Inventory-driven view and unavailable/empty states; quantity limits and exact-price totals checked using test fixtures |
| Checkout, empty / mismatch / matching amount | `DirectSalePaymentScreen` | BACKEND PENDING | Line summary, counted amount, payment choices, confirmation | Summary divider, prominent amount field, red/green feedback, disabled payment tiles | No direct-sale/payment contract | Amount normalization and matching, supported-method selection when supplied; submission disabled |
| Success | `DirectSaleSuccessScreen` | BACKEND PENDING | Receipt summary, success icon, reset and back | Green success circle, centered receipt, blue restart action | No confirmed-sale receipt contract | Receipt-driven view only; no production action manufactures success |

## Widgets created

All are under `lib/features/drawer_features/direct_sale/presentation/widgets/`:

| File | Responsibility |
| --- | --- |
| `direct_sale_page.dart` | Shared RTL header, fixed action footer, route/back handling |
| `direct_sale_card.dart` | Feature card border, radius, padding and shadow |
| `direct_sale_customer_choice.dart` | Customer-type option and selected state |
| `direct_sale_customer_card.dart` | Cash/saved customer summary and change action |
| `direct_sale_customer_form.dart` | Required/optional customer fields and validation |
| `direct_sale_location_card.dart` | Optional location request, coordinates, accuracy and failures |
| `direct_sale_product_card.dart` | Supplied price/stock display and quantity controls |
| `direct_sale_checkout_summary.dart` | Selected product lines and total |
| `direct_sale_amount_field.dart` | Counted amount and match/mismatch feedback |
| `direct_sale_payment_methods.dart` | Cash, InstaPay and wallet method tiles |
| `direct_sale_notice.dart` | Localized unavailable/error notices |

## Existing code reused

- Existing feature folders, Cubit/state conventions, GetIt factory registrations, GoRouter transitions and drawer callback pattern.
- `AppColors`, `Styles`, Cairo fonts, Material icons, `CustomTextField`, `CustomButton`, and the existing currency formatter.
- Arabic ARB localization and generated `AppLocalizations`; no additional language files or packages.
- Existing Geolocator dependency for on-demand location capture, with permission/service checks and a timeout.

Existing delivery, payment and authentication Cubits, repositories, usecases and API services were not changed. They are not repurposed for direct sales because their contracts describe different operations.

## Remaining backend dependencies

1. Customer creation returning a confirmed saved customer identifier and supported fields.
2. Current sellable vehicle stock and authoritative unit pricing. Loaded trip quantities and treasury sample data are not treated as current stock.
3. Direct-sale submission and collection, including supported payment methods, server validation and retry/idempotency behavior.
4. A confirmed receipt for success presentation. No local draft is presented as a saved sale.

All supplied screen layouts are implemented. End-to-end customer saving and sales remain backend pending. No additional reference material is needed for these layouts.

## Verification

- Formatting: changed handwritten files formatted; final dry run reported 28 files, zero changes.
- Localization regenerated using `flutter gen-l10n`.
- Final `flutter analyze --no-pub`: passed with no issues. Direct-sale scoped analysis also passed with no issues.
- Flutter tests: 24 passing, covering drawer routing, step/back behavior, form and checkout drafts, phone validation, quantity limits, exact monetary matching, location failures/duplicate requests, receipt-only success and reset.
- Responsive checks: every screen at 320, 360 and 390 logical pixels, with text scales 1.0 and 1.5, including scrolling; no RenderFlex overflow after the fixes.
- Visual review: rendered widget screenshots compared manually with the supplied screenshots. Screenshots are under the ignored `build/direct_sale_ui/` directory. Sample customer/products/receipt data exist only in `test/direct_sale_fixtures.dart`.
- Android: an isolated smoke-test entrypoint built successfully. Reliable device interaction verification was unavailable: the shared emulator resumed the running application and a separate emulator instance could not be launched. No end-to-end device verification is claimed.
- The routed drawer test also passed with an Android-style system-back event: products returns to customer selection, and the header back button then restores the previous route.
- The universal debug build was stopped after it stalled downloading architecture-specific Gradle artifacts. The normal-entrypoint x64 retry initially hit concurrent contact-support integration errors. When its ARB messages became available, localization was regenerated. An obsolete empty `onContactUsTap` callback was removed because it duplicated the newly added active callback; the new contact action was preserved.
- Final normal application build: `flutter build apk --debug --no-pub --target-platform android-x64 -t lib/app/main.dart` passed and produced `build/app/outputs/flutter-apk/app-debug.apk`. ARM/universal debug builds were not completed.
- Direct-sale tests were rerun after the shared localization/callback changes: all 24 passed again.

## Preserved workspace changes

The pre-existing drawer edit and staged deletion of six earlier test files were left intact. New direct-sale tests were added separately. The drawer widget itself was not edited by this implementation. Concurrent contact-support feature and LayoutCubit edits were preserved, with only the obsolete duplicate empty drawer callback removed to restore compilation.
