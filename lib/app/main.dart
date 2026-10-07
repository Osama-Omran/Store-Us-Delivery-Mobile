import 'package:flutter/material.dart';
import 'package:storeus_delivery/app/app_builder.dart';
import 'package:storeus_delivery/core/helpers/functions/initializer.dart';
import 'package:storeus_delivery/core/helpers/utils/logger.dart';

Future<void> main() async {
  try {
    await Initializer.initializeServices();
  } catch (e, stackTrace) {
    CustomLogger.logger?.e(
      'Error When Initializing Services: $e',
      error: e,
      stackTrace: stackTrace,
    );
  }
  runApp(const AppBuilder());
}
