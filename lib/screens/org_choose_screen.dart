import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/Utils/app_constants.dart';
import 'package:open_core_hr/api/api_routes.dart';
import 'package:open_core_hr/api/network_utils.dart';
import 'package:open_core_hr/models/DomainModel.dart';
import 'package:open_core_hr/screens/SettingUp/setting_up_screen.dart';

import '../main.dart';

class OrgChooseScreen extends StatefulWidget {
  const OrgChooseScreen({super.key});

  @override
  State<OrgChooseScreen> createState() => _OrgChooseScreenState();
}

class _OrgChooseScreenState extends State<OrgChooseScreen> {
  final TextEditingController _orgController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isProceeding = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    if (getIsDemoMode()) {
      _orgController.text = 'acme';
    }
  }

  /// Lookup organization via the organization/lookup API
  /// Backend expects: { "organization_code": "subdomain" }
  /// Backend returns: { "success": true, "data": { "name": "...", "subdomain": "...", "logo": "..." } }
  Future<TenantModel?> _lookupOrganization(String organizationCode) async {
    try {
      var response = await postRequest(
        APIRoutes.organizationLookup,
        {'organization_code': organizationCode},
      );
      var result = await handleResponse(response);
      if (result != null && result.success == true && result.data != null) {
        // Parse the response format from backend
        final data = result.data;
        final name = data['name'];
        final subdomain = data['subdomain'];

        if (name != null && subdomain != null) {
          return TenantModel(
            tenantId: subdomain, // Use subdomain as tenant identifier
            tenantName: name,
            domain: subdomain,
            domains: [], // Not provided by lookup API
          );
        }
      }
    } catch (e) {
      log("Error looking up organization: $e");
    }
    return null;
  }

  Future<void> _verifyAndProceed() async {
    if (_isProceeding) return;
    if (_formKey.currentState?.validate() != true) return;

    final String query = _orgController.text.trim();
    if (query.isEmpty) return;

    hideKeyboard(context);
    setState(() {
      _isProceeding = true;
      _validationError = null;
    });

    // Lookup organization via the organization/lookup API
    TenantModel? foundTenant = await _lookupOrganization(query);

    if (foundTenant != null) {
      // Store tenant ID for X-Tenant-ID header (header-based SaaS mode)
      await setValue(tenantPref, foundTenant.tenantId);

      // Store organization name for display purposes
      await setValue('organization', foundTenant.tenantName);
      appStore.centralDomainURL = foundTenant.tenantName ?? '';

      // NOTE: In header-based SaaS mode, we DON'T set per-tenant baseurl.
      // All API calls use the central base URL from APIRoutes.baseURL
      // Tenant is identified via X-Tenant-ID header, not URL.

      if (mounted) SettingUpScreen().launch(context, isNewTask: true);
    } else {
      setState(() {
        _validationError = language.lblOrganizationNotFound;
      });
    }

    if (mounted) {
      setState(() => _isProceeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (_) {
          final isDark = appStore.isDarkModeOn;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                    : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header Section (56px)
                  _buildHeader(),

                  // Content Area
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      child: Container(
                        color: isDark
                            ? const Color(0xFF111827)
                            : const Color(0xFFF3F4F6),
                        child: _buildBody(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            language.lblEnterOrganization,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Form Card
                  _buildFormCard(isDark),
                  const SizedBox(height: 16),

                  // Submit Button
                  _buildSubmitButton(isDark),

                  // Demo Mode Indicator
                  if (getIsDemoMode()) ...[
                    const SizedBox(height: 16),
                    _buildDemoModeIndicator(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header with Gradient Icon
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF696CFF).withOpacity(0.2),
                      const Color(0xFF5457E6).withOpacity(0.1)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Iconsax.buildings,
                  color: Color(0xFF696CFF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  language.lblSelectOrganizationTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Subtitle
          Text(
            language.lblEnterOrganizationNameOrDomain,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Organization Label
          Text(
            language.lblOrganization,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),

          // Organization Input Field
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _validationError != null
                    ? Colors.red
                    : isDark
                        ? Colors.grey[700]!
                        : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            child: TextFormField(
              controller: _orgController,
              textInputAction: TextInputAction.done,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF111827),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Iconsax.building,
                  color: Color(0xFF696CFF),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                hintText: language.lblEnterOrganizationName,
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return language.lblFieldRequired;
                }
                if (_validationError != null) {
                  setState(() => _validationError = null);
                }
                return null;
              },
              onFieldSubmitted: (s) => _verifyAndProceed(),
              onChanged: (value) {
                if (_validationError != null) {
                  setState(() => _validationError = null);
                }
              },
            ),
          ),

          // Validation Error
          if (_validationError != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Iconsax.info_circle,
                  size: 14,
                  color: Colors.red,
                ),
                const SizedBox(width: 6),
                Text(
                  _validationError!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    return InkWell(
      onTap: _isProceeding ? null : _verifyAndProceed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF696CFF).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isProceeding
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      language.lblProceed,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Iconsax.arrow_right_3,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDemoModeIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFBFDBFE),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Iconsax.info_circle,
            color: Color(0xFF3B82F6),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language.lblDemoMode,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  language.lblUseAcmeAsOrgName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _orgController.dispose();
    super.dispose();
  }
}
