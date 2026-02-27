import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mobx/mobx.dart';

import '../../api/dio_api/repositories/loan_repository.dart';
import '../../models/Loan/loan_request_model.dart';
import '../../models/Loan/loan_type.dart';
import '../../models/Loan/loan_statistics.dart';

part 'loan_store.g.dart';

class LoanStore = LoanStoreBase with _$LoanStore;

abstract class LoanStoreBase with Store {
  static const pageSize = 10;
  final LoanRepository _loanRepository = LoanRepository();

  @observable
  PagingController<int, LoanRequestModel> pagingController =
      PagingController(firstPageKey: 0);

  @observable
  String? selectedStatus;

  @observable
  ObservableList<String> statuses = ObservableList.of([
    'draft',
    'pending',
    'approved',
    'rejected',
    'cancelled',
    'disbursed',
    'closed',
  ]);

  @observable
  bool isLoading = false;

  @observable
  LoanStatistics? statistics;

  @observable
  ObservableList<LoanType> loanTypes = ObservableList.of([]);

  @observable
  LoanType? selectedLoanType;

  // Form controllers
  final TextEditingController amountController = TextEditingController();
  final TextEditingController tenureController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  final TextEditingController expectedDisbursementDateController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @action
  Future<void> init() async {
    await Future.wait([
      fetchLoanStatistics(),
      fetchLoanTypes(),
    ]);
  }

  @action
  Future<void> fetchLoanStatistics() async {
    try {
      statistics = await _loanRepository.getLoanStatistics();
    } catch (e) {
      print('Error fetching loan statistics: $e');
    }
  }

  @action
  Future<void> fetchLoanTypes() async {
    try {
      final types = await _loanRepository.getLoanTypes();
      loanTypes.clear();
      loanTypes.addAll(types);
      if (types.isNotEmpty) {
        selectedLoanType = types.first;
      }
    } catch (e) {
      print('Error fetching loan types: $e');
    }
  }

  @action
  Future<void> fetchLoanRequests(int pageKey) async {
    try {
      final result = await _loanRepository.getLoanRequests(
        skip: pageKey,
        take: pageSize,
        status: selectedStatus,
      );

      final newItems = result['values'] as List<LoanRequestModel>;
      final totalCount = result['totalCount'] as int;

      final isLastPage = pageKey + newItems.length >= totalCount;
      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        pagingController.appendPage(newItems, pageKey + newItems.length);
      }
    } catch (error) {
      print('Error fetching loan requests: $error');
      pagingController.error = error;
    }
  }

  @action
  Future<Map<String, dynamic>?> createLoanRequest({
    bool saveAsDraft = false,
  }) async {
    if (selectedLoanType == null) {
      throw Exception('Please select a loan type');
    }

    isLoading = true;
    try {
      final result = await _loanRepository.createLoanRequest(
        loanTypeId: selectedLoanType!.id,
        amount: double.parse(amountController.text),
        tenureMonths: int.parse(tenureController.text),
        purpose: purposeController.text,
        remarks: remarksController.text.isNotEmpty ? remarksController.text : null,
        expectedDisbursementDate: expectedDisbursementDateController.text.isNotEmpty
            ? expectedDisbursementDateController.text
            : null,
        saveAsDraft: saveAsDraft,
      );

      // Clear form after successful submission
      clearForm();

      // Refresh statistics
      await fetchLoanStatistics();

      return result;
    } catch (e) {
      print('Error creating loan request: $e');
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<Map<String, dynamic>?> updateLoanRequest(
    int id, {
    bool submit = false,
  }) async {
    if (selectedLoanType == null) {
      throw Exception('Please select a loan type');
    }

    isLoading = true;
    try {
      final result = await _loanRepository.updateLoanRequest(
        id,
        loanTypeId: selectedLoanType!.id,
        amount: double.parse(amountController.text),
        tenureMonths: int.parse(tenureController.text),
        purpose: purposeController.text,
        remarks: remarksController.text.isNotEmpty ? remarksController.text : null,
        expectedDisbursementDate: expectedDisbursementDateController.text.isNotEmpty
            ? expectedDisbursementDateController.text
            : null,
        submit: submit,
      );

      // Refresh statistics
      await fetchLoanStatistics();

      return result;
    } catch (e) {
      print('Error updating loan request: $e');
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> cancelLoanRequest(int id) async {
    isLoading = true;
    try {
      await _loanRepository.cancelLoanRequest(id);

      // Refresh statistics
      await fetchLoanStatistics();
    } catch (e) {
      print('Error cancelling loan request: $e');
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> deleteLoanRequest(int id) async {
    isLoading = true;
    try {
      await _loanRepository.deleteLoanRequest(id);

      // Refresh statistics
      await fetchLoanStatistics();
    } catch (e) {
      print('Error deleting loan request: $e');
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<Map<String, dynamic>?> calculateEmi() async {
    if (selectedLoanType == null) {
      throw Exception('Please select a loan type');
    }

    if (amountController.text.isEmpty || tenureController.text.isEmpty) {
      throw Exception('Please enter amount and tenure');
    }

    try {
      return await _loanRepository.calculateEmi(
        amount: double.parse(amountController.text),
        interestRate: selectedLoanType!.interestRate,
        tenureMonths: int.parse(tenureController.text),
      );
    } catch (e) {
      print('Error calculating EMI: $e');
      rethrow;
    }
  }

  @action
  void setSelectedLoanType(LoanType? type) {
    selectedLoanType = type;
  }

  @action
  void setSelectedStatus(String? status) {
    selectedStatus = status;
  }

  @action
  void clearForm() {
    amountController.clear();
    tenureController.clear();
    purposeController.clear();
    remarksController.clear();
    expectedDisbursementDateController.clear();
  }

  void dispose() {
    pagingController.dispose();
    amountController.dispose();
    tenureController.dispose();
    purposeController.dispose();
    remarksController.dispose();
    expectedDisbursementDateController.dispose();
  }
}
