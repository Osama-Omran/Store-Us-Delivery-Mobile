import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storeus_delivery/core/helpers/apis/dio/dio_factory.dart';
import 'package:storeus_delivery/core/helpers/localization/l10n.dart';

class LocaleCubit extends Cubit<Locale> {
  static LocaleCubit get(BuildContext context) => BlocProvider.of(context);
  LocaleCubit()
    : super(() {
        final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;

        return L10n.all.any(
              (locale) => locale.languageCode == deviceLocale.languageCode,
            )
            ? Locale(deviceLocale.languageCode)
            : const Locale('ar');
      }()) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString('locale');

    if (localeCode != null) {
      emit(Locale(localeCode));
    } else {
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;

      final supported = L10n.all.any(
        (locale) => locale.languageCode == deviceLocale.languageCode,
      );

      emit(supported ? Locale(deviceLocale.languageCode) : const Locale('ar'));
    }
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
    DioFactory.updateLanguageHeader(locale.languageCode);
    emit(locale);
  }

  void toArabic() => setLocale(const Locale('ar'));
}
