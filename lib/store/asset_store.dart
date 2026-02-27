import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../api/dio_api/repositories/asset_repository.dart';
import '../models/Assets/asset_assignment_model.dart';
import '../models/Assets/asset_document_model.dart';
import '../models/Assets/asset_maintenance_model.dart';
import '../models/Assets/asset_model.dart';

part 'asset_store.g.dart';

class AssetStore = AssetStoreBase with _$AssetStore;

abstract class AssetStoreBase with Store {
  final AssetRepository _assetRepository = AssetRepository();

  // Hive box name
  static const String _assetsBoxName = 'assets_box';
  static const String _assignmentHistoryBoxName = 'assignment_history_box';

  // Observable Collections
  @observable
  ObservableList<AssetModel> assetList = ObservableList<AssetModel>();

  @observable
  AssetModel? currentAsset;

  @observable
  ObservableList<AssetAssignmentModel> assignmentHistory =
      ObservableList<AssetAssignmentModel>();

  @observable
  ObservableList<AssetDocumentModel> assetDocuments =
      ObservableList<AssetDocumentModel>();

  @observable
  ObservableList<AssetMaintenanceModel> maintenanceHistory =
      ObservableList<AssetMaintenanceModel>();

  // Loading States
  @observable
  bool isLoading = false;

  @observable
  bool isLoadingMore = false;

  @observable
  bool isLoadingDetails = false;

  @observable
  bool isReportingIssue = false;

  @observable
  bool isScanningQR = false;

  @observable
  bool isLoadingMaintenance = false;

  // Pagination & Data State
  @observable
  bool hasMoreData = true;

  @observable
  int totalAssetsCount = 0;

  @observable
  int currentPage = 1;

  @observable
  int itemsPerPage = 20;

  @observable
  int totalHistoryCount = 0;

  @observable
  bool hasMoreHistory = true;

  @observable
  int currentHistoryPage = 1;

  @observable
  int totalMaintenanceCount = 0;

  @observable
  bool hasMoreMaintenance = true;

  @observable
  int currentMaintenancePage = 1;

  // Error Handling
  @observable
  String? errorMessage;

  // Filters
  @observable
  String searchQuery = '';

  @observable
  String? selectedStatus;

  @observable
  int? selectedCategoryId;

  // Computed Values
  @computed
  ObservableList<AssetModel> get filteredAssets {
    var filtered = assetList.toList();

    // Apply search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((asset) {
        return asset.name.toLowerCase().contains(query) ||
            asset.assetTag.toLowerCase().contains(query) ||
            (asset.serialNumber?.toLowerCase().contains(query) ?? false) ||
            (asset.manufacturer?.toLowerCase().contains(query) ?? false) ||
            (asset.model?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply status filter
    if (selectedStatus != null && selectedStatus!.isNotEmpty) {
      filtered = filtered.where((asset) => asset.status == selectedStatus).toList();
    }

    // Apply category filter
    if (selectedCategoryId != null) {
      filtered = filtered
          .where((asset) => asset.category.id == selectedCategoryId)
          .toList();
    }

    return ObservableList.of(filtered);
  }

  @computed
  int get activeAssignmentsCount {
    return assetList.where((asset) => asset.isAssigned).length;
  }

  @computed
  bool get hasAssets => assetList.isNotEmpty;

  @computed
  bool get hasFiltersApplied =>
      searchQuery.isNotEmpty ||
      selectedStatus != null ||
      selectedCategoryId != null;

  // Actions

  /// Fetch assigned assets with pagination
  @action
  Future<void> fetchAssignedAssets({bool loadMore = false}) async {
    if (loadMore) {
      if (isLoadingMore || !hasMoreData) return;
      isLoadingMore = true;
      currentPage++;
    } else {
      if (isLoading) return;
      isLoading = true;
      currentPage = 1;
      hasMoreData = true;
      errorMessage = null;
    }

    try {
      final skip = (currentPage - 1) * itemsPerPage;

      log('AssetStore: Fetching assets (page: $currentPage, skip: $skip, take: $itemsPerPage)');

      final response = await _assetRepository.getAssignedAssets(
        skip: skip,
        take: itemsPerPage,
        status: selectedStatus,
        categoryId: selectedCategoryId,
      );

      if (response != null) {
        runInAction(() {
          totalAssetsCount = response.totalCount;

          if (loadMore) {
            // Append to existing list
            assetList.addAll(response.values);
          } else {
            // Replace list
            assetList = ObservableList.of(response.values);
          }

          // Check if there's more data to load
          hasMoreData = assetList.length < totalAssetsCount;

          log('AssetStore: Fetched ${response.values.length} assets. Total: ${assetList.length}/$totalAssetsCount');
        });

        // Save to cache after successful fetch
        await saveToCache();
      } else {
        runInAction(() {
          if (!loadMore) {
            errorMessage = 'Failed to fetch assets. Please try again.';
          }
        });
      }
    } catch (e) {
      log('AssetStore: Error fetching assets - $e');
      runInAction(() {
        errorMessage = 'An error occurred while fetching assets: ${e.toString()}';
        if (loadMore) {
          currentPage--; // Revert page increment on error
        }
      });
    } finally {
      runInAction(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  /// Fetch details of a specific asset
  @action
  Future<bool> fetchAssetDetails(int assetId) async {
    if (isLoadingDetails) return false;

    isLoadingDetails = true;
    errorMessage = null;

    try {
      log('AssetStore: Fetching asset details for ID: $assetId');

      final asset = await _assetRepository.getAssetDetails(assetId);

      if (asset != null) {
        runInAction(() {
          currentAsset = asset;

          // Update in list if exists
          final index = assetList.indexWhere((a) => a.id == assetId);
          if (index != -1) {
            assetList[index] = asset;
          }
        });

        log('AssetStore: Successfully fetched asset details');
        return true;
      } else {
        runInAction(() {
          errorMessage = 'Failed to fetch asset details. Please try again.';
        });
        return false;
      }
    } catch (e) {
      log('AssetStore: Error fetching asset details - $e');
      runInAction(() {
        errorMessage = 'An error occurred while fetching asset details: ${e.toString()}';
      });
      return false;
    } finally {
      runInAction(() {
        isLoadingDetails = false;
      });
    }
  }

  /// Scan QR code to load asset
  @action
  Future<AssetModel?> scanQRCode(String qrCode) async {
    if (isScanningQR) return null;

    isScanningQR = true;
    errorMessage = null;

    try {
      log('AssetStore: Scanning QR code: $qrCode');

      final asset = await _assetRepository.scanQRCode(qrCode);

      if (asset != null) {
        runInAction(() {
          currentAsset = asset;

          // Update or add to list
          final index = assetList.indexWhere((a) => a.id == asset.id);
          if (index != -1) {
            assetList[index] = asset;
          } else {
            assetList.insert(0, asset);
          }
        });

        toast('Asset found: ${asset.name}');
        log('AssetStore: QR scan successful - ${asset.name}');
        return asset;
      } else {
        runInAction(() {
          errorMessage = 'Asset not found. Please check the QR code.';
        });
        toast('Asset not found');
        return null;
      }
    } catch (e) {
      log('AssetStore: Error scanning QR code - $e');
      runInAction(() {
        errorMessage = 'Failed to scan QR code: ${e.toString()}';
      });
      toast('Failed to scan QR code');
      return null;
    } finally {
      runInAction(() {
        isScanningQR = false;
      });
    }
  }

  /// Fetch assignment history with pagination
  @action
  Future<void> fetchAssignmentHistory({bool loadMore = false}) async {
    if (loadMore) {
      if (isLoadingMore || !hasMoreHistory) return;
      isLoadingMore = true;
      currentHistoryPage++;
    } else {
      if (isLoading) return;
      isLoading = true;
      currentHistoryPage = 1;
      hasMoreHistory = true;
      errorMessage = null;
    }

    try {
      final skip = (currentHistoryPage - 1) * itemsPerPage;

      log('AssetStore: Fetching assignment history (page: $currentHistoryPage, skip: $skip)');

      final response = await _assetRepository.getAssignmentHistory(
        skip: skip,
        take: itemsPerPage,
      );

      if (response != null) {
        runInAction(() {
          totalHistoryCount = response.totalCount;

          if (loadMore) {
            assignmentHistory.addAll(response.values);
          } else {
            assignmentHistory = ObservableList.of(response.values);
          }

          hasMoreHistory = assignmentHistory.length < totalHistoryCount;

          log('AssetStore: Fetched ${response.values.length} history records. Total: ${assignmentHistory.length}/$totalHistoryCount');
        });
      } else {
        runInAction(() {
          if (!loadMore) {
            errorMessage = 'Failed to fetch assignment history.';
          }
        });
      }
    } catch (e) {
      log('AssetStore: Error fetching assignment history - $e');
      runInAction(() {
        errorMessage = 'An error occurred while fetching assignment history: ${e.toString()}';
        if (loadMore) {
          currentHistoryPage--;
        }
      });
    } finally {
      runInAction(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  /// Report an issue with an asset
  @action
  Future<bool> reportIssue(int assetId, String description) async {
    if (isReportingIssue) return false;

    if (description.trim().isEmpty) {
      toast('Please provide a description of the issue');
      return false;
    }

    isReportingIssue = true;
    errorMessage = null;

    try {
      log('AssetStore: Reporting issue for asset ID: $assetId');

      final success = await _assetRepository.reportIssue(assetId, description);

      if (success) {
        toast('Issue reported successfully');
        log('AssetStore: Issue reported successfully');

        // Refresh asset details to get updated status
        await fetchAssetDetails(assetId);

        return true;
      } else {
        runInAction(() {
          errorMessage = 'Failed to report issue. Please try again.';
        });
        toast('Failed to report issue');
        return false;
      }
    } catch (e) {
      log('AssetStore: Error reporting issue - $e');
      runInAction(() {
        errorMessage = 'An error occurred while reporting the issue: ${e.toString()}';
      });
      toast('Failed to report issue');
      return false;
    } finally {
      runInAction(() {
        isReportingIssue = false;
      });
    }
  }

  /// Fetch maintenance/issue history for an asset
  @action
  Future<void> fetchMaintenanceHistory(int assetId, {bool loadMore = false}) async {
    if (loadMore) {
      if (isLoadingMore || !hasMoreMaintenance) return;
      isLoadingMore = true;
      currentMaintenancePage++;
    } else {
      if (isLoadingMaintenance) return;
      isLoadingMaintenance = true;
      currentMaintenancePage = 1;
      hasMoreMaintenance = true;
      errorMessage = null;
    }

    try {
      final skip = (currentMaintenancePage - 1) * itemsPerPage;

      log('AssetStore: Fetching maintenance history for asset $assetId (page: $currentMaintenancePage, skip: $skip)');

      final response = await _assetRepository.getMaintenanceHistory(
        assetId: assetId,
        skip: skip,
        take: itemsPerPage,
      );

      if (response != null) {
        runInAction(() {
          totalMaintenanceCount = response.totalCount;

          if (loadMore) {
            maintenanceHistory.addAll(response.values);
          } else {
            maintenanceHistory = ObservableList.of(response.values);
          }

          hasMoreMaintenance = maintenanceHistory.length < totalMaintenanceCount;

          log('AssetStore: Fetched ${response.values.length} maintenance records. Total: ${maintenanceHistory.length}/$totalMaintenanceCount');
        });
      } else {
        runInAction(() {
          if (!loadMore) {
            errorMessage = 'Failed to fetch maintenance history.';
          }
        });
      }
    } catch (e) {
      log('AssetStore: Error fetching maintenance history - $e');
      runInAction(() {
        errorMessage = 'An error occurred while fetching maintenance history: ${e.toString()}';
        if (loadMore) {
          currentMaintenancePage--;
        }
      });
    } finally {
      runInAction(() {
        isLoadingMaintenance = false;
        isLoadingMore = false;
      });
    }
  }

  /// Search assets in local cache
  @action
  void searchAssets(String query) {
    searchQuery = query.trim();
    log('AssetStore: Search query set to: "$searchQuery"');
  }

  /// Apply status filter
  @action
  void filterByStatus(String? status) {
    selectedStatus = status;
    log('AssetStore: Status filter set to: ${status ?? "null"}');

    // Reset pagination and refetch
    currentPage = 1;
    hasMoreData = true;
    fetchAssignedAssets();
  }

  /// Apply category filter
  @action
  void filterByCategory(int? categoryId) {
    selectedCategoryId = categoryId;
    log('AssetStore: Category filter set to: ${categoryId ?? "null"}');

    // Reset pagination and refetch
    currentPage = 1;
    hasMoreData = true;
    fetchAssignedAssets();
  }

  /// Clear all filters
  @action
  void clearFilters() {
    searchQuery = '';
    selectedStatus = null;
    selectedCategoryId = null;
    log('AssetStore: All filters cleared');

    // Reset pagination and refetch
    currentPage = 1;
    hasMoreData = true;
    fetchAssignedAssets();
  }

  /// Clear error message
  @action
  void clearError() {
    errorMessage = null;
  }

  /// Set current asset
  @action
  void setCurrentAsset(AssetModel? asset) {
    currentAsset = asset;
    log('AssetStore: Current asset set to: ${asset?.name ?? "null"}');
  }

  /// Clear current asset
  @action
  void clearCurrentAsset() {
    currentAsset = null;
    log('AssetStore: Current asset cleared');
  }

  /// Save assets to Hive cache
  @action
  Future<void> saveToCache() async {
    try {
      final box = await Hive.openBox<AssetModel>(_assetsBoxName);
      await box.clear();
      await box.addAll(assetList);
      log('AssetStore: Saved ${assetList.length} assets to cache');
    } catch (e) {
      log('AssetStore: Error saving to cache - $e');
      // If there's a type mismatch error, delete the box and try again
      if (e.toString().contains('is not a subtype')) {
        try {
          log('AssetStore: Detected incompatible cache, deleting and retrying...');
          await Hive.deleteBoxFromDisk(_assetsBoxName);
          final box = await Hive.openBox<AssetModel>(_assetsBoxName);
          await box.addAll(assetList);
          log('AssetStore: Successfully saved ${assetList.length} assets after cache clear');
        } catch (retryError) {
          log('AssetStore: Failed to save after cache clear - $retryError');
        }
      }
    }
  }

  /// Load assets from Hive cache
  @action
  Future<void> loadFromCache() async {
    try {
      final box = await Hive.openBox<AssetModel>(_assetsBoxName);
      if (box.isNotEmpty) {
        runInAction(() {
          assetList = ObservableList.of(box.values.toList());
          totalAssetsCount = assetList.length;
          log('AssetStore: Loaded ${assetList.length} assets from cache');
        });
      } else {
        log('AssetStore: No cached assets found');
      }
    } catch (e) {
      log('AssetStore: Error loading from cache - $e');
      // If there's a type mismatch error, delete the incompatible cache
      if (e.toString().contains('is not a subtype')) {
        try {
          log('AssetStore: Detected incompatible cache, deleting...');
          await Hive.deleteBoxFromDisk(_assetsBoxName);
          log('AssetStore: Incompatible cache deleted successfully');
        } catch (deleteError) {
          log('AssetStore: Failed to delete incompatible cache - $deleteError');
        }
      }
    }
  }

  /// Save assignment history to cache
  @action
  Future<void> saveHistoryToCache() async {
    try {
      final box = await Hive.openBox<AssetAssignmentModel>(_assignmentHistoryBoxName);
      await box.clear();
      await box.addAll(assignmentHistory);
      log('AssetStore: Saved ${assignmentHistory.length} history records to cache');
    } catch (e) {
      log('AssetStore: Error saving history to cache - $e');
      // If there's a type mismatch error, delete the box and try again
      if (e.toString().contains('is not a subtype')) {
        try {
          log('AssetStore: Detected incompatible history cache, deleting and retrying...');
          await Hive.deleteBoxFromDisk(_assignmentHistoryBoxName);
          final box = await Hive.openBox<AssetAssignmentModel>(_assignmentHistoryBoxName);
          await box.addAll(assignmentHistory);
          log('AssetStore: Successfully saved ${assignmentHistory.length} history records after cache clear');
        } catch (retryError) {
          log('AssetStore: Failed to save history after cache clear - $retryError');
        }
      }
    }
  }

  /// Load assignment history from cache
  @action
  Future<void> loadHistoryFromCache() async {
    try {
      final box = await Hive.openBox<AssetAssignmentModel>(_assignmentHistoryBoxName);
      if (box.isNotEmpty) {
        runInAction(() {
          assignmentHistory = ObservableList.of(box.values.toList());
          totalHistoryCount = assignmentHistory.length;
          log('AssetStore: Loaded ${assignmentHistory.length} history records from cache');
        });
      } else {
        log('AssetStore: No cached history found');
      }
    } catch (e) {
      log('AssetStore: Error loading history from cache - $e');
      // If there's a type mismatch error, delete the incompatible cache
      if (e.toString().contains('is not a subtype')) {
        try {
          log('AssetStore: Detected incompatible history cache, deleting...');
          await Hive.deleteBoxFromDisk(_assignmentHistoryBoxName);
          log('AssetStore: Incompatible history cache deleted successfully');
        } catch (deleteError) {
          log('AssetStore: Failed to delete incompatible history cache - $deleteError');
        }
      }
    }
  }

  /// Refresh all data
  @action
  Future<void> refreshAll() async {
    log('AssetStore: Refreshing all data');
    await Future.wait([
      fetchAssignedAssets(),
      fetchAssignmentHistory(),
    ]);
  }

  /// Reset store to initial state
  @action
  void reset() {
    assetList.clear();
    assignmentHistory.clear();
    assetDocuments.clear();
    maintenanceHistory.clear();
    currentAsset = null;
    searchQuery = '';
    selectedStatus = null;
    selectedCategoryId = null;
    currentPage = 1;
    currentHistoryPage = 1;
    currentMaintenancePage = 1;
    hasMoreData = true;
    hasMoreHistory = true;
    hasMoreMaintenance = true;
    totalAssetsCount = 0;
    totalHistoryCount = 0;
    totalMaintenanceCount = 0;
    errorMessage = null;
    isLoading = false;
    isLoadingMore = false;
    isLoadingDetails = false;
    isReportingIssue = false;
    isScanningQR = false;
    isLoadingMaintenance = false;
    log('AssetStore: Store reset to initial state');
  }
}
