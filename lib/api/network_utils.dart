import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/api/api_routes.dart';
import 'package:open_core_hr/main.dart';

import '../models/api_response_model.dart';
import '../utils/app_constants.dart';
import 'config.dart';

Map<String, String> buildHeader() {
  String? token = getStringAsync(tokenPref);
  String? tenantId = getStringAsync(tenantPref);

  log('Token: $token');
  if (getIsSaaSMode()) {
    log('X-Tenant-ID: $tenantId');
  }

  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  if (!token.isEmptyOrNull) {
    headers['Authorization'] = 'Bearer $token';
  }

  // Add tenant ID header for SaaS mode
  if (getIsSaaSMode() && !tenantId.isEmptyOrNull) {
    headers['X-Tenant-ID'] = tenantId!;
  }

  return headers;
}

/// Get the API base URL
/// In header-based SaaS mode, always use central URL from APIRoutes.baseURL
/// Tenant is identified via X-Tenant-ID header, not URL
String getBaseUrl() {
  return APIRoutes.baseURL;
}

/// Get the server base URL (without /api/V1/ suffix)
/// Used for WebSocket connections, admin panel links, etc.
String getServerBaseUrl() {
  String baseUrl = APIRoutes.baseURL;
  // Remove /api/V1/ suffix if present
  if (baseUrl.endsWith('/api/V1/')) {
    return baseUrl.substring(0, baseUrl.length - 8);
  } else if (baseUrl.endsWith('/api/V1')) {
    return baseUrl.substring(0, baseUrl.length - 7);
  }
  return baseUrl;
}

Future<Response> postRequest(String endPoint, body) async {
  try {
    endPoint = getBaseUrl() + endPoint;
    if (!await isNetworkAvailable()) throw noInternetMsg;

    log('Request: $endPoint $body');

    Response response = await post(Uri.parse(endPoint),
            body: jsonEncode(body), headers: buildHeader())
        .timeout(const Duration(seconds: timeoutDuration),
            onTimeout: () => throw language.lblPleaseTryAgain);

    log('Response: $endPoint ${response.statusCode} ${response.body}');
    return response;
  } catch (e) {
    log(e);
    if (!await isNetworkAvailable()) {
      throw noInternetMsg;
    } else {
      throw 'Something went wrong';
    }
  }
}

Future<Response> getRequest(String endPoint) async {
  try {
    endPoint = getBaseUrl() + endPoint;
    if (!await isNetworkAvailable()) throw noInternetMsg;

    log('Request: $endPoint ');

    Response response = await get(Uri.parse(endPoint), headers: buildHeader())
        .timeout(const Duration(seconds: timeoutDuration),
            onTimeout: () => throw language.lblPleaseTryAgain);

    log('Response: $endPoint ${response.statusCode} ${response.body}');
    return response;
  } catch (e) {
    log(e);
    if (!await isNetworkAvailable()) {
      throw noInternetMsg;
    } else {
      toast(language.lblPleaseTryAgain);
      throw language.lblPleaseTryAgain;
    }
  }
}

Future<Response> getRequestWithQuery(String endPoint, String query) async {
  try {
    endPoint = getBaseUrl() + endPoint;
    if (!await isNetworkAvailable()) throw noInternetMsg;

    String url = '$endPoint?$query';

    log('Request: $endPoint?$query ');

    Response response = await get(Uri.parse(url), headers: buildHeader())
        .timeout(const Duration(seconds: timeoutDuration),
            onTimeout: () => throw language.lblPleaseTryAgain);

    log('Response: $endPoint?$query ${response.statusCode} ${response.body}');
    return response;
  } catch (e) {
    log(e);
    if (!await isNetworkAvailable()) {
      throw noInternetMsg;
    } else {
      toast(language.lblPleaseTryAgain);
      throw language.lblPleaseTryAgain;
    }
  }
}

Future<bool> multipartRequest(String endPoint, String filePath) async {
  try {
    endPoint = getBaseUrl() + endPoint;
    if (!await isNetworkAvailable()) throw noInternetMsg;

    MultipartRequest request = MultipartRequest('POST', Uri.parse(endPoint));

    MultipartFile file = await MultipartFile.fromPath("file", filePath);

    request.files.add(file);

    request.headers.addAll(buildHeader());

    log("Multipart Request: $request");

    var response = await request.send();

    var responseBody = await response.stream.bytesToString();

    log('"Multipart Response: $endPoint Status ${response.statusCode}} Date: $responseBody');

    return response.statusCode == 200;
  } catch (e) {
    log(e);
    if (!await isNetworkAvailable()) {
      throw noInternetMsg;
    } else {
      toast(language.lblPleaseTryAgain);
      throw language.lblPleaseTryAgain;
    }
  }
}

Future<StreamedResponse> multipartRequestWithData(
    String endPoint, String filePath, Map<String, String> data) async {
  try {
    endPoint = getBaseUrl() + endPoint;
    if (!await isNetworkAvailable()) throw noInternetMsg;

    MultipartRequest request = MultipartRequest('POST', Uri.parse(endPoint));

    request.fields.addAll(data);

    MultipartFile file = await MultipartFile.fromPath("file", filePath);

    request.files.add(file);

    request.headers.addAll(buildHeader());

    log("Multipart Request: $request");

    var response = await request.send();

    log('"Multipart Response: $endPoint Status ${response.statusCode}}');

    return response;
  } catch (e) {
    log(e);
    if (!await isNetworkAvailable()) {
      throw noInternetMsg;
    } else {
      toast(language.lblPleaseTryAgain);
      throw language.lblPleaseTryAgain;
    }
  }
}

Future<ApiResponseModel?> handleResponse(Response response) async {
  if (response.statusCode.isSuccessful()) {
    try {
      var resModel = ApiResponseModel.fromJson(jsonDecode(response.body));
      return resModel;
    } on FormatException catch (e) {
      log('JSON parsing error: $e');
      log('Response body length: ${response.body.length}');
      throw 'Invalid response from server. Please try again.';
    }
  } else if (response.statusCode == 401) {
    sharedHelper.logoutAlt();
    throw ('Please login again');
  } else if (response.statusCode == 400) {
    try {
      var resModel = ApiResponseModel.fromJson(jsonDecode(response.body));
      return resModel;
    } on FormatException catch (e) {
      log('JSON parsing error for 400 response: $e');
      return null;
    }
  } else {
    return null;
  }
}
