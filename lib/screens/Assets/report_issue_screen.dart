import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../store/asset_store.dart';
import '../../models/Assets/asset_model.dart';
import '../../utils/url_helper.dart';
import '../../utils/app_widgets.dart';
import '../../main.dart';

class ReportIssueScreen extends StatefulWidget {
  final int assetId;
  final AssetModel asset;

  const ReportIssueScreen({
    super.key,
    required this.assetId,
    required this.asset,
  });

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  late AssetStore _assetStore;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _assetStore = Provider.of<AssetStore>(context, listen: false);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final success = await _assetStore.reportIssue(
        widget.assetId,
        _descriptionController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        toast(language.lblIssueReportedSuccessfully);
        Navigator.pop(context, true);
      } else {
        toast(_assetStore.errorMessage ?? language.lblFailedToReportIssue);
      }
    } catch (e) {
      if (mounted) {
        toast('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (_) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: appStore.isDarkModeOn
                  ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                  : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header Section
                _buildHeader(),

                // Content Area
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: Container(
                      color: appStore.isDarkModeOn
                          ? const Color(0xFF111827)
                          : const Color(0xFFF3F4F6),
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Asset Information Card
                              _buildAssetInfoCard(),
                              const SizedBox(height: 24),

                              // Issue Description
                              CustomTextField(
                                controller: _descriptionController,
                                label: language.lblIssueDescription,
                                hintText: language.lblDescribeIssueInDetail,
                                prefixIcon: Iconsax.note,
                                maxLines: 6,
                                maxLength: 500,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return language.lblPleaseDescribeIssue;
                                  }
                                  if (value.trim().length < 10) {
                                    return language.lblDescriptionMinLength;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),

                              // Helper Text
                              Text(
                                language.lblProvideDetailToResolve,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: appStore.isDarkModeOn
                                      ? Colors.grey[500]
                                      : const Color(0xFF9CA3AF),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Submit Button
                              _buildSubmitButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            language.lblReportIssue,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetInfoCard() {
    return Observer(
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appStore.isDarkModeOn
              ? const Color(0xFF1F2937)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                  appStore.isDarkModeOn ? 0.3 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Asset Image/Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF696CFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: widget.asset.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: UrlHelper.getFullUrl(widget.asset.image!),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF696CFF)),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Iconsax.box,
                          color: Color(0xFF696CFF),
                          size: 32,
                        ),
                      ),
                    )
                  : const Icon(
                      Iconsax.box,
                      color: Color(0xFF696CFF),
                      size: 32,
                    ),
            ),
            const SizedBox(width: 16),
            // Asset Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.asset.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: appStore.isDarkModeOn
                          ? Colors.white
                          : const Color(0xFF111827),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Iconsax.tag,
                        size: 14,
                        color: appStore.isDarkModeOn
                            ? Colors.grey[500]
                            : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.asset.assetTag,
                        style: TextStyle(
                          fontSize: 13,
                          color: appStore.isDarkModeOn
                              ? Colors.grey[400]
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Iconsax.category,
                        size: 14,
                        color: appStore.isDarkModeOn
                            ? Colors.grey[500]
                            : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.asset.category.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: appStore.isDarkModeOn
                              ? Colors.grey[500]
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF696CFF),
          disabledBackgroundColor: const Color(0xFF696CFF).withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                language.lblSubmitReport,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
