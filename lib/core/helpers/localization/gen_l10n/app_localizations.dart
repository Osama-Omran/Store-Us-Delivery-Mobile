import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ar')];

  /// No description provided for @store_us_delivery.
  ///
  /// In ar, this message translates to:
  /// **'ستور أص دليڤري'**
  String get store_us_delivery;

  /// No description provided for @delivery_agent_app.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق مندوب التوصيل'**
  String get delivery_agent_app;

  /// No description provided for @phone_number.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phone_number;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة السر'**
  String get password;

  /// No description provided for @phone_number_is_required.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف مطلوب'**
  String get phone_number_is_required;

  /// No description provided for @invalid_phone_number.
  ///
  /// In ar, this message translates to:
  /// **'رقم هاتف غير صالح'**
  String get invalid_phone_number;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @password_is_required.
  ///
  /// In ar, this message translates to:
  /// **'كلمة السر مطلوبة'**
  String get password_is_required;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @trip.
  ///
  /// In ar, this message translates to:
  /// **'الرحلة'**
  String get trip;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @menu.
  ///
  /// In ar, this message translates to:
  /// **'القائمة'**
  String get menu;

  /// No description provided for @trip_orders_are_unavailable.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الرحلة غير متاحة'**
  String get trip_orders_are_unavailable;

  /// No description provided for @you_must_confirm_receiving_van_and_goods_first.
  ///
  /// In ar, this message translates to:
  /// **'يجب تأكيد استلام الشاحنة و البضاعة أولاً'**
  String get you_must_confirm_receiving_van_and_goods_first;

  /// No description provided for @you_have_a_new_trip_awaiting_for_receiving_confirmation.
  ///
  /// In ar, this message translates to:
  /// **'لديك رحلة جديدة في انتظار تأكيد الاستلام'**
  String get you_have_a_new_trip_awaiting_for_receiving_confirmation;

  /// No description provided for @review_and_receive_van.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة و استلام الشاحنة'**
  String get review_and_receive_van;

  /// No description provided for @confirm_receiving_van.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد استلام الشاحنة'**
  String get confirm_receiving_van;

  /// No description provided for @trip_number.
  ///
  /// In ar, this message translates to:
  /// **'رقم الرحلة'**
  String get trip_number;

  /// No description provided for @warehouse.
  ///
  /// In ar, this message translates to:
  /// **'المخزن'**
  String get warehouse;

  /// No description provided for @van.
  ///
  /// In ar, this message translates to:
  /// **'الشاحنة'**
  String get van;

  /// No description provided for @driver.
  ///
  /// In ar, this message translates to:
  /// **'السائق'**
  String get driver;

  /// No description provided for @loading_time.
  ///
  /// In ar, this message translates to:
  /// **'وقت التحميل'**
  String get loading_time;

  /// No description provided for @loaded_goods_details.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل البضاعة المحملة'**
  String get loaded_goods_details;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
