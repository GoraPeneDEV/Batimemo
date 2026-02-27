import 'package:dio/dio.dart';
import 'package:nb_utils/nb_utils.dart';

/// Interceptor to check network availability
class NetworkInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!await isNetworkAvailable()) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'No internet connection',
          type: DioExceptionType.connectionError,
        ),
      );
      return;
    }
    super.onRequest(options, handler);
  }
}