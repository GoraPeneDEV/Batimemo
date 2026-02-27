import 'package:mobx/mobx.dart';

import '../../api/dio_api/repositories/hr_policies_repository.dart';
import '../../models/HRPolicies/policy_model.dart';
import '../../models/HRPolicies/policy_stats_model.dart';
import '../../models/HRPolicies/policy_category_model.dart';
import '../../models/HRPolicies/policy_detail_model.dart';
import '../../models/HRPolicies/acknowledgment_response_model.dart';

part 'hr_policies_store.g.dart';

class HRPoliciesStore = HRPoliciesStoreBase with _$HRPoliciesStore;

abstract class HRPoliciesStoreBase with Store {
  final HRPoliciesRepository _repository = HRPoliciesRepository();

  @observable
  ObservableList<PolicyModel> allPolicies = ObservableList.of([]);

  @observable
  ObservableList<PolicyModel> pendingPolicies = ObservableList.of([]);

  @observable
  ObservableList<PolicyModel> overduePolicies = ObservableList.of([]);

  @observable
  PolicyStatsModel? stats;

  @observable
  ObservableList<PolicyCategoryModel> categories = ObservableList.of([]);

  @observable
  int? selectedCategoryId;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  PolicyDetailModel? currentPolicyDetail;

  // Computed observable for acknowledged policies
  @computed
  List<PolicyModel> get acknowledgedPolicies {
    return allPolicies.where((policy) => policy.status == 'acknowledged').toList();
  }

  @action
  Future<void> init() async {
    await Future.wait([
      fetchPolicyStats(),
      fetchCategories(),
      fetchAllPolicies(),
    ]);
  }

  @action
  Future<void> fetchAllPolicies() async {
    isLoading = true;
    errorMessage = null;

    try {
      List<PolicyModel> policies;

      // Fetch policies based on selected category
      if (selectedCategoryId != null) {
        policies = await _repository.getPoliciesByCategory(selectedCategoryId!);
      } else {
        policies = await _repository.getMyPolicies();
      }

      runInAction(() {
        allPolicies.clear();
        allPolicies.addAll(policies);

        // Populate filtered lists
        pendingPolicies.clear();
        pendingPolicies.addAll(
          policies.where((policy) => policy.status == 'pending').toList(),
        );

        overduePolicies.clear();
        overduePolicies.addAll(
          policies.where((policy) => policy.isOverdue).toList(),
        );
      });
    } catch (e) {
      runInAction(() {
        errorMessage = 'Error fetching policies: $e';
      });
      print('Error fetching policies: $e');
    } finally {
      runInAction(() {
        isLoading = false;
      });
    }
  }

  @action
  Future<void> fetchPolicyStats() async {
    try {
      final fetchedStats = await _repository.getMyPoliciesStats();
      runInAction(() {
        stats = fetchedStats;
      });
    } catch (e) {
      print('Error fetching policy statistics: $e');
    }
  }

  @action
  Future<void> fetchCategories() async {
    try {
      final fetchedCategories = await _repository.getCategories();
      runInAction(() {
        categories.clear();
        categories.addAll(fetchedCategories);
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  @action
  Future<void> filterByCategory(int? categoryId) async {
    selectedCategoryId = categoryId;
    await fetchAllPolicies();
  }

  @action
  Future<void> refreshData() async {
    await Future.wait([
      fetchPolicyStats(),
      fetchCategories(),
      fetchAllPolicies(),
    ]);
  }

  @action
  Future<AcknowledgmentResponseModel?> acknowledgePolicy(
    int acknowledgmentId,
    String? comments,
  ) async {
    isLoading = true;
    errorMessage = null;

    try {
      final response = await _repository.acknowledgePolicy(
        acknowledgmentId: acknowledgmentId,
        comments: comments,
      );

      // Refresh data after successful acknowledgment
      await Future.wait([
        fetchPolicyStats(),
        fetchAllPolicies(),
      ]);

      return response;
    } catch (e) {
      runInAction(() {
        errorMessage = 'Error acknowledging policy: $e';
      });
      print('Error acknowledging policy: $e');
      rethrow;
    } finally {
      runInAction(() {
        isLoading = false;
      });
    }
  }

  @action
  Future<void> fetchPolicyDetails(int policyId) async {
    try {
      isLoading = true;
      errorMessage = null;
      currentPolicyDetail = null;

      final detail = await _repository.getPolicyDetails(policyId);

      runInAction(() {
        currentPolicyDetail = detail;
        isLoading = false;
      });
    } catch (e) {
      runInAction(() {
        errorMessage = 'Failed to load policy details: ${e.toString()}';
        isLoading = false;
      });
      print('Error fetching policy details: $e');
    }
  }

  @action
  void clearError() {
    errorMessage = null;
  }
}
