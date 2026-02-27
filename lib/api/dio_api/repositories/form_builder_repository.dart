import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../base_repository.dart';
import '../../../models/FormBuilder/assigned_forms_response_model.dart';
import '../../../models/FormBuilder/assigned_form_model.dart';

/// Repository for Form Builder API using Dio architecture
/// Handles form assignments and submissions
class FormBuilderRepository extends BaseRepository {
  static final FormBuilderRepository _instance =
      FormBuilderRepository._internal();

  factory FormBuilderRepository() {
    return _instance;
  }

  FormBuilderRepository._internal();

  /// Get assigned forms with pagination and optional status filter
  ///
  /// Parameters:
  /// - [skip]: Number of records to skip (default: 0)
  /// - [take]: Number of records to take (default: 10)
  /// - [status]: Filter by status - 'pending', 'submitted', or 'overdue' (optional)
  /// - [cancelToken]: Token to cancel the request
  ///
  /// Returns: [AssignedFormsResponseModel] containing forms and total count
  ///
  /// Throws:
  /// - [UnauthorizedException] (401): User is not authenticated
  /// - [NotFoundException] (404): No forms found
  /// - [NetworkException]: No internet connection
  /// - [TimeoutException]: Request timeout
  Future<AssignedFormsResponseModel?> getAssignedForms({
    int skip = 0,
    int take = 10,
    String? status,
    CancelToken? cancelToken,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'skip': skip,
        'take': take,
      };

      // Add status filter if provided
      if (status != null && status.isNotEmpty) {
        // Validate status values
        if (!['pending', 'submitted', 'overdue'].contains(status.toLowerCase())) {
          if (kDebugMode) {
            print('Invalid status value: $status. Must be pending, submitted, or overdue');
          }
        } else {
          queryParams['status'] = status;
        }
      }

      final response = await safeApiCall<Map<String, dynamic>>(
        () => dioClient.get(
          'forms/getAssignedForms',
          queryParameters: queryParams,
          cancelToken: cancelToken,
        ),
      );

      if (response['data'] != null) {
        return AssignedFormsResponseModel.fromJson(
          response['data'] as Map<String, dynamic>,
        );
      }

      if (kDebugMode) {
        print('No data in response for getAssignedForms');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting assigned forms: $e');
      }
      rethrow;
    }
  }

  /// Submit a form with form data
  ///
  /// Parameters:
  /// - [assignmentId]: The assignment ID of the form to submit
  /// - [formData]: Map containing form field data (key: field ID, value: field value)
  ///   - Supports file uploads: Use MultipartFile for file fields
  /// - [cancelToken]: Token to cancel the request
  /// - [onSendProgress]: Callback for upload progress (useful for file uploads)
  ///
  /// Returns: Success message as [String]
  ///
  /// Throws:
  /// - [UnauthorizedException] (401): User is not authenticated
  /// - [NotFoundException] (404): Assignment not found
  /// - [BadRequestException] (400): Already submitted, form inactive, or form expired
  /// - [ValidationException] (422): Validation errors in form data
  /// - [NetworkException]: No internet connection
  /// - [TimeoutException]: Request timeout
  ///
  /// Example:
  /// ```dart
  /// // For text/number fields
  /// final formData = {
  ///   'field_1': 'John Doe',
  ///   'field_2': 25,
  /// };
  ///
  /// // For file uploads
  /// final formDataWithFile = {
  ///   'field_1': 'John Doe',
  ///   'field_file': await MultipartFile.fromFile('/path/to/file.pdf'),
  /// };
  /// ```
  Future<String?> submitForm({
    required int assignmentId,
    required Map<String, dynamic> formData,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      // Check if formData contains files
      final hasFiles = formData.values.any((value) => value is MultipartFile);

      dynamic requestData;
      Options? options;

      if (hasFiles) {
        // Use FormData for multipart/form-data (file uploads)
        final formDataObj = FormData();

        // Add assignment ID
        formDataObj.fields.add(MapEntry('assignmentId', assignmentId.toString()));

        // Add form fields
        formData.forEach((key, value) {
          if (value is MultipartFile) {
            formDataObj.files.add(MapEntry(key, value));
          } else {
            formDataObj.fields.add(MapEntry(key, value.toString()));
          }
        });

        requestData = formDataObj;
        options = Options(
          contentType: 'multipart/form-data',
        );

        if (kDebugMode) {
          print('Submitting form with files - Assignment ID: $assignmentId');
        }
      } else {
        // Use JSON for regular form data
        requestData = {
          'assignmentId': assignmentId,
          'formData': formData,
        };

        if (kDebugMode) {
          print('Submitting form with JSON - Assignment ID: $assignmentId');
        }
      }

      final response = await safeApiCall<Map<String, dynamic>>(
        () => dioClient.post(
          'forms/submitForm',
          data: requestData,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
        ),
      );

      if (response['message'] != null) {
        if (kDebugMode) {
          print('Form submitted successfully: ${response['message']}');
        }
        return response['message'] as String;
      }

      if (kDebugMode) {
        print('Form submitted but no message in response');
      }
      return 'Form submitted successfully';
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting form: $e');
      }
      rethrow;
    }
  }

  /// Get form details by assignment ID
  ///
  /// Parameters:
  /// - [assignmentId]: The assignment ID
  /// - [cancelToken]: Token to cancel the request
  ///
  /// Returns: [AssignedFormModel] with form details
  ///
  /// Throws:
  /// - [UnauthorizedException] (401): User is not authenticated
  /// - [NotFoundException] (404): Assignment not found
  Future<AssignedFormModel?> getFormByAssignmentId({
    required int assignmentId,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await safeApiCall<Map<String, dynamic>>(
        () => dioClient.get(
          'forms/getFormByAssignment/$assignmentId',
          cancelToken: cancelToken,
        ),
      );

      if (response['data'] != null) {
        return AssignedFormModel.fromJson(
          response['data'] as Map<String, dynamic>,
        );
      }

      if (kDebugMode) {
        print('No data in response for getFormByAssignmentId');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting form by assignment ID: $e');
      }
      rethrow;
    }
  }

  /// Get pending forms count
  ///
  /// Returns: Number of pending forms
  Future<int> getPendingFormsCount({
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await safeApiCall<Map<String, dynamic>>(
        () => dioClient.get(
          'forms/pendingCount',
          cancelToken: cancelToken,
        ),
      );

      if (response['data'] != null && response['data']['count'] != null) {
        return response['data']['count'] as int;
      }

      return 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting pending forms count: $e');
      }
      return 0;
    }
  }

  /// Get overdue forms count
  ///
  /// Returns: Number of overdue forms
  Future<int> getOverdueFormsCount({
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await safeApiCall<Map<String, dynamic>>(
        () => dioClient.get(
          'forms/overdueCount',
          cancelToken: cancelToken,
        ),
      );

      if (response['data'] != null && response['data']['count'] != null) {
        return response['data']['count'] as int;
      }

      return 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting overdue forms count: $e');
      }
      return 0;
    }
  }
}
