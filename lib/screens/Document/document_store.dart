import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import '../../models/Document/document_request_model.dart';
import '../../models/Document/document_type_model.dart';
import '../../api/dio_api/repositories/document_request_repository.dart';
import '../../api/dio_api/exceptions/api_exceptions.dart';
import '../../utils/url_helper.dart';

part 'document_store.g.dart';

class DocumentStore = DocumentStoreBase with _$DocumentStore;

abstract class DocumentStoreBase with Store {
  final DocumentRequestRepository _repository = DocumentRequestRepository();
  static const pageSize = 15;

  @observable
  PagingController<int, DocumentRequestModel> pagingController =
      PagingController(firstPageKey: 0);

  String? selectedStatus;

  String dateFilter = '';

  @observable
  bool isDownloadLoading = false;

  @observable
  ObservableList<String> statuses = ObservableList.of([
    'pending',
    'approved',
    'rejected',
    'cancelled',
    'generated',
  ]);

  @observable
  TextEditingController dateFilterController = TextEditingController();

  @observable
  bool isLoading = false;

  @observable
  ObservableList<DocumentTypeModel> documentTypes = ObservableList<DocumentTypeModel>();

  @observable
  int? selectedTypeId;

  @observable
  DocumentRequestStatistics? statistics;

  @observable
  String? error;

  final formKey = GlobalKey<FormState>();
  final commentsCont = TextEditingController();
  final commentsNode = FocusNode();

  int _currentPage = 1;

  void _handleError(dynamic e) {
    if (e is ApiException) {
      error = e.message;
    } else {
      error = e.toString();
    }
  }

  @action
  Future<void> fetchDocumentRequests(int pageKey) async {
    try {
      final page = (pageKey ~/ pageSize) + 1;

      final result = await _repository.getMyDocumentRequests(
        page: page,
        perPage: pageSize,
        status: selectedStatus,
        date: dateFilterController.text.isNotEmpty ? dateFilterController.text : null,
      );

      if (result != null) {
        final requests = result['data'] as List<DocumentRequestModel>;
        final currentPage = result['current_page'] as int;
        final lastPage = result['last_page'] as int;
        final isLastPage = currentPage >= lastPage;

        if (isLastPage) {
          pagingController.appendLastPage(requests);
        } else {
          pagingController.appendPage(requests, pageKey + requests.length);
        }
      }
    } catch (e) {
      _handleError(e);
      pagingController.error = e;
    }
  }

  @action
  Future<bool> sendDocumentRequest() async {
    if (selectedTypeId == null) {
      toast(language.lblPleaseSelectADocumentType);
      return false;
    }
    if (formKey.currentState!.validate()) {
      try {
        isLoading = true;
        error = null;

        final result = await _repository.requestDocument(
          documentTypeId: selectedTypeId!,
          remarks: commentsCont.text,
        );

        isLoading = false;

        if (result != null) {
          // Refresh the list
          pagingController.refresh();
          return true;
        }
        return false;
      } catch (e) {
        _handleError(e);
        isLoading = false;
        return false;
      }
    }
    return false;
  }

  @action
  Future<void> getDocumentTypes() async {
    try {
      isLoading = true;
      error = null;

      final types = await _repository.getAvailableDocumentTypes();
      documentTypes = ObservableList.of(types);

      if (documentTypes.isNotEmpty) {
        selectedTypeId = documentTypes.first.id;
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> getStatistics() async {
    try {
      isLoading = true;
      error = null;

      statistics = await _repository.getMyStatistics();
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> getDocumentFileUrl(int id) async {
    try {
      isDownloadLoading = true;
      error = null;

      final downloadInfo = await _repository.getDownloadUrl(id);

      if (downloadInfo != null && downloadInfo['file_url'] != null) {
        final fullUrl = UrlHelper.getFullUrl(downloadInfo['file_url']!);
        await _launchUrl(Uri.parse(fullUrl));
      } else {
        toast('Document file not available');
      }
    } catch (e) {
      _handleError(e);
      toast(error ?? 'Failed to download document');
    } finally {
      isDownloadLoading = false;
    }
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      log('Could not launch $url');
      toast('Failed to open document');
    }
  }

  @action
  Future<bool> cancelDocumentRequest(int id) async {
    try {
      isLoading = true;
      error = null;

      final result = await _repository.cancelDocumentRequest(id);

      if (result) {
        // Refresh the list
        pagingController.refresh();
        toast('Document request cancelled successfully');
      }

      return result;
    } catch (e) {
      _handleError(e);
      toast(error ?? 'Failed to cancel request');
      return false;
    } finally {
      isLoading = false;
    }
  }
}
