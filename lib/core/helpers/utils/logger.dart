import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class CustomLogger {
  static final Logger? logger = kDebugMode
      ? Logger(
          printer: PrettyPrinter(
            colors: true,
            printEmojis: true,
            methodCount: 0,
          ),
        )
      : null;
}
