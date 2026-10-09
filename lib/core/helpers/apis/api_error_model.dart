import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/routing/app_router.dart';

class ApiErrorModel {
  /// The main message of the error
  final String message;

  /// Detailed errors per field or key
  final Map<String, List<String>>? errors;

  /// Optional error code from API
  final int? errorCode;

  ApiErrorModel({required this.message, this.errorCode, this.errors});

  /// Factory to parse API response
  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    // Parse multi-language message
    final dynamic rawMessage = json['message'];
    String parsedMessage = 'Unknown error';
    try {
      if (rawMessage is Map<String, dynamic>) {
        final currentLang = getCurrentAppLang();
        parsedMessage =
            rawMessage[currentLang] ?? rawMessage['en'] ?? 'Unknown error';
      } else if (rawMessage is String) {
        try {
          final decoded = jsonDecode(rawMessage);
          if (decoded is Map<String, dynamic>) {
            final currentLang = getCurrentAppLang();
            parsedMessage = decoded[currentLang] ?? decoded['en'] ?? rawMessage;
          } else {
            parsedMessage = rawMessage;
          }
        } catch (_) {
          parsedMessage = rawMessage;
        }
      }
    } catch (_) {
      parsedMessage = 'Unknown error';
    }

    // Parse errors as Map<String, List<String>>
    Map<String, List<String>>? errorMap;
    if (json['errors'] != null && json['errors'] is Map) {
      errorMap = (json['errors'] as Map<String, dynamic>).map((key, value) {
        if (value is List) {
          return MapEntry(key, value.map((e) => e.toString()).toList());
        }
        return MapEntry(key, [value.toString()]);
      });
    }

    return ApiErrorModel(
      message: parsedMessage,
      errorCode: json['errorCode'] as int?,
      errors: errorMap,
    );
  }

  /// Convert object to JSON
  Map<String, dynamic> toJson() {
    return {'message': message, 'errorCode': errorCode, 'errors': errors};
  }

  /// Flatten all error messages into a single list
  List<String> getAllErrors() {
    if (errors == null || errors!.isEmpty) return [message];
    return errors!.values.expand((e) => e).toList();
  }
}

/// Helper to get current app language
String getCurrentAppLang() {
  final context = navigatorKey.currentContext;
  if (context != null) {
    return Localizations.localeOf(context).languageCode;
  }
  return 'en';
}
