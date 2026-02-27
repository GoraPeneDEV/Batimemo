/// Custom exceptions for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}

/// Network connection exception
class NetworkException extends ApiException {
  NetworkException({String message = 'No internet connection'})
      : super(message: message);
}

/// Request timeout exception
class TimeoutException extends ApiException {
  TimeoutException({String message = 'Request timeout'})
      : super(message: message);
}

/// Unauthorized access exception
class UnauthorizedException extends ApiException {
  UnauthorizedException({String message = 'Unauthorized access'})
      : super(message: message, statusCode: 401);
}

/// Resource not found exception
class NotFoundException extends ApiException {
  NotFoundException({String message = 'Resource not found'})
      : super(message: message, statusCode: 404);
}

/// Validation error exception
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException({
    String message = 'Validation failed',
    this.errors,
  }) : super(message: message, statusCode: 422, data: errors);

  /// Get validation error for a specific field
  String? getFieldError(String field) {
    if (errors == null) return null;

    if (errors!.containsKey(field)) {
      final fieldError = errors![field];
      if (fieldError is List && fieldError.isNotEmpty) {
        return fieldError.first.toString();
      }
      return fieldError.toString();
    }
    return null;
  }

  /// Get all validation errors as a list
  List<String> getAllErrors() {
    if (errors == null) return [];

    List<String> errorList = [];
    errors!.forEach((key, value) {
      if (value is List) {
        errorList.addAll(value.map((e) => e.toString()));
      } else {
        errorList.add(value.toString());
      }
    });
    return errorList;
  }
}

/// Server error exception
class ServerException extends ApiException {
  ServerException({String message = 'Server error'})
      : super(message: message, statusCode: 500);
}

/// Bad request exception
class BadRequestException extends ApiException {
  BadRequestException({String message = 'Bad request'})
      : super(message: message, statusCode: 400);
}

/// Forbidden access exception
class ForbiddenException extends ApiException {
  ForbiddenException({String message = 'Forbidden access'})
      : super(message: message, statusCode: 403);
}