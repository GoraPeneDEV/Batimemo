import 'package:dio/dio.dart';
import '../base_repository.dart';
import '../../../models/holiday_model.dart';

/// Repository for Holiday API using Dio architecture
class HolidayRepository extends BaseRepository {
  static final HolidayRepository _instance = HolidayRepository._internal();

  factory HolidayRepository() {
    return _instance;
  }

  HolidayRepository._internal();

  /// Get holidays applicable to the authenticated employee
  /// [year] - Filter by year (default: current year)
  Future<HolidayModelResponse?> getMyHolidays({
    int? year,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await safeApiCall<Map<String, dynamic>>(
        () => dioClient.get(
          '/holidays/my-holidays',
          queryParameters: {
            if (year != null) 'year': year,
          },
          cancelToken: cancelToken,
        ),
      );

      if (response['data'] != null) {
        final data = response['data'];
        return HolidayModelResponse(
          totalCount: data['totalCount'] ?? 0,
          values: (data['holidays'] as List?)
                  ?.map((item) => HolidayModel.fromJson(item))
                  .toList() ??
              [],
        );
      }
      return null;
    } catch (e) {
      print('Error getting my holidays: $e');
      return null;
    }
  }

  /// Get upcoming holidays
  /// [limit] - Number of holidays to return (default: 10, max: 50)
  Future<List<HolidayModel>> getUpcomingHolidays({
    int limit = 10,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await safeApiCall<Map<String, dynamic>>(
        () => dioClient.get(
          '/holidays/upcoming',
          queryParameters: {'limit': limit},
          cancelToken: cancelToken,
        ),
      );

      if (response['data'] != null && response['data']['holidays'] != null) {
        return (response['data']['holidays'] as List)
            .map((item) => HolidayModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting upcoming holidays: $e');
      return [];
    }
  }

  /// Get holidays grouped by month
  /// [year] - Filter by year (default: current year)
  Future<Map<String, List<HolidayModel>>?> getHolidaysByYearGrouped({
    int? year,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await safeApiCall<Map<String, dynamic>>(
        () => dioClient.get(
          '/holidays/by-year-grouped',
          queryParameters: {
            if (year != null) 'year': year,
          },
          cancelToken: cancelToken,
        ),
      );

      if (response['data'] != null && response['data']['months'] != null) {
        final monthsData = response['data']['months'] as Map<String, dynamic>;
        final result = <String, List<HolidayModel>>{};

        monthsData.forEach((month, holidays) {
          if (holidays is List) {
            result[month] =
                holidays.map((item) => HolidayModel.fromJson(item)).toList();
          }
        });

        return result;
      }
      return null;
    } catch (e) {
      print('Error getting holidays by year grouped: $e');
      return null;
    }
  }

  /// Get all holidays with filters and pagination
  Future<HolidayModelResponse?> getAllHolidays({
    int skip = 0,
    int take = 10,
    int? year,
    String? type,
    bool? isActive,
    bool? upcoming,
    bool? visibleToEmployees,
    CancelToken? cancelToken,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'skip': skip,
        'take': take,
      };

      if (year != null) queryParams['year'] = year;
      if (type != null) queryParams['type'] = type;
      if (isActive != null) queryParams['is_active'] = isActive ? 1 : 0;
      if (upcoming != null) queryParams['upcoming'] = upcoming ? 1 : 0;
      if (visibleToEmployees != null) {
        queryParams['visible_to_employees'] = visibleToEmployees ? 1 : 0;
      }

      final response = await safeApiCall<Map<String, dynamic>>(
        () => dioClient.get(
          '/holidays/getAll',
          queryParameters: queryParams,
          cancelToken: cancelToken,
        ),
      );

      if (response['data'] != null) {
        final data = response['data'];
        return HolidayModelResponse(
          totalCount: data['totalCount'] ?? 0,
          values: (data['values'] as List?)
                  ?.map((item) => HolidayModel.fromJson(item))
                  .toList() ??
              [],
        );
      }
      return null;
    } catch (e) {
      print('Error getting all holidays: $e');
      return null;
    }
  }

  /// Get holiday details by ID
  Future<HolidayModel?> getHolidayDetails({
    required int id,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await safeApiCall<Map<String, dynamic>>(
        () => dioClient.get(
          '/holidays/$id',
          cancelToken: cancelToken,
        ),
      );

      if (response['data'] != null) {
        return HolidayModel.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error getting holiday details: $e');
      return null;
    }
  }
}
