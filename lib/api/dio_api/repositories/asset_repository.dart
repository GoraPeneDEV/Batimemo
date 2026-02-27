import '../base_repository.dart';
import '../../../models/Assets/asset_model.dart';
import '../../../models/Assets/asset_assignment_model.dart';
import '../../../models/Assets/asset_document_model.dart';
import '../../../models/Assets/asset_maintenance_model.dart';

/// Repository for asset management operations
/// Handles assigned assets, QR scanning, issue reporting, and document access
class AssetRepository extends BaseRepository {
  /// Get paginated list of assigned assets
  ///
  /// GET /api/V1/assets
  ///
  /// Returns list of assets assigned to the current user with optional filtering
  ///
  /// Parameters:
  /// - [skip] - Number of records to skip for pagination (default: 0)
  /// - [take] - Number of records to fetch (default: 10)
  /// - [status] - Filter by asset status (e.g., 'assigned', 'returned', 'under_maintenance')
  /// - [categoryId] - Filter by asset category ID
  ///
  /// Returns [AssetListResponse] containing total count and list of assets
  Future<AssetListResponse?> getAssignedAssets({
    int skip = 0,
    int take = 10,
    String? status,
    int? categoryId,
  }) async {
    final queryParams = <String, dynamic>{
      'skip': skip,
      'take': take,
    };

    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    if (categoryId != null) {
      queryParams['categoryId'] = categoryId;
    }

    return await safeApiCall(
      () => dioClient.get('assets', queryParameters: queryParams),
      parser: (data) => AssetListResponse.fromJson(data['data']),
    );
  }

  /// Get details of a specific asset
  ///
  /// GET /api/V1/assets/{id}
  ///
  /// Returns complete information about a single asset including assignment details,
  /// maintenance history, and current status
  ///
  /// Parameters:
  /// - [assetId] - The unique identifier of the asset
  ///
  /// Returns [AssetModel] with complete asset details
  Future<AssetModel?> getAssetDetails(int assetId) async {
    return await safeApiCall(
      () => dioClient.get('assets/$assetId'),
      parser: (data) => AssetModel.fromJson(data['data']),
    );
  }

  /// Scan asset QR code to retrieve asset details
  ///
  /// GET /api/V1/assets/scan/{qrCode}
  ///
  /// Scans a QR code and returns the associated asset information.
  /// Used for quick asset lookup and verification in the mobile app.
  ///
  /// Parameters:
  /// - [qrCode] - The QR code string to scan
  ///
  /// Returns [AssetModel] if QR code is valid, null if not found
  Future<AssetModel?> scanQRCode(String qrCode) async {
    return await safeApiCall(
      () => dioClient.get('assets/scan/$qrCode'),
      parser: (data) => AssetModel.fromJson(data['data']),
    );
  }

  /// Get assignment history with pagination
  ///
  /// GET /api/V1/assets/assignments/history
  ///
  /// Retrieves the history of asset assignments for the current user,
  /// showing both current and past assignments
  ///
  /// Parameters:
  /// - [skip] - Number of records to skip for pagination (default: 0)
  /// - [take] - Number of records to fetch (default: 10)
  /// - [returned] - Filter by return status (true for returned assets, false for current, null for all)
  ///
  /// Returns [AssignmentHistoryResponse] containing total count and list of assignment history
  Future<AssignmentHistoryResponse?> getAssignmentHistory({
    int skip = 0,
    int take = 10,
    bool? returned,
  }) async {
    final queryParams = <String, dynamic>{
      'skip': skip,
      'take': take,
    };

    if (returned != null) {
      queryParams['returned'] = returned;
    }

    return await safeApiCall(
      () => dioClient.get('assets/assignments/history', queryParameters: queryParams),
      parser: (data) => AssignmentHistoryResponse.fromJson(data['data']),
    );
  }

  /// Report an issue with an assigned asset
  ///
  /// POST /api/V1/assets/{id}/report-issue
  ///
  /// Allows employees to report problems or issues with their assigned assets.
  /// Creates a maintenance ticket or issue record in the system.
  ///
  /// Parameters:
  /// - [assetId] - The ID of the asset with the issue
  /// - [description] - Detailed description of the issue
  ///
  /// Returns true if the issue was successfully reported, false otherwise
  Future<bool> reportIssue(int assetId, String description) async {
    try {
      final response = await safeApiCallWithResponse(
        () => dioClient.post(
          'assets/$assetId/report-issue',
          data: {
            'description': description,
          },
        ),
      );

      return response?.success == true;
    } catch (e) {
      return false;
    }
  }

  /// Get maintenance/issue history for an asset
  ///
  /// GET /api/V1/assets/{id}/maintenances
  ///
  /// Retrieves the maintenance and issue history for a specific asset.
  /// Shows all repairs, upgrades, and reported issues with details.
  ///
  /// Parameters:
  /// - [assetId] - The ID of the asset
  /// - [skip] - Number of records to skip for pagination (default: 0)
  /// - [take] - Number of records to fetch (default: 20)
  ///
  /// Returns [MaintenanceHistoryResponse] containing total count and list of maintenance records
  Future<MaintenanceHistoryResponse?> getMaintenanceHistory({
    required int assetId,
    int skip = 0,
    int take = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'skip': skip,
      'take': take,
    };

    return await safeApiCall(
      () => dioClient.get('assets/$assetId/maintenances', queryParameters: queryParams),
      parser: (data) => MaintenanceHistoryResponse.fromJson(data['data']),
    );
  }

  /// Get asset document
  ///
  /// GET /api/V1/assets/{assetId}/documents/{documentId}
  ///
  /// Retrieves a specific document associated with an asset, such as user manuals,
  /// warranty information, or maintenance records.
  ///
  /// Parameters:
  /// - [assetId] - The ID of the asset
  /// - [documentId] - The ID of the document to retrieve
  ///
  /// Returns [AssetDocumentModel] containing document details including download URL
  Future<AssetDocumentModel?> getDocument(int assetId, int documentId) async {
    return await safeApiCall(
      () => dioClient.get('assets/$assetId/documents/$documentId'),
      parser: (data) => AssetDocumentModel.fromJson(data['data']),
    );
  }
}
