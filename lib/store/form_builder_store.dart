import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import '../api/dio_api/repositories/form_builder_repository.dart';
import '../models/FormBuilder/assigned_form_model.dart';

part 'form_builder_store.g.dart';

class FormBuilderStore = FormBuilderStoreBase with _$FormBuilderStore;

abstract class FormBuilderStoreBase with Store {
  final FormBuilderRepository _repository;

  FormBuilderStoreBase({FormBuilderRepository? repository})
      : _repository = repository ?? FormBuilderRepository();

  @observable
  ObservableList<AssignedFormModel> assignedForms =
      ObservableList<AssignedFormModel>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  int totalCount = 0;

  @observable
  String? currentFilter;

  @observable
  int currentPage = 0;

  @observable
  bool hasMoreData = true;

  @observable
  int? submittingFormId;

  // Constants for pagination
  static const int pageSize = 10;

  @computed
  List<AssignedFormModel> get pendingForms {
    return assignedForms
        .where((form) =>
            form.status?.toLowerCase() == 'pending' ||
            form.status?.toLowerCase() == 'assigned')
        .toList();
  }

  @computed
  List<AssignedFormModel> get submittedForms {
    return assignedForms
        .where((form) => form.status?.toLowerCase() == 'submitted')
        .toList();
  }

  @computed
  List<AssignedFormModel> get overdueForms {
    final now = DateTime.now();
    return assignedForms.where((form) {
      if (form.dueDate == null) return false;
      final dueDate = form.dueDate!;
      return dueDate.isBefore(now) &&
          (form.status?.toLowerCase() == 'pending' ||
              form.status?.toLowerCase() == 'assigned');
    }).toList();
  }

  @computed
  bool get isSubmitting => submittingFormId != null;

  @action
  Future<void> fetchAssignedForms({
    int? skip,
    int? take,
    String? status,
    bool append = false,
  }) async {
    try {
      // Don't fetch if already loading
      if (isLoading) return;

      isLoading = true;
      errorMessage = null;

      final skipCount = skip ?? (currentPage * pageSize);
      final takeCount = take ?? pageSize;

      final response = await _repository.getAssignedForms(
        skip: skipCount,
        take: takeCount,
        status: status ?? currentFilter,
      );

      runInAction(() {
        if (response != null) {
          if (append) {
            // Append to existing list for pagination
            final newForms = response.values;
            assignedForms.addAll(newForms);
          } else {
            // Replace entire list for fresh fetch/filter
            assignedForms = ObservableList.of(response.values);
          }

          totalCount = response.totalCount;
          hasMoreData = assignedForms.length < totalCount;
        } else {
          if (!append) {
            assignedForms.clear();
          }
          totalCount = 0;
          hasMoreData = false;
        }

        isLoading = false;
      });
    } catch (e) {
      runInAction(() {
        errorMessage = _getErrorMessage(e);
        isLoading = false;
        log('Error fetching assigned forms: $e');
      });
    }
  }

  @action
  Future<void> loadMore() async {
    if (isLoading || !hasMoreData) return;

    try {
      currentPage++;
      await fetchAssignedForms(append: true);
    } catch (e) {
      runInAction(() {
        // Revert page increment on error
        currentPage--;
        errorMessage = _getErrorMessage(e);
        log('Error loading more forms: $e');
      });
    }
  }

  @action
  Future<void> filterByStatus(String? status) async {
    try {
      // Reset pagination when filtering
      currentPage = 0;
      currentFilter = status;
      hasMoreData = true;

      await fetchAssignedForms(status: status, append: false);
    } catch (e) {
      runInAction(() {
        errorMessage = _getErrorMessage(e);
        log('Error filtering forms: $e');
      });
    }
  }

  @action
  Future<bool> submitForm({
    required int assignmentId,
    required Map<String, dynamic> formData,
  }) async {
    try {
      submittingFormId = assignmentId;
      errorMessage = null;

      final message = await _repository.submitForm(
        assignmentId: assignmentId,
        formData: formData,
      );

      runInAction(() {
        if (message != null) {
          // Update the form status locally
          final index = assignedForms.indexWhere(
            (form) => form.assignmentId == assignmentId,
          );

          if (index != -1) {
            final updatedForm = assignedForms[index].copyWith(
              status: 'submitted',
            );
            assignedForms[index] = updatedForm;
          }

          toast(message);
        } else {
          errorMessage = 'Failed to submit form';
          toast('Failed to submit form');
        }

        submittingFormId = null;
      });

      return message != null;
    } catch (e) {
      runInAction(() {
        errorMessage = _getErrorMessage(e);
        submittingFormId = null;
        toast(errorMessage ?? 'Error submitting form');
        log('Error submitting form: $e');
      });
      return false;
    }
  }

  @action
  Future<void> refreshForms() async {
    try {
      // Reset pagination state
      currentPage = 0;
      hasMoreData = true;
      assignedForms.clear();

      await fetchAssignedForms(append: false);
    } catch (e) {
      runInAction(() {
        errorMessage = _getErrorMessage(e);
        log('Error refreshing forms: $e');
      });
    }
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  @action
  void reset() {
    assignedForms.clear();
    isLoading = false;
    errorMessage = null;
    totalCount = 0;
    currentFilter = null;
    currentPage = 0;
    hasMoreData = true;
    submittingFormId = null;
  }

  /// Extract user-friendly error message from exception
  String _getErrorMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';

    final errorString = error.toString();

    // Handle common API error patterns
    if (errorString.contains('NetworkException') ||
        errorString.contains('No internet')) {
      return 'No internet connection. Please check your network.';
    }

    if (errorString.contains('TimeoutException') ||
        errorString.contains('timeout')) {
      return 'Request timeout. Please try again.';
    }

    if (errorString.contains('UnauthorizedException') ||
        errorString.contains('401')) {
      return 'Session expired. Please login again.';
    }

    if (errorString.contains('ForbiddenException') ||
        errorString.contains('403')) {
      return 'You do not have permission to perform this action.';
    }

    if (errorString.contains('NotFoundException') ||
        errorString.contains('404')) {
      return 'The requested resource was not found.';
    }

    if (errorString.contains('ServerException') ||
        errorString.contains('500')) {
      return 'Server error. Please try again later.';
    }

    // Return the error message if it's a string
    if (error is String) return error;

    return 'An error occurred. Please try again.';
  }

  void dispose() {
    // Clean up resources if needed
    assignedForms.clear();
  }
}
