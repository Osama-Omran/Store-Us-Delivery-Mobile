import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:storeus_delivery/app/app_builder.dart';
import 'package:storeus_delivery/core/helpers/functions/initializer.dart';
import 'package:storeus_delivery/core/helpers/utils/logger.dart';

Future<void> main() async {
  final startupWatch = Stopwatch()..start();
  var servicesInitialized = false;

  try {
    await Initializer.initializeServices();
    servicesInitialized = true;
  } catch (e, stackTrace) {
    CustomLogger.logger?.e(
      'Error When Initializing Services: $e',
      error: e,
      stackTrace: stackTrace,
    );
  }

  if (kDebugMode) {
    debugPrint(
      '[STARTUP] Before runApp: '
          '${startupWatch.elapsedMilliseconds}ms',
    );
  }

  runApp(const AppBuilder());

  if (kDebugMode) {
    unawaited(
      WidgetsBinding.instance.waitUntilFirstFrameRasterized.then((_) {
        debugPrint(
          '[STARTUP] First Flutter frame: '
              '${startupWatch.elapsedMilliseconds}ms',
        );
      }),
    );
  }

  if (servicesInitialized) {
    unawaited(Initializer.initializeDeferredServices());
  }
}
