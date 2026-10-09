import 'package:dio/dio.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/app_router.dart';
import 'api_error_model.dart';

enum DataSource {
  noContent,
  badRequest,
  forbidden,
  unauthorized,
  notFound,
  internalServerError,
  connectTimeout,
  cancel,
  receiveTimeout,
  sendTimeout,
  cacheError,
  noInternetConnection,
  defaultError,
}

class ResponseMessage {
  static const String noContent = ApiErrors.noContent;
  static const String badRequest = ApiErrors.badRequestError;
  static const String unauthorized = ApiErrors.unauthorizedError;
  static const String forbidden = ApiErrors.forbiddenError;
  static const String internalServerError = ApiErrors.internalServerError;
  static const String notFound = ApiErrors.notFoundError;

  // local status messages
  static String connectTimeout = ApiErrors.timeoutError;
  static String cancel = ApiErrors.defaultError;
  static String receiveTimeout = ApiErrors.timeoutError;
  static String sendTimeout = ApiErrors.timeoutError;
  static String cacheError = ApiErrors.cacheError;
  static String noInternetConnection = ApiErrors.noInternetError;
  static String defaultError = ApiErrors.defaultError;
}

extension DataSourceExtension on DataSource {
  ApiErrorModel getFailure() {
    Map<String, List<String>> errorMap(String message) => {
      'general': [message],
    };

    switch (this) {
      case DataSource.noContent:
        return ApiErrorModel(
          message: ResponseMessage.noContent,
          errors: errorMap(ResponseMessage.noContent),
        );
      case DataSource.badRequest:
        return ApiErrorModel(
          message: ResponseMessage.badRequest,
          errors: errorMap(ResponseMessage.badRequest),
        );
      case DataSource.forbidden:
        return ApiErrorModel(
          message: ResponseMessage.forbidden,
          errors: errorMap(ResponseMessage.forbidden),
        );
      case DataSource.unauthorized:
        return ApiErrorModel(
          message: ResponseMessage.unauthorized,
          errors: errorMap(ResponseMessage.unauthorized),
        );
      case DataSource.notFound:
        return ApiErrorModel(
          message: ResponseMessage.notFound,
          errors: errorMap(ResponseMessage.notFound),
        );
      case DataSource.internalServerError:
        return ApiErrorModel(
          message: ResponseMessage.internalServerError,
          errors: errorMap(ResponseMessage.internalServerError),
        );
      case DataSource.connectTimeout:
        return ApiErrorModel(
          message: ResponseMessage.connectTimeout,
          errors: errorMap(ResponseMessage.connectTimeout),
        );
      case DataSource.cancel:
        return ApiErrorModel(
          message: ResponseMessage.cancel,
          errors: errorMap(ResponseMessage.cancel),
        );
      case DataSource.receiveTimeout:
        return ApiErrorModel(
          message: ResponseMessage.receiveTimeout,
          errors: errorMap(ResponseMessage.receiveTimeout),
        );
      case DataSource.sendTimeout:
        return ApiErrorModel(
          message: ResponseMessage.sendTimeout,
          errors: errorMap(ResponseMessage.sendTimeout),
        );
      case DataSource.cacheError:
        return ApiErrorModel(
          message: ResponseMessage.cacheError,
          errors: errorMap(ResponseMessage.cacheError),
        );
      case DataSource.noInternetConnection:
        return ApiErrorModel(
          message: ResponseMessage.noInternetConnection,
          errors: errorMap(ResponseMessage.noInternetConnection),
        );
      case DataSource.defaultError:
        return ApiErrorModel(
          message: ResponseMessage.defaultError,
          errors: errorMap(ResponseMessage.defaultError),
        );
    }
  }
}

class ErrorHandler implements Exception {
  late ApiErrorModel apiErrorModel;

  ErrorHandler.handle(dynamic error) {
    if (error is DioException) {
      apiErrorModel = _handleError(error);
    } else {
      apiErrorModel = DataSource.defaultError.getFailure();
    }
  }
}

ApiErrorModel _handleError(DioException error) {
  final data = error.response?.data;
  final statusCode = error.response?.statusCode;

  // Any 5xx error
  if (statusCode != null && statusCode >= 500 && statusCode < 600) {
    return ApiErrorModel(
      message: navigatorKey
          .currentContext!
          .strings
          .an_error_occurred_try_again_later,
      errors: {
        'general': [
          navigatorKey
              .currentContext!
              .strings
              .an_error_occurred_try_again_later,
        ],
      },
      errorCode: statusCode,
    );
  }

  if (error.type == DioExceptionType.badResponse ||
      error.type == DioExceptionType.unknown) {
    if (data != null) {
      try {
        if (data is Map<String, dynamic>) {
          if (data['errors'] != null && data['errors'] is Map) {
            final Map<String, List<String>> errorMap = {};
            (data['errors'] as Map<String, dynamic>).forEach((key, value) {
              if (value is List) {
                errorMap[key] = value.map((e) => e.toString()).toList();
              } else {
                errorMap[key] = [value.toString()];
              }
            });
            return ApiErrorModel(
              message: data['message']?.toString() ?? 'Unknown error',
              errors: errorMap,
              errorCode: data['status'] as int?,
            );
          } else {
            return ApiErrorModel(
              message: data['message']?.toString() ?? 'Unknown error',
              errors: {
                'general': [data['message']?.toString() ?? 'Unknown error'],
              },
              errorCode: data['status'] as int?,
            );
          }
        } else if (data is String) {
          return ApiErrorModel(
            message: data,
            errors: {
              'general': [data],
            },
          );
        } else {
          return DataSource.defaultError.getFailure();
        }
      } catch (_) {
        return DataSource.defaultError.getFailure();
      }
    } else {
      return DataSource.defaultError.getFailure();
    }
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      return DataSource.connectTimeout.getFailure();
    case DioExceptionType.sendTimeout:
      return DataSource.sendTimeout.getFailure();
    case DioExceptionType.receiveTimeout:
      return DataSource.receiveTimeout.getFailure();
    case DioExceptionType.cancel:
      return DataSource.cancel.getFailure();
    case DioExceptionType.connectionError:
      return DataSource.defaultError.getFailure();
    case DioExceptionType.badCertificate:
      return DataSource.defaultError.getFailure();
    default:
      return DataSource.defaultError.getFailure();
  }
}

class ApiInternalStatus {
  static const int success = 0;
  static const int failure = 1;
}

class ApiErrors {
  static const String badRequestError = "badRequestError";
  static const String noContent = "noContent";
  static const String forbiddenError = "forbiddenError";
  static const String unauthorizedError = "unauthorizedError";
  static const String notFoundError = "notFoundError";
  static const String conflictError = "conflictError";
  static const String internalServerError = "internalServerError";
  static const String unknownError = "unknownError";
  static String timeoutError =
      navigatorKey.currentContext!.strings.no_internet_please_try_again;
  static String defaultError =
      navigatorKey.currentContext!.strings.no_internet_please_try_again;
  static const String cacheError = "cacheError";
  static String noInternetError =
      navigatorKey.currentContext!.strings.no_internet_please_try_again;
  static const String loadingMessage = "loading_message";
  static const String retryAgainMessage = "retry_again_message";
  static const String ok = "Ok";
}
