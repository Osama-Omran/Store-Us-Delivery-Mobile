import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:storeus_delivery/core/helpers/localization/l10n.dart';
import 'package:storeus_delivery/core/helpers/localization/locale_cubit.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/routing/app_router.dart';
import 'package:storeus_delivery/core/theme/app_theme.dart';

class AppBuilder extends StatelessWidget {
  const AppBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => getIt<LocaleCubit>())],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (_, locale) {
          return OverlaySupport(
            child: MaterialApp.router(
              title: 'Store Us Delivery',
              theme: AppTheme.lightTheme,
              locale: locale,
              supportedLocales: L10n.all,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: AppRouter.routes,
            ),
          );
        },
      ),
    );
  }
}
