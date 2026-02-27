import '../base_repository.dart';
import '../../../models/Loan/loan_type.dart';
import '../../../models/Loan/loan_request_model.dart';
import '../../../models/Loan/loan_detail_model.dart';
import '../../../models/Loan/loan_statistics.dart';
import '../../../models/Loan/loan_history.dart';

class LoanRepository extends BaseRepository {
  /// Get paginated list of loan requests
  /// GET /api/V1/loan/requests
  Future<Map<String, dynamic>> getLoanRequests({
    int skip = 0,
    int take = 10,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'skip': skip,
      'take': take,
    };

    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    return await safeApiCall(
      () => dioClient.get('loan/requests', queryParameters: queryParams),
      parser: (data) {
        return {
          'totalCount': data['data']['totalCount'] ?? 0,
          'values': (data['data']['values'] as List? ?? [])
              .map((item) => LoanRequestModel.fromJson(item))
              .toList(),
        };
      },
    );
  }

  /// Get single loan request details
  /// GET /api/V1/loan/requests/{id}
  Future<LoanDetailResponse?> getLoanRequest(int id) async {
    return await safeApiCall(
      () => dioClient.get('loan/requests/$id'),
      parser: (data) => LoanDetailResponse.fromJson(data['data']),
    );
  }

  /// Create a new loan request
  /// POST /api/V1/loan/requests
  Future<Map<String, dynamic>?> createLoanRequest({
    required int loanTypeId,
    required double amount,
    required int tenureMonths,
    required String purpose,
    String? remarks,
    String? expectedDisbursementDate,
    bool saveAsDraft = false,
  }) async {
    final requestData = {
      'loan_type_id': loanTypeId,
      'amount': amount,
      'tenure_months': tenureMonths,
      'purpose': purpose,
    };

    if (remarks != null) requestData['remarks'] = remarks;
    if (expectedDisbursementDate != null) {
      requestData['expected_disbursement_date'] = expectedDisbursementDate;
    }
    requestData['save_as_draft'] = saveAsDraft;

    return await safeApiCall(
      () => dioClient.post('loan/requests', data: requestData),
      parser: (data) {
        return {
          'message': data['data']['message'],
          'loanId': data['data']['loanId'],
          'loanNumber': data['data']['loanNumber'],
        };
      },
    );
  }

  /// Update an existing loan request
  /// PUT /api/V1/loan/requests/{id}
  Future<Map<String, dynamic>?> updateLoanRequest(
    int id, {
    required int loanTypeId,
    required double amount,
    required int tenureMonths,
    required String purpose,
    String? remarks,
    String? expectedDisbursementDate,
    bool submit = false,
  }) async {
    final requestData = {
      'loan_type_id': loanTypeId,
      'amount': amount,
      'tenure_months': tenureMonths,
      'purpose': purpose,
    };

    if (remarks != null) requestData['remarks'] = remarks;
    if (expectedDisbursementDate != null) {
      requestData['expected_disbursement_date'] = expectedDisbursementDate;
    }
    requestData['submit'] = submit;

    return await safeApiCall(
      () => dioClient.put('loan/requests/$id', data: requestData),
      parser: (data) {
        return {
          'message': data['data']['message'],
          'loanId': data['data']['loanId'],
        };
      },
    );
  }

  /// Cancel a loan request
  /// POST /api/V1/loan/requests/{id}/cancel
  Future<String?> cancelLoanRequest(int id) async {
    return await safeApiCall(
      () => dioClient.post('loan/requests/$id/cancel'),
      parser: (data) {
        // API returns data as a string directly
        if (data['data'] is String) {
          return data['data'] as String;
        }
        return data['data']['message'] as String?;
      },
    );
  }

  /// Delete a draft loan request
  /// DELETE /api/V1/loan/requests/{id}
  Future<String?> deleteLoanRequest(int id) async {
    return await safeApiCall(
      () => dioClient.delete('loan/requests/$id'),
      parser: (data) {
        // API returns data as a string directly
        if (data['data'] is String) {
          return data['data'] as String;
        }
        return data['data']['message'] as String?;
      },
    );
  }

  /// Get loan request history
  /// GET /api/V1/loan/requests/{id}/history
  Future<List<LoanHistory>> getLoanHistory(int id) async {
    return await safeApiCall(
      () => dioClient.get('loan/requests/$id/history'),
      parser: (data) {
        return (data['data']['values'] as List? ?? [])
            .map((item) => LoanHistory.fromJson(item))
            .toList();
      },
    );
  }

  /// Get available loan types
  /// GET /api/V1/loan/types
  Future<List<LoanType>> getLoanTypes() async {
    return await safeApiCall(
      () => dioClient.get('loan/types'),
      parser: (data) {
        return (data['data']['values'] as List? ?? [])
            .map((item) => LoanType.fromJson(item))
            .toList();
      },
    );
  }

  /// Calculate EMI for given parameters
  /// POST /api/V1/loan/calculate-emi
  Future<Map<String, dynamic>?> calculateEmi({
    required double amount,
    required double interestRate,
    required int tenureMonths,
  }) async {
    return await safeApiCall(
      () => dioClient.post('loan/calculate-emi', data: {
        'amount': amount,
        'interest_rate': interestRate,
        'tenure_months': tenureMonths,
      }),
      parser: (data) {
        return {
          'emi': (data['data']['emi'] as num).toDouble(),
          'totalAmount': (data['data']['totalAmount'] as num).toDouble(),
          'totalInterest': (data['data']['totalInterest'] as num).toDouble(),
        };
      },
    );
  }

  /// Get user's loan statistics
  /// GET /api/V1/loan/statistics
  Future<LoanStatistics?> getLoanStatistics() async {
    return await safeApiCall(
      () => dioClient.get('loan/statistics'),
      parser: (data) => LoanStatistics.fromJson(data['data']),
    );
  }
}
