import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/utils/app_update_config.dart';
import 'package:storeus_delivery/core/helpers/utils/force_update_services.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/routing/app_router.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import 'package:storeus_delivery/features/splash/presentation/widgets/splash_body.dart';
import 'package:storeus_delivery/features/app_update/presentation/widgets/optional_update_dialog.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.nextRoute});

  final String nextRoute;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatingController;

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);

    _startApplication();
  }

  Future<void> _startApplication() async {
    final minimumSplashDuration = Future<void>.delayed(
      const Duration(seconds: 2),
    );
    final update = await getIt<ForceUpdateServices>().checkForUpdate();
    await minimumSplashDuration;
    if (!mounted) return;

    ForceUpdateServices.startupCheckComplete = true;
    final router = GoRouter.of(context);
    if (update.status == AppUpdateStatus.required) {
      router.go(RoutesNames.forceUpdate);
      return;
    }

    router.go(widget.nextRoute);
    if (update.status != AppUpdateStatus.optional ||
        await getIt<ForceUpdateServices>().isOptionalUpdateDismissed(
          update.latestVersion,
        )) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appContext = navigatorKey.currentContext;
      if (appContext != null && appContext.mounted) {
        showOptionalUpdateDialog(appContext, update);
      }
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.splashNavigationBar,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SplashBody(floatingAnimation: _floatingController),
      ),
    );
  }
}
