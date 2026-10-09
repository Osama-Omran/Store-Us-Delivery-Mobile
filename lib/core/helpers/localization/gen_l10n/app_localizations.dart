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

  /// No description provided for @total_items.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الأصناف'**
  String get total_items;

  /// No description provided for @total_quantities.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الكميات'**
  String get total_quantities;

  /// No description provided for @search_for_a_product.
  ///
  /// In ar, this message translates to:
  /// **'بحث عن منتج'**
  String get search_for_a_product;

  /// No description provided for @confirm_receiving.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الاستلام'**
  String get confirm_receiving;

  /// No description provided for @confirm_receiving_description.
  ///
  /// In ar, this message translates to:
  /// **'أؤكد أنني راجعت الشاحنة والبضاعة الموضحة أعلاه واستلمتها.'**
  String get confirm_receiving_description;

  /// No description provided for @confirm_receiving_warning.
  ///
  /// In ar, this message translates to:
  /// **'التقط صورة سيلفي واضحة واعتمدها أولاً لتفعيل التأكيد'**
  String get confirm_receiving_warning;

  /// No description provided for @loaded_quantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المحملة'**
  String get loaded_quantity;

  /// No description provided for @from_trip_orders.
  ///
  /// In ar, this message translates to:
  /// **'من طلبات الرحلة'**
  String get from_trip_orders;

  /// No description provided for @unit.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة'**
  String get unit;

  /// No description provided for @receiving_proof_photo.
  ///
  /// In ar, this message translates to:
  /// **'صورة إثبات استلام العربية والبضاعة'**
  String get receiving_proof_photo;

  /// No description provided for @open_camera_and_capture.
  ///
  /// In ar, this message translates to:
  /// **'فتح الكاميرا والتقاط صورة'**
  String get open_camera_and_capture;

  /// No description provided for @proof_photo_auto_details.
  ///
  /// In ar, this message translates to:
  /// **'يُضاف التاريخ والوقت ورقم الرحلة تلقائياً'**
  String get proof_photo_auto_details;

  /// No description provided for @retake_photo.
  ///
  /// In ar, this message translates to:
  /// **'إعادة التصوير'**
  String get retake_photo;

  /// No description provided for @proof_photo_error.
  ///
  /// In ar, this message translates to:
  /// **'تعذر التقاط الصورة، يرجى المحاولة مرة أخرى'**
  String get proof_photo_error;

  /// No description provided for @use_photo.
  ///
  /// In ar, this message translates to:
  /// **'استخدام الصورة'**
  String get use_photo;

  /// No description provided for @photo_approved.
  ///
  /// In ar, this message translates to:
  /// **'تم اعتماد الصورة'**
  String get photo_approved;

  /// No description provided for @confirm_receiving_dialog_title.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الاستلام؟'**
  String get confirm_receiving_dialog_title;

  /// No description provided for @confirm_receiving_dialog_description.
  ///
  /// In ar, this message translates to:
  /// **'أنت تؤكد أنك راجعت واستلمت العربية والبضاعة الموضحة في الرحلة'**
  String get confirm_receiving_dialog_description;

  /// No description provided for @yes_confirm_receiving.
  ///
  /// In ar, this message translates to:
  /// **'نعم، تأكيد الاستلام'**
  String get yes_confirm_receiving;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @trip_receiving_success_title.
  ///
  /// In ar, this message translates to:
  /// **'تم تأكيد استلام العربية بنجاح'**
  String get trip_receiving_success_title;

  /// No description provided for @trip_receiving_success_description.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل استلامك للعربية والبضاعة.'**
  String get trip_receiving_success_description;

  /// No description provided for @receiving_time.
  ///
  /// In ar, this message translates to:
  /// **'وقت الاستلام'**
  String get receiving_time;

  /// No description provided for @show_trip_orders.
  ///
  /// In ar, this message translates to:
  /// **'عرض طلبات الرحلة'**
  String get show_trip_orders;

  /// No description provided for @welcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحبا،'**
  String get welcome;

  /// No description provided for @currently_on_trip.
  ///
  /// In ar, this message translates to:
  /// **'في رحلة حاليا'**
  String get currently_on_trip;

  /// No description provided for @your_current_trip.
  ///
  /// In ar, this message translates to:
  /// **'رحلتك الحالية'**
  String get your_current_trip;

  /// No description provided for @started_at.
  ///
  /// In ar, this message translates to:
  /// **'بدأت'**
  String get started_at;

  /// No description provided for @order.
  ///
  /// In ar, this message translates to:
  /// **'طلب'**
  String get order;

  /// No description provided for @delivered_orders.
  ///
  /// In ar, this message translates to:
  /// **'تم تسليمهم'**
  String get delivered_orders;

  /// No description provided for @remaining_orders.
  ///
  /// In ar, this message translates to:
  /// **'متبقي'**
  String get remaining_orders;

  /// No description provided for @collected_amount.
  ///
  /// In ar, this message translates to:
  /// **'المحصل'**
  String get collected_amount;

  /// No description provided for @egp_currency.
  ///
  /// In ar, this message translates to:
  /// **'ج.م'**
  String get egp_currency;

  /// No description provided for @continue_trip.
  ///
  /// In ar, this message translates to:
  /// **'متابعة الرحلة'**
  String get continue_trip;

  /// No description provided for @previous_today_trips.
  ///
  /// In ar, this message translates to:
  /// **'رحلات اليوم السابقة'**
  String get previous_today_trips;

  /// No description provided for @trip_label.
  ///
  /// In ar, this message translates to:
  /// **'رحلة'**
  String get trip_label;

  /// No description provided for @orders_plural.
  ///
  /// In ar, this message translates to:
  /// **'طلبات'**
  String get orders_plural;

  /// No description provided for @completed_at.
  ///
  /// In ar, this message translates to:
  /// **'اكتملت'**
  String get completed_at;

  /// No description provided for @settled.
  ///
  /// In ar, this message translates to:
  /// **'تمت التسوية'**
  String get settled;

  /// No description provided for @unread_notifications.
  ///
  /// In ar, this message translates to:
  /// **'غير مقروءة'**
  String get unread_notifications;

  /// No description provided for @no_notifications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات حالياً'**
  String get no_notifications;

  /// No description provided for @notification_new_trip_title.
  ///
  /// In ar, this message translates to:
  /// **'تم إسناد رحلة جديدة إليك'**
  String get notification_new_trip_title;

  /// No description provided for @notification_new_trip_description.
  ///
  /// In ar, this message translates to:
  /// **'رحلة 12 — TRIP-0025 طلب من مخزن 6 أكتوبر'**
  String get notification_new_trip_description;

  /// No description provided for @notification_route_updated_title.
  ///
  /// In ar, this message translates to:
  /// **'تم تعديل ترتيب الرحلة'**
  String get notification_route_updated_title;

  /// No description provided for @notification_route_updated_description.
  ///
  /// In ar, this message translates to:
  /// **'تم تقديم محطة سوبر ماركت النور قبل ماركت الأمل'**
  String get notification_route_updated_description;

  /// No description provided for @notification_order_updated_title.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الطلب SO-00254'**
  String get notification_order_updated_title;

  /// No description provided for @notification_order_updated_description.
  ///
  /// In ar, this message translates to:
  /// **'تم تعديل كمية كوكاكولا 330 مل إلى 10 علب'**
  String get notification_order_updated_description;

  /// No description provided for @notification_payment_received_title.
  ///
  /// In ar, this message translates to:
  /// **'تم استلام المبلغ بواسطة المخزن'**
  String get notification_payment_received_title;

  /// No description provided for @notification_payment_received_description.
  ///
  /// In ar, this message translates to:
  /// **'تم تسوية رحلة TRIP-0024 — 6,200 ج.م'**
  String get notification_payment_received_description;

  /// No description provided for @notification_trip_completed_title.
  ///
  /// In ar, this message translates to:
  /// **'تم إنهاء الرحلة'**
  String get notification_trip_completed_title;

  /// No description provided for @notification_trip_completed_description.
  ///
  /// In ar, this message translates to:
  /// **'رحلة TRIP-0024 اكتملت بنجاح'**
  String get notification_trip_completed_description;

  /// No description provided for @two_hours_ago.
  ///
  /// In ar, this message translates to:
  /// **'منذ ساعتين'**
  String get two_hours_ago;

  /// No description provided for @one_hour_ago.
  ///
  /// In ar, this message translates to:
  /// **'منذ ساعة'**
  String get one_hour_ago;

  /// No description provided for @forty_five_minutes_ago.
  ///
  /// In ar, this message translates to:
  /// **'منذ 45 دقيقة'**
  String get forty_five_minutes_ago;

  /// No description provided for @yesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get yesterday;

  /// No description provided for @account.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get account;

  /// No description provided for @treasury.
  ///
  /// In ar, this message translates to:
  /// **'الخزينة'**
  String get treasury;

  /// No description provided for @deliveries.
  ///
  /// In ar, this message translates to:
  /// **'التسليمات'**
  String get deliveries;

  /// No description provided for @customers.
  ///
  /// In ar, this message translates to:
  /// **'العملاء'**
  String get customers;

  /// No description provided for @areas.
  ///
  /// In ar, this message translates to:
  /// **'المناطق'**
  String get areas;

  /// No description provided for @reports.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get reports;

  /// No description provided for @contact_us.
  ///
  /// In ar, this message translates to:
  /// **'تواصل معنا'**
  String get contact_us;

  /// No description provided for @receive_custody.
  ///
  /// In ar, this message translates to:
  /// **'استلام العهدة'**
  String get receive_custody;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @driver_selfie_title.
  ///
  /// In ar, this message translates to:
  /// **'صورة المندوب لتأكيد الاستلام'**
  String get driver_selfie_title;

  /// No description provided for @selfie_capture_action.
  ///
  /// In ar, this message translates to:
  /// **'فتح الكاميرا والتقاط سيلفي'**
  String get selfie_capture_action;

  /// No description provided for @selfie_capture_hint.
  ///
  /// In ar, this message translates to:
  /// **'اجعل وجهك واضحًا داخل الصورة وفي إضاءة جيدة'**
  String get selfie_capture_hint;

  /// No description provided for @selfie_checking_photo.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ فحص وضوح الصورة والوجه...'**
  String get selfie_checking_photo;

  /// No description provided for @selfie_no_face_error.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على وجه. صوّر وجهك بوضوح باستخدام الكاميرا الأمامية.'**
  String get selfie_no_face_error;

  /// No description provided for @selfie_many_faces_error.
  ///
  /// In ar, this message translates to:
  /// **'ظهر أكثر من وجه في الصورة. يجب أن تكون وحدك داخل الصورة.'**
  String get selfie_many_faces_error;

  /// No description provided for @selfie_too_small_error.
  ///
  /// In ar, this message translates to:
  /// **'وجهك بعيد أو حجم الصورة صغير. اقترب من الكاميرا وحاول مرة أخرى.'**
  String get selfie_too_small_error;

  /// No description provided for @selfie_not_centered_error.
  ///
  /// In ar, this message translates to:
  /// **'اجعل وجهك في منتصف الصورة ثم أعد التصوير.'**
  String get selfie_not_centered_error;

  /// No description provided for @selfie_not_frontal_error.
  ///
  /// In ar, this message translates to:
  /// **'انظر إلى الكاميرا مباشرةً دون إمالة الرأس.'**
  String get selfie_not_frontal_error;

  /// No description provided for @selfie_eyes_not_visible_error.
  ///
  /// In ar, this message translates to:
  /// **'تأكد من ظهور العينين بوضوح وعدم تغطية الوجه.'**
  String get selfie_eyes_not_visible_error;

  /// No description provided for @selfie_too_dark_error.
  ///
  /// In ar, this message translates to:
  /// **'الصورة مظلمة. انتقل لمكان أكثر إضاءة وأعد التصوير.'**
  String get selfie_too_dark_error;

  /// No description provided for @selfie_too_bright_error.
  ///
  /// In ar, this message translates to:
  /// **'الإضاءة قوية جدًا. تجنب الضوء المباشر وأعد التصوير.'**
  String get selfie_too_bright_error;

  /// No description provided for @selfie_blurry_error.
  ///
  /// In ar, this message translates to:
  /// **'الصورة غير واضحة أو مهزوزة. ثبّت الهاتف وأعد التصوير.'**
  String get selfie_blurry_error;

  /// No description provided for @selfie_invalid_image_error.
  ///
  /// In ar, this message translates to:
  /// **'تعذر قراءة الصورة. التقط صورة جديدة من الكاميرا.'**
  String get selfie_invalid_image_error;

  /// No description provided for @selfie_check_failed_error.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء فحص الصورة. حاول مرة أخرى.'**
  String get selfie_check_failed_error;

  /// No description provided for @face_not_detected.
  ///
  /// In ar, this message translates to:
  /// **'لم نتمكن من التعرف على وجه في الصورة. التقط صورة شخصية واضحة لوجهك.'**
  String get face_not_detected;

  /// No description provided for @face_multiple_detected.
  ///
  /// In ar, this message translates to:
  /// **'تم اكتشاف أكثر من وجه. يجب أن تظهر أنت فقط في الصورة.'**
  String get face_multiple_detected;

  /// No description provided for @face_too_small.
  ///
  /// In ar, this message translates to:
  /// **'وجهك بعيد عن الكاميرا. قرّب الهاتف وحاول مرة أخرى.'**
  String get face_too_small;

  /// No description provided for @face_not_frontal.
  ///
  /// In ar, this message translates to:
  /// **'انظر مباشرة إلى الكاميرا وحافظ على وجهك مستقيماً.'**
  String get face_not_frontal;

  /// No description provided for @face_eyes_closed.
  ///
  /// In ar, this message translates to:
  /// **'عيناك مغمضتان. افتح عينيك والتقط الصورة مرة أخرى.'**
  String get face_eyes_closed;

  /// No description provided for @my_current_trip.
  ///
  /// In ar, this message translates to:
  /// **'رحلتي الحالية'**
  String get my_current_trip;

  /// No description provided for @trip_orders.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الرحلة'**
  String get trip_orders;

  /// No description provided for @handled_orders_label.
  ///
  /// In ar, this message translates to:
  /// **'تم التعامل معهم'**
  String get handled_orders_label;

  /// No description provided for @collected_so_far.
  ///
  /// In ar, this message translates to:
  /// **'المحصل حتى الآن'**
  String get collected_so_far;

  /// No description provided for @of_total.
  ///
  /// In ar, this message translates to:
  /// **'من'**
  String get of_total;

  /// No description provided for @orders_handled.
  ///
  /// In ar, this message translates to:
  /// **'طلب تم التعامل معهم'**
  String get orders_handled;

  /// No description provided for @all_orders.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all_orders;

  /// No description provided for @awaiting_delivery.
  ///
  /// In ar, this message translates to:
  /// **'في انتظار التسليم'**
  String get awaiting_delivery;

  /// No description provided for @delivered_fully.
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم بالكامل'**
  String get delivered_fully;

  /// No description provided for @delivered_partially.
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم جزئياً'**
  String get delivered_partially;

  /// No description provided for @delivery_rescheduled.
  ///
  /// In ar, this message translates to:
  /// **'تمت إعادة الجدولة'**
  String get delivery_rescheduled;

  /// No description provided for @delivery_cancelled.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء التسليم'**
  String get delivery_cancelled;

  /// No description provided for @order_value.
  ///
  /// In ar, this message translates to:
  /// **'قيمة الأوردر'**
  String get order_value;

  /// No description provided for @payment_collected.
  ///
  /// In ar, this message translates to:
  /// **'تم التحصيل'**
  String get payment_collected;

  /// No description provided for @amount_collected.
  ///
  /// In ar, this message translates to:
  /// **'محصل'**
  String get amount_collected;

  /// No description provided for @view_delivery_details.
  ///
  /// In ar, this message translates to:
  /// **'عرض تفاصيل التسليم'**
  String get view_delivery_details;

  /// No description provided for @open_order.
  ///
  /// In ar, this message translates to:
  /// **'فتح الأوردر'**
  String get open_order;

  /// No description provided for @open_directions.
  ///
  /// In ar, this message translates to:
  /// **'فتح الاتجاهات'**
  String get open_directions;

  /// No description provided for @call_customer.
  ///
  /// In ar, this message translates to:
  /// **'اتصال بالعميل'**
  String get call_customer;

  /// No description provided for @no_orders_in_filter.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات بهذا التصنيف'**
  String get no_orders_in_filter;

  /// No description provided for @trip_map_title.
  ///
  /// In ar, this message translates to:
  /// **'خريطة رحلة'**
  String get trip_map_title;

  /// No description provided for @trip_map_next_stop.
  ///
  /// In ar, this message translates to:
  /// **'المحطة التالية'**
  String get trip_map_next_stop;

  /// No description provided for @trip_map_selected_stop.
  ///
  /// In ar, this message translates to:
  /// **'المحطة المختارة'**
  String get trip_map_selected_stop;

  /// No description provided for @trip_map_out_of.
  ///
  /// In ar, this message translates to:
  /// **'من'**
  String get trip_map_out_of;

  /// No description provided for @trip_map_arrival_in.
  ///
  /// In ar, this message translates to:
  /// **'الوصول خلال'**
  String get trip_map_arrival_in;

  /// No description provided for @trip_map_minutes.
  ///
  /// In ar, this message translates to:
  /// **'دقائق'**
  String get trip_map_minutes;

  /// No description provided for @trip_map_km.
  ///
  /// In ar, this message translates to:
  /// **'كم'**
  String get trip_map_km;

  /// No description provided for @trip_map_meters.
  ///
  /// In ar, this message translates to:
  /// **'متر'**
  String get trip_map_meters;

  /// No description provided for @trip_map_start_navigation.
  ///
  /// In ar, this message translates to:
  /// **'بدء الملاحة'**
  String get trip_map_start_navigation;

  /// No description provided for @trip_map_show_order.
  ///
  /// In ar, this message translates to:
  /// **'عرض الطلب'**
  String get trip_map_show_order;

  /// No description provided for @trip_map_calculating_route.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ حساب الطريق ووقت الوصول...'**
  String get trip_map_calculating_route;

  /// No description provided for @trip_map_location_unavailable.
  ///
  /// In ar, this message translates to:
  /// **'فعّل إذن الموقع لعرض المسافة ووقت الوصول'**
  String get trip_map_location_unavailable;

  /// No description provided for @trip_map_route_unavailable.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حساب الطريق حالياً. يمكنك بدء الملاحة.'**
  String get trip_map_route_unavailable;

  /// No description provided for @trip_map_route_not_connected.
  ///
  /// In ar, this message translates to:
  /// **'وقت الوصول والمسافة متاحان بعد ربط خدمة المسارات'**
  String get trip_map_route_not_connected;

  /// No description provided for @trip_map_navigation_failed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح خرائط Google. حاول مرة أخرى.'**
  String get trip_map_navigation_failed;

  /// No description provided for @trip_map_no_stops.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد محطات بإحداثيات لعرضها على الخريطة'**
  String get trip_map_no_stops;

  /// No description provided for @trip_map_refresh_location.
  ///
  /// In ar, this message translates to:
  /// **'تحديث موقع المندوب'**
  String get trip_map_refresh_location;

  /// No description provided for @an_error_occurred_try_again_later.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ، من فضلك حاول لاحقاً'**
  String get an_error_occurred_try_again_later;

  /// No description provided for @no_internet_please_try_again.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت، حاول لاحقاً'**
  String get no_internet_please_try_again;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @enter_your_email.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني'**
  String get enter_your_email;

  /// No description provided for @email_is_required.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني مطلوب'**
  String get email_is_required;

  /// No description provided for @please_enter_a_valid_email.
  ///
  /// In ar, this message translates to:
  /// **'من فضلك أدخل بريد إلكتروني صحيح'**
  String get please_enter_a_valid_email;
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
