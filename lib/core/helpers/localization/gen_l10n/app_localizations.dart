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
  /// **'فتح الطلب'**
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

  /// No description provided for @trip_history_title.
  ///
  /// In ar, this message translates to:
  /// **'سجل الرحلات السابقة'**
  String get trip_history_title;

  /// No description provided for @trip_history_completed.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get trip_history_completed;

  /// No description provided for @trip_history_cancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get trip_history_cancelled;

  /// No description provided for @trip_history_date.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الرحلة'**
  String get trip_history_date;

  /// No description provided for @trip_history_orders_total.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الطلبات'**
  String get trip_history_orders_total;

  /// No description provided for @trip_history_acceptance.
  ///
  /// In ar, this message translates to:
  /// **'حالة الاستلام'**
  String get trip_history_acceptance;

  /// No description provided for @trip_history_acceptance_pending.
  ///
  /// In ar, this message translates to:
  /// **'في انتظار الاستلام'**
  String get trip_history_acceptance_pending;

  /// No description provided for @trip_history_completed_at.
  ///
  /// In ar, this message translates to:
  /// **'وقت اكتمال الرحلة'**
  String get trip_history_completed_at;

  /// No description provided for @trip_history_not_available.
  ///
  /// In ar, this message translates to:
  /// **'غير متاح'**
  String get trip_history_not_available;

  /// No description provided for @trip_history_retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get trip_history_retry;

  /// No description provided for @trip_history_empty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رحلات سابقة'**
  String get trip_history_empty;

  /// No description provided for @trip_status.
  ///
  /// In ar, this message translates to:
  /// **'حالة الرحلة'**
  String get trip_status;

  /// No description provided for @trip_status_shipped.
  ///
  /// In ar, this message translates to:
  /// **'تم شحن الرحلة'**
  String get trip_status_shipped;

  /// No description provided for @trip_total_orders.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الطلبات'**
  String get trip_total_orders;

  /// No description provided for @trip_acceptance_status.
  ///
  /// In ar, this message translates to:
  /// **'حالة الاستلام'**
  String get trip_acceptance_status;

  /// No description provided for @trip_acceptance_pending.
  ///
  /// In ar, this message translates to:
  /// **'في انتظار الاستلام'**
  String get trip_acceptance_pending;

  /// No description provided for @trip_accepted_at.
  ///
  /// In ar, this message translates to:
  /// **'وقت الاستلام'**
  String get trip_accepted_at;

  /// No description provided for @current_trip_load_failed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل الرحلة الحالية. حاول مرة أخرى.'**
  String get current_trip_load_failed;

  /// No description provided for @current_trip_empty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رحلة حالية متاحة.'**
  String get current_trip_empty;

  /// No description provided for @current_trip_retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get current_trip_retry;

  /// No description provided for @loaded_items_extra_source.
  ///
  /// In ar, this message translates to:
  /// **'بضاعة إضافية'**
  String get loaded_items_extra_source;

  /// No description provided for @loaded_items_load_failed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل البضاعة المحملة. حاول مرة أخرى.'**
  String get loaded_items_load_failed;

  /// No description provided for @loaded_items_empty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أصناف محملة لهذه الرحلة.'**
  String get loaded_items_empty;

  /// No description provided for @loaded_items_no_search_results.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أصناف مطابقة للبحث.'**
  String get loaded_items_no_search_results;

  /// No description provided for @trip_accept_failed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تأكيد استلام الرحلة. حاول مرة أخرى.'**
  String get trip_accept_failed;

  /// No description provided for @trip_accept_photo_missing.
  ///
  /// In ar, this message translates to:
  /// **'الصورة غير متاحة. يرجى التقاط صورة شخصية جديدة.'**
  String get trip_accept_photo_missing;

  /// No description provided for @trip_accept_location_disabled.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تفعيل خدمة الموقع GPS لتأكيد استلام الرحلة.'**
  String get trip_accept_location_disabled;

  /// No description provided for @trip_accept_location_permission_denied.
  ///
  /// In ar, this message translates to:
  /// **'يجب السماح للتطبيق بالوصول إلى موقعك. يمكنك تفعيل الإذن من إعدادات التطبيق.'**
  String get trip_accept_location_permission_denied;

  /// No description provided for @trip_accept_location_timeout.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحديد موقعك في الوقت المحدد. حاول مرة أخرى.'**
  String get trip_accept_location_timeout;

  /// No description provided for @top_rank.
  ///
  /// In ar, this message translates to:
  /// **'لوحة الترتيب'**
  String get top_rank;

  /// No description provided for @stock_transfer.
  ///
  /// In ar, this message translates to:
  /// **'نقل مخزني'**
  String get stock_transfer;

  /// No description provided for @direct_sale.
  ///
  /// In ar, this message translates to:
  /// **'بيع مباشر'**
  String get direct_sale;

  /// No description provided for @account_delivery_representative.
  ///
  /// In ar, this message translates to:
  /// **'مندوب توصيل'**
  String get account_delivery_representative;

  /// No description provided for @account_my_data.
  ///
  /// In ar, this message translates to:
  /// **'بياناتي'**
  String get account_my_data;

  /// No description provided for @account_edit_data.
  ///
  /// In ar, this message translates to:
  /// **'تعديل البيانات'**
  String get account_edit_data;

  /// No description provided for @account_name.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get account_name;

  /// No description provided for @account_employee_number.
  ///
  /// In ar, this message translates to:
  /// **'رقم الموظف'**
  String get account_employee_number;

  /// No description provided for @account_change_password.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get account_change_password;

  /// No description provided for @account_wallet_title.
  ///
  /// In ar, this message translates to:
  /// **'محفظة التحصيل الحالية'**
  String get account_wallet_title;

  /// No description provided for @account_wallet_name.
  ///
  /// In ar, this message translates to:
  /// **'محفظة'**
  String get account_wallet_name;

  /// No description provided for @account_today_trips.
  ///
  /// In ar, this message translates to:
  /// **'رحلات اليوم'**
  String get account_today_trips;

  /// No description provided for @account_delivered_orders.
  ///
  /// In ar, this message translates to:
  /// **'طلبات مسلمة'**
  String get account_delivered_orders;

  /// No description provided for @account_today_collection.
  ///
  /// In ar, this message translates to:
  /// **'تحصيل اليوم ج.م'**
  String get account_today_collection;

  /// No description provided for @account_sync_status.
  ///
  /// In ar, this message translates to:
  /// **'حالة المزامنة'**
  String get account_sync_status;

  /// No description provided for @account_sync_unavailable.
  ///
  /// In ar, this message translates to:
  /// **'بيانات المزامنة غير متاحة حاليًا'**
  String get account_sync_unavailable;

  /// No description provided for @account_offline_preview.
  ///
  /// In ar, this message translates to:
  /// **'معاينة وضع عدم الاتصال'**
  String get account_offline_preview;

  /// No description provided for @account_feature_unavailable.
  ///
  /// In ar, this message translates to:
  /// **'هذه الخدمة غير متاحة حاليًا'**
  String get account_feature_unavailable;

  /// No description provided for @account_logout_confirm_title.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج؟'**
  String get account_logout_confirm_title;

  /// No description provided for @account_logout_confirm_description.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟'**
  String get account_logout_confirm_description;

  /// No description provided for @account_cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get account_cancel;

  /// No description provided for @account_load_failed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل بيانات الحساب. حاول مرة أخرى.'**
  String get account_load_failed;

  /// No description provided for @account_logout_failed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تسجيل الخروج. حاول مرة أخرى.'**
  String get account_logout_failed;

  /// No description provided for @account_retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get account_retry;

  /// No description provided for @trip_tab_load_failed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل الرحلة الحالية. حاول مرة أخرى.'**
  String get trip_tab_load_failed;

  /// No description provided for @trip_tab_no_trip.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رحلة حالية مرتبطة بحسابك.'**
  String get trip_tab_no_trip;

  /// No description provided for @trip_tab_unsupported_status.
  ///
  /// In ar, this message translates to:
  /// **'الرحلة الحالية غير متاحة للتنفيذ في هذه الحالة.'**
  String get trip_tab_unsupported_status;

  /// No description provided for @trip_tab_unknown_status.
  ///
  /// In ar, this message translates to:
  /// **'حالة غير معروفة'**
  String get trip_tab_unknown_status;

  /// No description provided for @trip_tab_retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get trip_tab_retry;

  /// No description provided for @trip_tab_accepted.
  ///
  /// In ar, this message translates to:
  /// **'تم استلام الرحلة'**
  String get trip_tab_accepted;

  /// No description provided for @trip_tab_orders_not_loaded.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل طلبات الرحلة ستظهر بعد ربط خدمة الطلبات.'**
  String get trip_tab_orders_not_loaded;

  /// No description provided for @trip_progress_unavailable.
  ///
  /// In ar, this message translates to:
  /// **'بيانات إنجاز الطلبات غير متاحة حالياً'**
  String get trip_progress_unavailable;

  /// No description provided for @trip_map_wait_orders.
  ///
  /// In ar, this message translates to:
  /// **'خريطة الرحلة ستتاح بعد تحميل مواقع الطلبات.'**
  String get trip_map_wait_orders;

  /// No description provided for @trip_orders_load_failed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل طلبات الرحلة. حاول مرة أخرى.'**
  String get trip_orders_load_failed;

  /// No description provided for @trip_order_details_unavailable.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الأوردر غير متاحة حالياً.'**
  String get trip_order_details_unavailable;

  /// No description provided for @trip_action_unavailable.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تنفيذ العملية. حاول مرة أخرى.'**
  String get trip_action_unavailable;

  /// No description provided for @home_no_current_trip.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رحلة حالية مرتبطة بحسابك.'**
  String get home_no_current_trip;

  /// No description provided for @home_retry_orders.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل إحصائيات الطلبات، اضغط لإعادة المحاولة.'**
  String get home_retry_orders;

  /// No description provided for @home_history_completed.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get home_history_completed;

  /// No description provided for @home_history_cancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get home_history_cancelled;

  /// No description provided for @home_history_empty_today.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رحلات سابقة اليوم.'**
  String get home_history_empty_today;

  /// No description provided for @home_history_load_failed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل الرحلات السابقة. حاول مرة أخرى.'**
  String get home_history_load_failed;

  /// No description provided for @order_details_title.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل التسليم'**
  String get order_details_title;

  /// No description provided for @order_details_load_failed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل تفاصيل الطلب. حاول مرة أخرى.'**
  String get order_details_load_failed;

  /// No description provided for @order_details_confirmed_read_only.
  ///
  /// In ar, this message translates to:
  /// **'تم تأكيد التسليم — للعرض فقط'**
  String get order_details_confirmed_read_only;

  /// No description provided for @order_details_read_only.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الطلب — للعرض فقط'**
  String get order_details_read_only;

  /// No description provided for @order_delivery_status.
  ///
  /// In ar, this message translates to:
  /// **'حالة التسليم'**
  String get order_delivery_status;

  /// No description provided for @order_delivery_time.
  ///
  /// In ar, this message translates to:
  /// **'وقت التسليم'**
  String get order_delivery_time;

  /// No description provided for @order_delivery_reason.
  ///
  /// In ar, this message translates to:
  /// **'سبب حالة التسليم'**
  String get order_delivery_reason;

  /// No description provided for @order_rescheduled_for.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ إعادة الجدولة'**
  String get order_rescheduled_for;

  /// No description provided for @order_details_items_title.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات المطلوبة والكميات المتاحة'**
  String get order_details_items_title;

  /// No description provided for @order_details_quantities_hint.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المطلوبة / أقصى كمية قابلة للتسليم'**
  String get order_details_quantities_hint;

  /// No description provided for @order_details_vehicle_available.
  ///
  /// In ar, this message translates to:
  /// **'المتاح بالعربية'**
  String get order_details_vehicle_available;

  /// No description provided for @order_details_no_items.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات في هذا الطلب.'**
  String get order_details_no_items;

  /// No description provided for @order_details_original_total.
  ///
  /// In ar, this message translates to:
  /// **'قيمة الطلب الأصلية'**
  String get order_details_original_total;

  /// No description provided for @order_details_collected.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المحصل'**
  String get order_details_collected;

  /// No description provided for @order_details_remaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get order_details_remaining;

  /// No description provided for @order_details_payment_method.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get order_details_payment_method;

  /// No description provided for @order_details_financial_unavailable.
  ///
  /// In ar, this message translates to:
  /// **'بيانات التحصيل وطريقة الدفع غير متاحة حاليًا.'**
  String get order_details_financial_unavailable;

  /// No description provided for @order_details_notes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات المندوب'**
  String get order_details_notes;

  /// No description provided for @order_details_notes_unavailable.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات المندوب غير متاحة في بيانات هذا الطلب.'**
  String get order_details_notes_unavailable;

  /// No description provided for @notifications_load_failed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل الإشعارات. حاول مرة أخرى.'**
  String get notifications_load_failed;

  /// No description provided for @notifications_mark_read_failed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحديد الإشعار كمقروء. حاول مرة أخرى.'**
  String get notifications_mark_read_failed;

  /// No description provided for @notification_just_now.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get notification_just_now;

  /// No description provided for @notification_minutes_ago.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة مضت'**
  String get notification_minutes_ago;

  /// No description provided for @notification_hours_ago.
  ///
  /// In ar, this message translates to:
  /// **'ساعة مضت'**
  String get notification_hours_ago;

  /// No description provided for @trip_map_orders_unavailable.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الرحلة لم يتم تحميلها بعد. حاول مرة أخرى.'**
  String get trip_map_orders_unavailable;

  /// No description provided for @order_customer_data.
  ///
  /// In ar, this message translates to:
  /// **'بيانات العميل'**
  String get order_customer_data;

  /// No description provided for @order_address_defined.
  ///
  /// In ar, this message translates to:
  /// **'محدد'**
  String get order_address_defined;

  /// No description provided for @order_address_only.
  ///
  /// In ar, this message translates to:
  /// **'عنوان فقط'**
  String get order_address_only;

  /// No description provided for @order_gps_only.
  ///
  /// In ar, this message translates to:
  /// **'موقع فقط'**
  String get order_gps_only;

  /// No description provided for @order_address_undefined.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get order_address_undefined;

  /// No description provided for @order_no_address.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد عنوان مسجل'**
  String get order_no_address;

  /// No description provided for @order_customer_phone_missing.
  ///
  /// In ar, this message translates to:
  /// **'رقم هاتف العميل غير متوفر.'**
  String get order_customer_phone_missing;

  /// No description provided for @order_customer_gps_missing.
  ///
  /// In ar, this message translates to:
  /// **'إحداثيات GPS غير متوفرة'**
  String get order_customer_gps_missing;

  /// No description provided for @order_location_not_defined.
  ///
  /// In ar, this message translates to:
  /// **'العنوان موجود لكن الموقع غير محدد'**
  String get order_location_not_defined;

  /// No description provided for @order_address_not_defined.
  ///
  /// In ar, this message translates to:
  /// **'عنوان وموقع العميل غير محددين'**
  String get order_address_not_defined;

  /// No description provided for @order_set_location.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الموقع الحالي'**
  String get order_set_location;

  /// No description provided for @order_update_address.
  ///
  /// In ar, this message translates to:
  /// **'تحديث عنوان وموقع العميل'**
  String get order_update_address;

  /// No description provided for @order_location_permission_required.
  ///
  /// In ar, this message translates to:
  /// **'يجب السماح بالوصول للموقع من إعدادات التطبيق.'**
  String get order_location_permission_required;

  /// No description provided for @order_location_fetch_failed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحديد موقعك الحالي. حاول مرة أخرى.'**
  String get order_location_fetch_failed;

  /// No description provided for @order_address_required.
  ///
  /// In ar, this message translates to:
  /// **'من فضلك أدخل عنوان العميل الصحيح.'**
  String get order_address_required;

  /// No description provided for @order_current_saved_data.
  ///
  /// In ar, this message translates to:
  /// **'البيانات المسجلة حالياً'**
  String get order_current_saved_data;

  /// No description provided for @order_use_current_location.
  ///
  /// In ar, this message translates to:
  /// **'استخدام موقعي الحالي'**
  String get order_use_current_location;

  /// No description provided for @order_reselect_location.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تحديد موقعي'**
  String get order_reselect_location;

  /// No description provided for @order_location_accuracy.
  ///
  /// In ar, this message translates to:
  /// **'دقة الموقع'**
  String get order_location_accuracy;

  /// No description provided for @order_meters.
  ///
  /// In ar, this message translates to:
  /// **'متر'**
  String get order_meters;

  /// No description provided for @order_correct_address.
  ///
  /// In ar, this message translates to:
  /// **'العنوان الصحيح'**
  String get order_correct_address;

  /// No description provided for @order_optional_notes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات (اختياري)'**
  String get order_optional_notes;

  /// No description provided for @order_save_address.
  ///
  /// In ar, this message translates to:
  /// **'حفظ عنوان وموقع العميل'**
  String get order_save_address;

  /// No description provided for @order_confirm_data_before_save.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد البيانات قبل الحفظ'**
  String get order_confirm_data_before_save;

  /// No description provided for @order_confirm_save.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحفظ'**
  String get order_confirm_save;

  /// No description provided for @order_back_to_edit.
  ///
  /// In ar, this message translates to:
  /// **'رجوع للتعديل'**
  String get order_back_to_edit;

  /// No description provided for @order_address_not_saved_yet.
  ///
  /// In ar, this message translates to:
  /// **'هذه البيانات لم يتم حفظها على السيرفر بعد.'**
  String get order_address_not_saved_yet;

  /// No description provided for @order_address_save_api_missing.
  ///
  /// In ar, this message translates to:
  /// **'واجهة التعديل جاهزة، لكن خدمة حفظ عنوان العميل لم يتم ربطها بعد.'**
  String get order_address_save_api_missing;

  /// No description provided for @order_products.
  ///
  /// In ar, this message translates to:
  /// **'منتجات الطلب'**
  String get order_products;

  /// No description provided for @order_visit_action_question.
  ///
  /// In ar, this message translates to:
  /// **'ماذا حدث في هذه الزيارة؟'**
  String get order_visit_action_question;

  /// No description provided for @deliver_order.
  ///
  /// In ar, this message translates to:
  /// **'تسليم الطلب'**
  String get deliver_order;

  /// No description provided for @reschedule_delivery.
  ///
  /// In ar, this message translates to:
  /// **'إعادة جدولة'**
  String get reschedule_delivery;

  /// No description provided for @cancel_delivery.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء التسليم'**
  String get cancel_delivery;

  /// No description provided for @order_operation_not_connected.
  ///
  /// In ar, this message translates to:
  /// **'هذه العملية لم يتم ربطها بالخدمة بعد.'**
  String get order_operation_not_connected;

  /// No description provided for @open_location.
  ///
  /// In ar, this message translates to:
  /// **'فتح الموقع'**
  String get open_location;

  /// No description provided for @start_navigation.
  ///
  /// In ar, this message translates to:
  /// **'بدء الملاحة'**
  String get start_navigation;

  /// No description provided for @order_latitude.
  ///
  /// In ar, this message translates to:
  /// **'خط العرض'**
  String get order_latitude;

  /// No description provided for @order_longitude.
  ///
  /// In ar, this message translates to:
  /// **'خط الطول'**
  String get order_longitude;

  /// No description provided for @order_location_required.
  ///
  /// In ar, this message translates to:
  /// **'يجب تحديد موقع العميل على الخريطة قبل الحفظ.'**
  String get order_location_required;

  /// No description provided for @order_location_saving.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ حفظ عنوان وموقع العميل...'**
  String get order_location_saving;

  /// No description provided for @order_location_save_failed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حفظ عنوان وموقع العميل. حاول مرة أخرى.'**
  String get order_location_save_failed;

  /// No description provided for @order_confirm_location_warning.
  ///
  /// In ar, this message translates to:
  /// **'تأكد من صحة العنوان والإحداثيات قبل تأكيد الحفظ.'**
  String get order_confirm_location_warning;

  /// No description provided for @order_location_updated_successfully.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث عنوان وموقع العميل بنجاح'**
  String get order_location_updated_successfully;

  /// No description provided for @order_notes_not_saved.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظات غير مشمولة في خدمة تحديث العنوان الحالية.'**
  String get order_notes_not_saved;

  /// No description provided for @top_rank_title.
  ///
  /// In ar, this message translates to:
  /// **'Top Rank'**
  String get top_rank_title;

  /// No description provided for @top_rank_subtitle.
  ///
  /// In ar, this message translates to:
  /// **'أفضل أداء في المنظومة'**
  String get top_rank_subtitle;

  /// No description provided for @top_rank_intro.
  ///
  /// In ar, this message translates to:
  /// **'تابع أفضل أداء واعرف إيه اللي ناقصك علشان تبقى رقم 1'**
  String get top_rank_intro;

  /// No description provided for @top_rank_today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get top_rank_today;

  /// No description provided for @top_rank_week.
  ///
  /// In ar, this message translates to:
  /// **'الأسبوع'**
  String get top_rank_week;

  /// No description provided for @top_rank_this_month.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر'**
  String get top_rank_this_month;

  /// No description provided for @top_rank_previous_month.
  ///
  /// In ar, this message translates to:
  /// **'الشهر السابق'**
  String get top_rank_previous_month;

  /// No description provided for @top_rank_all_warehouses.
  ///
  /// In ar, this message translates to:
  /// **'كل المخازن'**
  String get top_rank_all_warehouses;

  /// No description provided for @top_rank_warehouse_october.
  ///
  /// In ar, this message translates to:
  /// **'مخزن 6 أكتوبر (تجريبي)'**
  String get top_rank_warehouse_october;

  /// No description provided for @top_rank_warehouse_nasr_city.
  ///
  /// In ar, this message translates to:
  /// **'مخزن مدينة نصر (تجريبي)'**
  String get top_rank_warehouse_nasr_city;

  /// No description provided for @top_rank_representatives.
  ///
  /// In ar, this message translates to:
  /// **'المناديب'**
  String get top_rank_representatives;

  /// No description provided for @top_rank_drivers.
  ///
  /// In ar, this message translates to:
  /// **'السائقين'**
  String get top_rank_drivers;

  /// No description provided for @top_rank_dispatchers.
  ///
  /// In ar, this message translates to:
  /// **'الـ Dispatchers'**
  String get top_rank_dispatchers;

  /// No description provided for @top_rank_best_representatives.
  ///
  /// In ar, this message translates to:
  /// **'أفضل المندوبين'**
  String get top_rank_best_representatives;

  /// No description provided for @top_rank_best_drivers.
  ///
  /// In ar, this message translates to:
  /// **'أفضل السائقين'**
  String get top_rank_best_drivers;

  /// No description provided for @top_rank_best_dispatchers.
  ///
  /// In ar, this message translates to:
  /// **'أفضل الـ Dispatchers'**
  String get top_rank_best_dispatchers;

  /// No description provided for @top_rank_best_representative.
  ///
  /// In ar, this message translates to:
  /// **'أفضل مندوب'**
  String get top_rank_best_representative;

  /// No description provided for @top_rank_best_driver.
  ///
  /// In ar, this message translates to:
  /// **'أفضل سائق'**
  String get top_rank_best_driver;

  /// No description provided for @top_rank_best_dispatcher.
  ///
  /// In ar, this message translates to:
  /// **'أفضل Dispatcher'**
  String get top_rank_best_dispatcher;

  /// No description provided for @top_rank_winner.
  ///
  /// In ar, this message translates to:
  /// **'الفائز'**
  String get top_rank_winner;

  /// No description provided for @top_rank_delivery.
  ///
  /// In ar, this message translates to:
  /// **'التسليم'**
  String get top_rank_delivery;

  /// No description provided for @top_rank_collection.
  ///
  /// In ar, this message translates to:
  /// **'التحصيل'**
  String get top_rank_collection;

  /// No description provided for @top_rank_extra_sales.
  ///
  /// In ar, this message translates to:
  /// **'Extra Sales'**
  String get top_rank_extra_sales;

  /// No description provided for @top_rank_view_details.
  ///
  /// In ar, this message translates to:
  /// **'عرض التفاصيل'**
  String get top_rank_view_details;

  /// No description provided for @top_rank_unqualified.
  ///
  /// In ar, this message translates to:
  /// **'غير مؤهل للترتيب بعد'**
  String get top_rank_unqualified;

  /// No description provided for @top_rank_empty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج لهذه الفلاتر حالياً'**
  String get top_rank_empty;

  /// No description provided for @top_rank_score.
  ///
  /// In ar, this message translates to:
  /// **'النتيجة'**
  String get top_rank_score;

  /// No description provided for @top_rank_position.
  ///
  /// In ar, this message translates to:
  /// **'الترتيب'**
  String get top_rank_position;

  /// No description provided for @top_rank_movement.
  ///
  /// In ar, this message translates to:
  /// **'تغير الترتيب'**
  String get top_rank_movement;

  /// No description provided for @top_rank_unchanged.
  ///
  /// In ar, this message translates to:
  /// **'بدون تغيير'**
  String get top_rank_unchanged;

  /// No description provided for @top_rank_moved_up.
  ///
  /// In ar, this message translates to:
  /// **'صعد {count} مركز'**
  String top_rank_moved_up(int count);

  /// No description provided for @top_rank_moved_down.
  ///
  /// In ar, this message translates to:
  /// **'تراجع {count} مركز'**
  String top_rank_moved_down(int count);

  /// No description provided for @delivery_order_title.
  ///
  /// In ar, this message translates to:
  /// **'تسليم الطلب'**
  String get delivery_order_title;

  /// No description provided for @delivery_item_code.
  ///
  /// In ar, this message translates to:
  /// **'كود الصنف'**
  String get delivery_item_code;

  /// No description provided for @delivery_ordered_quantity.
  ///
  /// In ar, this message translates to:
  /// **'المطلوب في الأوردر'**
  String get delivery_ordered_quantity;

  /// No description provided for @delivery_vehicle_available.
  ///
  /// In ar, this message translates to:
  /// **'المتاح في العربية'**
  String get delivery_vehicle_available;

  /// No description provided for @delivery_insufficient_stock.
  ///
  /// In ar, this message translates to:
  /// **'المتاح بالعربية أقل من الكمية المطلوبة'**
  String get delivery_insufficient_stock;

  /// No description provided for @delivery_selected_quantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المسلمة'**
  String get delivery_selected_quantity;

  /// No description provided for @delivery_ordered.
  ///
  /// In ar, this message translates to:
  /// **'المطلوب'**
  String get delivery_ordered;

  /// No description provided for @delivery_selected.
  ///
  /// In ar, this message translates to:
  /// **'المختار'**
  String get delivery_selected;

  /// No description provided for @delivery_not_delivered.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تسليم'**
  String get delivery_not_delivered;

  /// No description provided for @delivery_extra_products.
  ///
  /// In ar, this message translates to:
  /// **'منتجات إضافية'**
  String get delivery_extra_products;

  /// No description provided for @delivery_add_extra_product.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منتج إضافي'**
  String get delivery_add_extra_product;

  /// No description provided for @delivery_extra_products_unavailable.
  ///
  /// In ar, this message translates to:
  /// **'إضافة المنتجات الإضافية تحتاج خدمة الرصيد الحالي والتسعير من السيرفر.'**
  String get delivery_extra_products_unavailable;

  /// No description provided for @delivery_selected_items_value.
  ///
  /// In ar, this message translates to:
  /// **'قيمة المنتجات المختارة للتسليم'**
  String get delivery_selected_items_value;

  /// No description provided for @delivery_estimated_total.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي قيمة التسليم التقديرية'**
  String get delivery_estimated_total;

  /// No description provided for @delivery_no_items_selected.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم اختيار كميات للتسليم'**
  String get delivery_no_items_selected;

  /// No description provided for @delivery_partial_draft.
  ///
  /// In ar, this message translates to:
  /// **'تسليم جزئي (مبدئي)'**
  String get delivery_partial_draft;

  /// No description provided for @delivery_full_draft.
  ///
  /// In ar, this message translates to:
  /// **'تسليم كامل (مبدئي)'**
  String get delivery_full_draft;

  /// No description provided for @delivery_auto_calculated.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get delivery_auto_calculated;

  /// No description provided for @delivery_continue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة التسليم'**
  String get delivery_continue;

  /// No description provided for @delivery_review_title.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة التسليم'**
  String get delivery_review_title;

  /// No description provided for @delivery_submission_not_available.
  ///
  /// In ar, this message translates to:
  /// **'الكميات المختارة محفوظة مؤقتًا داخل الشاشة فقط. لم يتم إرسال أو اعتماد التسليم على السيرفر لأن خدمة تنفيذ التسليم لم تُربط بعد.'**
  String get delivery_submission_not_available;

  /// No description provided for @delivery_back_to_edit.
  ///
  /// In ar, this message translates to:
  /// **'رجوع لتعديل الكميات'**
  String get delivery_back_to_edit;

  /// No description provided for @delivery_order_not_pending.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن إعداد تسليم لهذا الطلب لأن حالته ليست في انتظار التسليم.'**
  String get delivery_order_not_pending;

  /// No description provided for @delivery_back_to_details.
  ///
  /// In ar, this message translates to:
  /// **'الرجوع لتفاصيل الطلب'**
  String get delivery_back_to_details;

  /// No description provided for @treasury_subtitle.
  ///
  /// In ar, this message translates to:
  /// **'ما في عهدتك حالياً'**
  String get treasury_subtitle;

  /// No description provided for @treasury_wallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظتي'**
  String get treasury_wallet;

  /// No description provided for @treasury_vehicle_goods.
  ///
  /// In ar, this message translates to:
  /// **'بضاعة العربية'**
  String get treasury_vehicle_goods;

  /// No description provided for @treasury_active_trip.
  ///
  /// In ar, this message translates to:
  /// **'رحلة نشطة'**
  String get treasury_active_trip;

  /// No description provided for @treasury_after_settlement.
  ///
  /// In ar, this message translates to:
  /// **'بعد التسوية'**
  String get treasury_after_settlement;

  /// No description provided for @treasury_no_trip.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رحلة'**
  String get treasury_no_trip;

  /// No description provided for @treasury_current_trip.
  ///
  /// In ar, this message translates to:
  /// **'الرحلة الحالية'**
  String get treasury_current_trip;

  /// No description provided for @treasury_trip_custody.
  ///
  /// In ar, this message translates to:
  /// **'عهدة الرحلة الحالية'**
  String get treasury_trip_custody;

  /// No description provided for @treasury_custody_description.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المبالغ الموجودة في عهدتك خلال الرحلة الحالية'**
  String get treasury_custody_description;

  /// No description provided for @treasury_delivered_total.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي قيمة التسليمات'**
  String get treasury_delivered_total;

  /// No description provided for @treasury_collected_total.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المحصل'**
  String get treasury_collected_total;

  /// No description provided for @treasury_collected_orders.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات المحصلة'**
  String get treasury_collected_orders;

  /// No description provided for @treasury_collection_details.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل التحصيلات'**
  String get treasury_collection_details;

  /// No description provided for @treasury_collected.
  ///
  /// In ar, this message translates to:
  /// **'تم التحصيل'**
  String get treasury_collected;

  /// No description provided for @treasury_delivered_value.
  ///
  /// In ar, this message translates to:
  /// **'قيمة التسليم'**
  String get treasury_delivered_value;

  /// No description provided for @treasury_received_value.
  ///
  /// In ar, this message translates to:
  /// **'استلمت من العميل'**
  String get treasury_received_value;

  /// No description provided for @treasury_cash.
  ///
  /// In ar, this message translates to:
  /// **'كاش'**
  String get treasury_cash;

  /// No description provided for @treasury_insta_pay.
  ///
  /// In ar, this message translates to:
  /// **'InstaPay'**
  String get treasury_insta_pay;

  /// No description provided for @treasury_electronic_wallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظة إلكترونية'**
  String get treasury_electronic_wallet;

  /// No description provided for @treasury_custody_impact.
  ///
  /// In ar, this message translates to:
  /// **'أثر العملية على عهدتي'**
  String get treasury_custody_impact;

  /// No description provided for @treasury_balance_after.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد بعد العملية'**
  String get treasury_balance_after;

  /// No description provided for @treasury_pending_settlement.
  ///
  /// In ar, this message translates to:
  /// **'حالة التسوية: في انتظار الرجوع للمخزن'**
  String get treasury_pending_settlement;

  /// No description provided for @treasury_current_custody.
  ///
  /// In ar, this message translates to:
  /// **'العهدة الحالية'**
  String get treasury_current_custody;

  /// No description provided for @treasury_settlement_hint.
  ///
  /// In ar, this message translates to:
  /// **'العهدة تصفر فقط بعد تأكيد المخزن استلام المبلغ.'**
  String get treasury_settlement_hint;

  /// No description provided for @treasury_settled.
  ///
  /// In ar, this message translates to:
  /// **'تمت التسوية وتأكيد استلام المخزن'**
  String get treasury_settled;

  /// No description provided for @treasury_settled_hint.
  ///
  /// In ar, this message translates to:
  /// **'تم تأكيد استلام المبلغ بالمخزن. لا توجد عهدة مالية حالياً.'**
  String get treasury_settled_hint;

  /// No description provided for @treasury_no_active_trip.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رحلة نشطة حالياً'**
  String get treasury_no_active_trip;

  /// No description provided for @treasury_no_custody.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عهدة مالية حالياً'**
  String get treasury_no_custody;

  /// No description provided for @treasury_balance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد'**
  String get treasury_balance;

  /// No description provided for @treasury_current_goods.
  ///
  /// In ar, this message translates to:
  /// **'البضاعة الموجودة بالعربية حالياً'**
  String get treasury_current_goods;

  /// No description provided for @treasury_vehicle.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get treasury_vehicle;

  /// No description provided for @treasury_remaining_units.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الأصناف المتبقية'**
  String get treasury_remaining_units;

  /// No description provided for @treasury_product_search.
  ///
  /// In ar, this message translates to:
  /// **'بحث عن منتج'**
  String get treasury_product_search;

  /// No description provided for @treasury_product_unit.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة'**
  String get treasury_product_unit;

  /// No description provided for @treasury_trip_order_goods.
  ///
  /// In ar, this message translates to:
  /// **'من طلبات الرحلة'**
  String get treasury_trip_order_goods;

  /// No description provided for @treasury_extra_product.
  ///
  /// In ar, this message translates to:
  /// **'منتج إضافي'**
  String get treasury_extra_product;

  /// No description provided for @treasury_loaded.
  ///
  /// In ar, this message translates to:
  /// **'تم تحميل'**
  String get treasury_loaded;

  /// No description provided for @treasury_delivered.
  ///
  /// In ar, this message translates to:
  /// **'تم تسليم'**
  String get treasury_delivered;

  /// No description provided for @treasury_remaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي بالعربية'**
  String get treasury_remaining;

  /// No description provided for @treasury_inventory_read_only.
  ///
  /// In ar, this message translates to:
  /// **'للعرض فقط — لا يمكن تعديل المخزون من هنا'**
  String get treasury_inventory_read_only;

  /// No description provided for @treasury_no_inventory.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بضاعة بالعربية حالياً'**
  String get treasury_no_inventory;

  /// No description provided for @treasury_goods_returned.
  ///
  /// In ar, this message translates to:
  /// **'تمت إعادة البضاعة المتبقية إلى المخزن'**
  String get treasury_goods_returned;

  /// No description provided for @treasury_no_search_results.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات مطابقة للبحث'**
  String get treasury_no_search_results;

  /// No description provided for @treasury_clear_search.
  ///
  /// In ar, this message translates to:
  /// **'مسح البحث'**
  String get treasury_clear_search;

  /// No description provided for @reschedule_order_title.
  ///
  /// In ar, this message translates to:
  /// **'إعادة جدولة الطلب'**
  String get reschedule_order_title;

  /// No description provided for @reschedule_new_date.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ التسليم الجديد *'**
  String get reschedule_new_date;

  /// No description provided for @reschedule_new_time.
  ///
  /// In ar, this message translates to:
  /// **'الوقت المقترح *'**
  String get reschedule_new_time;

  /// No description provided for @reschedule_reason.
  ///
  /// In ar, this message translates to:
  /// **'سبب إعادة الجدولة *'**
  String get reschedule_reason;

  /// No description provided for @reschedule_other_reason_hint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سبب إعادة الجدولة'**
  String get reschedule_other_reason_hint;

  /// No description provided for @reschedule_notes_hint.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get reschedule_notes_hint;

  /// No description provided for @reschedule_notes_not_sent.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظات غير مشمولة في خدمة إعادة الجدولة الحالية.'**
  String get reschedule_notes_not_sent;

  /// No description provided for @reschedule_date_must_be_future.
  ///
  /// In ar, this message translates to:
  /// **'يجب اختيار موعد مستقبلي لإعادة الجدولة.'**
  String get reschedule_date_must_be_future;

  /// No description provided for @reschedule_confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد إعادة الجدولة'**
  String get reschedule_confirm;

  /// No description provided for @reschedule_order_failed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إعادة جدولة الطلب. حاول مرة أخرى.'**
  String get reschedule_order_failed;

  /// No description provided for @reschedule_success_title.
  ///
  /// In ar, this message translates to:
  /// **'تمت إعادة جدولة الطلب'**
  String get reschedule_success_title;

  /// No description provided for @reschedule_new_date_time.
  ///
  /// In ar, this message translates to:
  /// **'الموعد الجديد'**
  String get reschedule_new_date_time;

  /// No description provided for @reschedule_reason_label.
  ///
  /// In ar, this message translates to:
  /// **'السبب'**
  String get reschedule_reason_label;

  /// No description provided for @reschedule_no_delivery_recorded.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تسجيل كميات مسلّمة أو تحصيل لهذا الطلب من خلال عملية إعادة الجدولة.'**
  String get reschedule_no_delivery_recorded;

  /// No description provided for @reschedule_next_order.
  ///
  /// In ar, this message translates to:
  /// **'الطلب التالي'**
  String get reschedule_next_order;

  /// No description provided for @cancel_delivery_title.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء التسليم'**
  String get cancel_delivery_title;

  /// No description provided for @cancel_delivery_reason_required.
  ///
  /// In ar, this message translates to:
  /// **'سبب الإلغاء *'**
  String get cancel_delivery_reason_required;

  /// No description provided for @cancel_reason_customer_refused.
  ///
  /// In ar, this message translates to:
  /// **'العميل رفض الطلب'**
  String get cancel_reason_customer_refused;

  /// No description provided for @cancel_reason_customer_requested.
  ///
  /// In ar, this message translates to:
  /// **'العميل طلب الإلغاء'**
  String get cancel_reason_customer_requested;

  /// No description provided for @cancel_reason_shop_closed.
  ///
  /// In ar, this message translates to:
  /// **'المحل مغلق'**
  String get cancel_reason_shop_closed;

  /// No description provided for @cancel_reason_cannot_contact.
  ///
  /// In ar, this message translates to:
  /// **'تعذر التواصل مع العميل'**
  String get cancel_reason_cannot_contact;

  /// No description provided for @cancel_reason_wrong_address.
  ///
  /// In ar, this message translates to:
  /// **'عنوان غير صحيح'**
  String get cancel_reason_wrong_address;

  /// No description provided for @cancel_reason_duplicate_order.
  ///
  /// In ar, this message translates to:
  /// **'طلب مكرر'**
  String get cancel_reason_duplicate_order;

  /// No description provided for @cancel_reason_other.
  ///
  /// In ar, this message translates to:
  /// **'سبب آخر'**
  String get cancel_reason_other;

  /// No description provided for @cancel_delivery_other_reason_hint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سبب الإلغاء'**
  String get cancel_delivery_other_reason_hint;

  /// No description provided for @cancel_delivery_notes_hint.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get cancel_delivery_notes_hint;

  /// No description provided for @cancel_delivery_notes_not_sent.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظات غير مشمولة في خدمة إلغاء التسليم الحالية.'**
  String get cancel_delivery_notes_not_sent;

  /// No description provided for @cancel_delivery_confirm_button.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد إلغاء التسليم'**
  String get cancel_delivery_confirm_button;

  /// No description provided for @cancel_delivery_confirm_title.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد إلغاء التسليم؟'**
  String get cancel_delivery_confirm_title;

  /// No description provided for @cancel_delivery_confirm_description.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تسجيل إلغاء التسليم للطلب'**
  String get cancel_delivery_confirm_description;

  /// No description provided for @cancel_delivery_reason_label.
  ///
  /// In ar, this message translates to:
  /// **'السبب'**
  String get cancel_delivery_reason_label;

  /// No description provided for @cancel_delivery_yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم، إلغاء التسليم'**
  String get cancel_delivery_yes;

  /// No description provided for @cancel_delivery_failed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إلغاء التسليم. حاول مرة أخرى.'**
  String get cancel_delivery_failed;

  /// No description provided for @cancel_delivery_success_title.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل إلغاء التسليم'**
  String get cancel_delivery_success_title;

  /// No description provided for @cancel_delivery_success_description.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم إرسال كميات مسلّمة أو مبالغ محصلة ضمن عملية الإلغاء.'**
  String get cancel_delivery_success_description;

  /// No description provided for @cancel_delivery_next_order.
  ///
  /// In ar, this message translates to:
  /// **'الطلب التالي'**
  String get cancel_delivery_next_order;

  /// No description provided for @cancel_delivery_next_order_failed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل الطلب التالي. حاول مرة أخرى.'**
  String get cancel_delivery_next_order_failed;

  /// No description provided for @order_delivery_phone.
  ///
  /// In ar, this message translates to:
  /// **'رقم هاتف المحل'**
  String get order_delivery_phone;

  /// No description provided for @order_delivery_city.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get order_delivery_city;

  /// No description provided for @order_delivery_city_hint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسم المدينة'**
  String get order_delivery_city_hint;

  /// No description provided for @order_delivery_country.
  ///
  /// In ar, this message translates to:
  /// **'الدولة'**
  String get order_delivery_country;
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
