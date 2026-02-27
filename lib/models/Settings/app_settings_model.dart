class AppSettingsModel {
  // SaaS Mode
  bool? isSaaSMode;

  // Demo Mode
  bool? isDemoMode;

  // App Settings
  String? privacyPolicyUrl;
  String? currency;
  String? currencySymbol;
  String? distanceUnit;
  String? countryPhoneCode;

  // Support Settings
  String? supportEmail;
  String? supportPhone;
  String? supportWhatsapp;
  String? website;

  // Company Settings
  String? companyName;
  String? companyLogo;
  String? companyAddress;
  String? companyPhone;
  String? companyEmail;
  String? companyWebsite;
  String? companyCountry;
  String? companyState;

  AppSettingsModel({
    this.isSaaSMode,
    this.isDemoMode,
    this.privacyPolicyUrl,
    this.currency,
    this.currencySymbol,
    this.distanceUnit,
    this.countryPhoneCode,
    this.supportEmail,
    this.supportPhone,
    this.supportWhatsapp,
    this.website,
    this.companyName,
    this.companyLogo,
    this.companyAddress,
    this.companyPhone,
    this.companyEmail,
    this.companyWebsite,
    this.companyCountry,
    this.companyState,
  });

  AppSettingsModel.fromJson(Map<String, dynamic> json) {
    isSaaSMode = json['isSaaSMode'] ?? false;
    isDemoMode = json['isDemoMode'] ?? false;
    privacyPolicyUrl = json['privacyPolicyUrl'];
    currency = json['currency'];
    currencySymbol = json['currencySymbol'];
    distanceUnit = json['distanceUnit'];
    countryPhoneCode = json['countryPhoneCode'];
    supportEmail = json['supportEmail'];
    supportPhone = json['supportPhone'];
    supportWhatsapp = json['supportWhatsapp'];
    website = json['website'];
    companyName = json['companyName'];
    companyLogo = json['companyLogo'];
    companyAddress = json['companyAddress'];
    companyPhone = json['companyPhone'];
    companyEmail = json['companyEmail'];
    companyWebsite = json['companyWebsite'];
    companyCountry = json['companyCountry'];
    companyState = json['companyState'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isSaaSMode'] = isSaaSMode;
    data['isDemoMode'] = isDemoMode;
    data['privacyPolicyUrl'] = privacyPolicyUrl;
    data['currency'] = currency;
    data['currencySymbol'] = currencySymbol;
    data['distanceUnit'] = distanceUnit;
    data['countryPhoneCode'] = countryPhoneCode;
    data['supportEmail'] = supportEmail;
    data['supportPhone'] = supportPhone;
    data['supportWhatsapp'] = supportWhatsapp;
    data['website'] = website;
    data['companyName'] = companyName;
    data['companyLogo'] = companyLogo;
    data['companyAddress'] = companyAddress;
    data['companyPhone'] = companyPhone;
    data['companyEmail'] = companyEmail;
    data['companyWebsite'] = companyWebsite;
    data['companyCountry'] = companyCountry;
    data['companyState'] = companyState;
    return data;
  }
}
