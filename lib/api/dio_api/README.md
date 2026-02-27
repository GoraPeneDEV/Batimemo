# Dio API Implementation Guide

## Overview

This is the new Dio-based API architecture for Open Core HR. Use this for all NEW feature implementations while keeping existing code untouched.

## Structure

```
lib/api/dio_api/
├── dio_client.dart              # Main Dio client with configuration
├── base_repository.dart         # Base repository class with error handling
├── exceptions/
│   └── api_exceptions.dart      # Custom exception classes
├── interceptors/
│   ├── auth_interceptor.dart    # Authentication handling
│   ├── error_interceptor.dart   # Error handling
│   └── network_interceptor.dart # Network checking
└── repositories/
    ├── example_auth_repository.dart      # Example: Authentication
    └── example_attendance_repository.dart # Example: Attendance
```

## Quick Start

### 1. Simple API Call

```dart
import 'package:open_core_hr/api/dio_api/dio_client.dart';

final client = DioApiClient();
final response = await client.get('endpoint');
```

### 2. Using Repository Pattern (Recommended)

```dart
import 'package:open_core_hr/api/dio_api/base_repository.dart';

class MyFeatureRepository extends BaseRepository {
  Future<MyModel?> getData() async {
    return await safeApiCall(
      () => dioClient.get('my-endpoint'),
      parser: (data) => MyModel.fromJson(data),
    );
  }
}
```

### 3. File Upload with Progress

```dart
await dioClient.uploadFile(
  'upload-endpoint',
  filePath: '/path/to/file',
  onSendProgress: (sent, total) {
    final progress = (sent / total * 100).toStringAsFixed(0);
    print('Upload Progress: $progress%');
  },
);
```

### 4. Handling Errors

```dart
try {
  final data = await repository.getData();
} on NetworkException {
  // No internet
} on ValidationException catch (e) {
  // Show validation errors
  print(e.getAllErrors());
} on UnauthorizedException {
  // Redirect to login
} on ApiException catch (e) {
  // Generic API error
  print(e.message);
}
```

## Features

### ✅ Built-in Features
- Automatic token injection
- Network checking
- Error handling
- Request/response logging (debug mode)
- Progress tracking
- Request cancellation
- Retry logic

### 🚀 Advanced Features

#### Cancel Requests
```dart
final cancelToken = CancelToken();

// Start request
final future = dioClient.get('endpoint', cancelToken: cancelToken);

// Cancel if needed
cancelToken.cancel('User cancelled');
```

#### Pagination
```dart
Future<List<Item>> getItems({int page = 1, int pageSize = 20}) async {
  return await safeApiCallList(
    () => dioClient.get(
      'items',
      queryParameters: {'page': page, 'pageSize': pageSize},
    ),
    itemParser: (item) => Item.fromJson(item),
  );
}
```

#### Multiple File Upload
```dart
await dioClient.uploadMultipleFiles(
  'upload-multiple',
  filePaths: ['/path/file1.jpg', '/path/file2.jpg'],
  data: {'description': 'Multiple files'},
);
```

## Creating New Repositories

### Step 1: Create Repository Class

```dart
import 'package:open_core_hr/api/dio_api/base_repository.dart';
import 'package:open_core_hr/api/api_routes.dart';

class MyNewRepository extends BaseRepository {
  static final MyNewRepository _instance = MyNewRepository._internal();

  factory MyNewRepository() => _instance;

  MyNewRepository._internal();

  // Add your methods here
}
```

### Step 2: Implement Methods

```dart
Future<MyModel?> createItem(Map<String, dynamic> data) async {
  return await safeApiCall(
    () => dioClient.post('items', data: data),
    parser: (data) => MyModel.fromJson(data),
  );
}

Future<List<MyModel>> getItems() async {
  return await safeApiCallList(
    () => dioClient.get('items'),
    itemParser: (item) => MyModel.fromJson(item),
  );
}

Future<bool> deleteItem(String id) async {
  final response = await safeApiCallWithResponse(
    () => dioClient.delete('items/$id'),
  );
  return response?.success == true;
}
```

## Exception Types

| Exception | When to Use |
|-----------|------------|
| `NetworkException` | No internet connection |
| `TimeoutException` | Request timeout |
| `UnauthorizedException` | 401 - Authentication required |
| `ForbiddenException` | 403 - Permission denied |
| `NotFoundException` | 404 - Resource not found |
| `ValidationException` | 422 - Validation errors |
| `BadRequestException` | 400 - Bad request |
| `ServerException` | 500+ - Server errors |
| `ApiException` | Generic API errors |

## Best Practices

### DO ✅
- Use repository pattern for business logic
- Handle specific exceptions
- Use cancel tokens for cancellable operations
- Implement progress callbacks for file operations
- Use type-safe methods with proper models

### DON'T ❌
- Don't use Dio directly in UI code
- Don't ignore error handling
- Don't forget to dispose cancel tokens
- Don't mix old HTTP code with new Dio code

## Migration from Old API

### Old Code (Keep as is):
```dart
// This still works, don't change existing code
var response = await postRequest('login', {'user': 'test'});
var result = await handleResponse(response);
```

### New Code (For new features):
```dart
// Use Dio for new implementations
final authRepo = ExampleAuthRepository();
final user = await authRepo.login(
  username: 'test',
  password: 'password',
);
```

## Testing

```dart
// Test network error handling
when(mockDio.get(any)).thenThrow(
  DioException(
    type: DioExceptionType.connectionError,
    requestOptions: RequestOptions(),
  ),
);

// Test successful response
when(mockDio.get(any)).thenAnswer(
  (_) async => Response(
    data: {'success': true},
    statusCode: 200,
    requestOptions: RequestOptions(),
  ),
);
```

## Debugging

Enable detailed logging in debug mode:
- Request headers ✅
- Request body ✅
- Response body ✅
- Errors ✅

Logs are automatically pretty-printed in debug mode.

## Support

For questions about:
- Old API: See `lib/api/network_utils.dart`
- New API: See examples in `lib/api/dio_api/repositories/`
- Migration: Keep old code, use Dio for new features