import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor to handle errors globally
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = _getErrorMessage(err);

    if (kDebugMode) {
      print('API Error: $errorMessage');
      print('Error Type: ${err.type}');
      print('Response: ${err.response?.data}');
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Connection timeout. Please try again.';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'No internet connection';
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled';
        break;
      case DioExceptionType.badCertificate:
        errorMessage = 'Bad certificate';
        break;
      case DioExceptionType.badResponse:
        errorMessage = _handleStatusCode(err.response);
        break;
      case DioExceptionType.unknown:
        errorMessage = 'Something went wrong. Please try again.';
        break;
    }

    err = err.copyWith(message: errorMessage);
    super.onError(err, handler);
  }

  String _handleStatusCode(Response? response) {
    if (response == null) return 'Unknown error';

    String errorMessage = 'Something went wrong';

    switch (response.statusCode) {
      case 400:
        errorMessage = _extractServerMessage(response.data) ??
            'Bad request. Please check your input.';
        break;
      case 401:
        errorMessage = 'Session expired. Please login again.';
        break;
      case 403:
        errorMessage = 'You do not have permission to perform this action.';
        break;
      case 404:
        errorMessage = 'Resource not found.';
        break;
      case 422:
        errorMessage = _extractServerMessage(response.data) ??
            'Validation failed. Please check your input.';
        break;
      case 500:
      case 502:
      case 503:
      case 504:
        errorMessage = 'Server error. Please try again later.';
        break;
      default:
        errorMessage = _extractServerMessage(response.data) ??
            'Error occurred (${response.statusCode})';
    }

    return errorMessage;
  }

  String _getErrorMessage(DioException err) {
    if (err.message != null && err.message!.isNotEmpty) {
      return err.message!;
    }
    return 'Something went wrong';
  }

  String? _extractServerMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      // Check for message field
      if (data.containsKey('message')) {
        return data['message'].toString();
      }
      // Check for error field
      if (data.containsKey('error')) {
        return data['error'].toString();
      }
      // Check for errors field (validation errors)
      if (data.containsKey('errors')) {
        final errors = data['errors'];
        if (errors is Map) {
          // Return first error message
          return errors.values.first.toString();
        }
        return errors.toString();
      }
    }

    if (data is String) {
      return data;
    }

    return null;
  }
}