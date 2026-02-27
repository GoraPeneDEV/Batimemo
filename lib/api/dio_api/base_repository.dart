import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dio_client.dart';
import 'exceptions/api_exceptions.dart';
import '../../models/api_response_model.dart';

/// Base repository class for all API repositories
/// Extend this class for new feature implementations
abstract class BaseRepository {
  late final DioApiClient _dioClient;

  BaseRepository() {
    _dioClient = DioApiClient();
  }

  DioApiClient get dioClient => _dioClient;

  /// Safe API call with automatic error handling
  /// Returns parsed data of type T
  Future<T> safeApiCall<T>(
    Future<Response> Function() apiCall, {
    T Function(dynamic)? parser,
    bool showError = true,
  }) async {
    try {
      final response = await apiCall();

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (parser != null) {
          return parser(response.data);
        }
        return response.data as T;
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on ApiException {
      rethrow; // Re-throw ApiException without wrapping
    } catch (e) {
      if (kDebugMode) print('Unexpected error in safeApiCall: $e');
      throw ApiException(message: 'An unexpected error occurred');
    }
  }

  /// Safe API call that returns ApiResponseModel
  Future<ApiResponseModel?> safeApiCallWithResponse(
    Future<Response> Function() apiCall, {
    bool showError = true,
  }) async {
    try {
      final response = await apiCall();

      if (response.data != null) {
        return ApiResponseModel.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (showError) {
        throw _handleDioError(e);
      }
      return null;
    } on ApiException {
      rethrow; // Re-throw ApiException without wrapping
    } catch (e) {
      if (kDebugMode) print('Unexpected error: $e');
      if (showError) {
        throw ApiException(message: 'An unexpected error occurred');
      }
      return null;
    }
  }

  /// Safe API call for list responses
  Future<List<T>> safeApiCallList<T>(
    Future<Response> Function() apiCall, {
    required T Function(Map<String, dynamic>) itemParser,
    bool showError = true,
  }) async {
    try {
      final response = await apiCall();

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is List) {
          return (response.data as List)
              .map((item) => itemParser(item))
              .toList();
        }
        return [];
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      if (showError) {
        throw _handleDioError(e);
      }
      return [];
    } on ApiException {
      rethrow; // Re-throw ApiException without wrapping
    } catch (e) {
      if (kDebugMode) print('Unexpected error in safeApiCallList: $e');
      if (showError) {
        throw ApiException(message: 'An unexpected error occurred');
      }
      return [];
    }
  }

  /// Handle error responses
  ApiException _handleErrorResponse(Response response) {
    switch (response.statusCode) {
      case 400:
        return BadRequestException(
          message: _extractMessage(response.data) ?? 'Bad request',
        );
      case 401:
        return UnauthorizedException();
      case 403:
        return ForbiddenException();
      case 404:
        return NotFoundException();
      case 422:
        return ValidationException(
          message: _extractMessage(response.data) ?? 'Validation failed',
          errors: _extractErrors(response.data),
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message: _extractMessage(response.data) ?? 'Server error',
        );
      default:
        return ApiException(
          message: _extractMessage(response.data) ?? 'Something went wrong',
          statusCode: response.statusCode,
          data: response.data,
        );
    }
  }

  /// Handle Dio errors
  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();
      case DioExceptionType.connectionError:
        return NetworkException();
      case DioExceptionType.badResponse:
        if (error.response != null) {
          return _handleErrorResponse(error.response!);
        }
        return ApiException(message: 'Bad response from server');
      case DioExceptionType.cancel:
        return ApiException(message: 'Request cancelled');
      default:
        return ApiException(
          message: error.message ?? 'Unknown error occurred',
        );
    }
  }

  /// Extract error message from response
  String? _extractMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      // Check for message field
      if (data.containsKey('message')) {
        return data['message']?.toString();
      }
      // Check for error field
      if (data.containsKey('error')) {
        return data['error']?.toString();
      }
      // Check for data field (API sometimes returns error message in data)
      if (data.containsKey('data') && data['data'] is String) {
        return data['data']?.toString();
      }
    }

    if (data is String) {
      return data;
    }

    return null;
  }

  /// Extract validation errors from response
  Map<String, dynamic>? _extractErrors(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic> && data.containsKey('errors')) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        return errors;
      }
    }

    return null;
  }
}