import 'package:flutter/material.dart';

abstract class BaseLanguage {
  static BaseLanguage of(BuildContext context) =>
      Localizations.of<BaseLanguage>(context, BaseLanguage)!;

  String get lblSelectDateRange;

  String get lblOrganization;

  String get lblStart;

  String get lblEnd;

  String get lblNoRequestsFound;

  String get lblRequestedBy;

  String get lblCallNow;

  String get lblCreatedOn;

  String get lblFileForwardedSuccessfully;

  //Long words

  String get lblDoYouWantToLogoutFromTheApp;

  String get lblAreYouSureYouWantToDelete;

  String get lblLanguageChanged;

  String get lblLoggedOutSuccessfully;

  String get lblCommentsIsRequired;

  String get lblVerificationFailedPleaseTryAgain;

  String get lblThisDeviceIsNotRegisteredClickOnRegisterToAddItToYourAccount;

  String
      get lblThisDeviceIsAlreadyRegisteredWithOtherAccountPleaseContactAdministrator;

  String get lblEnterYourPhoneNumberToSendAnOTP;

  String
      get lblWeHaveSendA4DigitVerificationCodeToYourPhonePleaseEnterTheCodeBelowTtoVerifyItsYou;

  String get lblPasswordSuccessfullyChanged;

  String get lblPleaseAllowAllTheTimeInSettings;

  String get lblPleaseEnableAllowAllTheTimeInSettings;

  String get lblPleaseEnablePhysicalActivityPermissionInSettings;

  String get lblToEnableAutomaticAttendance;

  String get lblToTrackTheDistanceTravelled;

  String get lblToMarkClientVisits;

  String get lblToProcessTheSalary;

  String
      get lblLocationWillBeTrackedTnTheBackgroundAndAlsoEvenWhenTheAppIsClosedOrNotInUse;

  String
      get lblImportantGiveLocationAccuracyToPreciseAndAllowAllTheTimeSoThatTheAppCanFunctionProperly;

  String get lblCollectsPhysicalActivityData;

  String get lblToCheckTheDeviceStateToEnableTrackingWhenTravelling;

  String get lblYourAccountIsBanned;

  String get lblEnableAutoStart;

  String get lblFollowTheStepsAndEnableTheAutoStartOfThisApp;

  String get lblYourDeviceHasAdditionalBatteryOptimization;

  String
      get lblFollowTheStepsAndDisableTheOptimizationsToAllowSmoothFunctioningOfThisApp;

  String get lblAreYouSureYouWantToCheckOut;

  String get lblLoadingPleaseWait;

  String get lblPleaseSetUpYourTouchId;

  String get lblPleaseReEnableYourTouchId;

  String get lblAuthenticateWithFingerprintOrPasswordToProceed;

  String get lblFingerprintOrPinVerificationIsRequiredForCheckInAndOut;

  String get lblCityIsRequired;

  String get lblAddressIsRequired;

  String get lblPleasePickALocation;

  String get lblContactPersonNameIsRequired;

  String get lblPhoneNumberIsRequired;

  String get lblNameIsRequired;

  String get lblClientAdded;

  String get lblRemarksIsRequired;

  String get lblAmountIsRequired;

  String get lblSomethingWentWrongWhileUploadingTheFile;

  String get lblPleaseAllowMotionTracking;

  String get lblTrackingStartedAt;

  String get lblActivityCount;

  String get lblLocationCount;

  String get lblLastLocation;

  String get lblRefresh;

  String get lblDeviceStatusUpdateInterval;

  String get lblBackgroundServiceStatus;

  String get lblBackgroundLocationTracker;

  String get lblDeviceStatus;

  String get lblRunning;

  String get lblStopped;

  String get lblRefreshAppConfiguration;

  String get lblSettingsRefreshed;

  //Ends

  String get lblEnterValidDate;

  String get lblEnterDateInValidRange;

  String get lblYouCannotSelectOlderDates;

  String get lblLeaveTo;

  String get lblPleaseTryAgainLater;

  String get lblPleaseTryAgain;

  String get lblLeaveFrom;

  String get lblChoose;

  String get lblFromDate;

  String get lblClaimed;

  String get lblYou;

  String get lblYourAccountIsActive;

  String get lblBanned;

  String get lblYouReBanned;

  String get lblKindlyContactAdministrator;

  String get lblPleaseTypeAMessageFirst;

  String get lblOpenSecuritySettings;

  String get lblFingerprintAuthentication;

  String get lblCancel;

  String get lblTodayAttendance;

  String get lblNotifications;

  String get lblRegisterNow;

  String get lblSun;

  String get lblMon;

  String get lblTue;

  String get lblWed;

  String get lblThu;

  String get lblFri;

  String get lblSat;

  String get lblVerified;

  String get lblSearchByAddress;

  String get lblAllSet;

  String get lblActivityAccess;

  String get lblCollectsLocationData;

  String get lblNewPassword;

  String get lblPasswordIsRequired;

  String get lblSendOTP;

  String get lblVerifyOTP;

  String get lblChange;

  String get lblInvalidPassword;

  String get lblExpenseType;

  String get lblNoMessages;

  String get lblTypeYourMessage;

  String get lblPickAddress;

  String get lblConfirm;

  String get lblSearchHere;

  String get lblCheckOut;

  String get lblVerifyIdentity;

  String get lblScanYourFingerprintToCheckIn;

  String get lblAreYouSureYouWantToCheckIn;

  String get lblAllDoneForToday;

  String get lblClient;

  String get lblVerificationFailed;

  String get lblVerificationPending;

  String get lblYourDeviceVerificationIsPending;

  String get lblNewDevice;

  String get lblVisits;

  String get lblImageIsRequired;

  String get lblSubmittedSuccessfully;

  String get lblToday;

  String get lblExpenseStatus;

  String get lblAttendanceInAt;

  String get lblAttendanceOutAt;

  String get lblNoRequests;

  String get lblPrivacyPolicy;

  String get lblLeave;

  String get lblChangeLanguage;

  //Login
  String get lblLogin;

  String get lblSignIn;

  String get lblSignOut;

  String get lblUserName;

  String get lblPassword;

  String get lblRememberMe;

  String get lblForgotPassword;

  String get lblVerification;

  String get lblAccount;

  String get lblDarkMode;

  String get lblNotification;

  String get lblArabic;

  String get lblEnglish;
  //Other

  String get lblDocumentation;

  String get lblChangeLog;

  String get lblShareApp;

  String get lblRateUs;

  String get lblSettings;

  String get lblLanguage;

  String get lblSupportLanguage;

  String get lblDefaultTheme;

  String get lblDashboard;

  String get lblSetupConfiguration;

  String get lblVersionHistory;

  String get lblShareWithFriends;

  String get lblRateGooglePlayStore;

  String get lblContactUs;

  String get lblGetInTouchWithUs;

  String get lblAboutUs;

  String get lblSupport;

  String get lblVersion;

  String get lblAboutUsDescription;

  String get lblHome;

  String get lblAttendanceStatus;

  String get lblCheckInToBegin;

  String get lblCheckIn;

  String get lblExpense;

  String get lblCreateExpense;

  String get lblDate;

  String get lblLeaveType;

  String get lblAmount;

  String get lblRemarks;

  String get lblChooseImage;

  String get lblSubmit;

  String get lblGoodMorning;

  String get lblName;

  String get lblTodayDate;

  String get lblShift;

  String get lblAttendanceInformation;

  String get lblKM;

  String get lblDays;

  String get lblPresent;

  String get lblHalfDay;

  String get lblAbsent;

  String get lblWeeklyOff;

  String get lblOnLeave;

  String get lblAvailableLeave;

  String get lblDistance;

  String get lblTravelled;

  String get lblApproved;

  String get lblPending;

  String get lblRejected;

  String get lblLeaveRequest;

  String get lblFrom;

  String get lblTo;

  String get lblNoRequest;

  String get lblComments;

  String get lblClients;

  String get lblCreateClient;

  String get lblEmail;

  String get lblPhoneNumber;

  String get lblContactPerson;

  String get lblAddress;

  String get lblCity;

  String get lblLogout;

  String get lblClickToAddImage;

  String get lblUsername;

  String get lblByLoggingInYouAreAgreedToThePrivacyPolicy;

  String get lblClickHereToReadPrivacyPolicy;

  String get lblDeviceVerification;

  String get lblVerificationCompleted;

  String get lblYourDeviceVerificationIsSuccessfullyCompleted;

  String get lblOk;

  String get lblWelcomeBack;

  String get lblLocationAccess;

  String get lblVerifying;

  String get lblPleaseWait;

  String get lblEnablePermission;

  String get lblLogOut;

  String get lblConfirmation;

  String get lblYes;

  String get lblNo;

  String get lblSuccessfullyCheckIn;

  String get lblMarkVisit;

  String get lblVisitHistory;

  String get lblRequestSuccessfullySubmitted;

  String get lblChats;

  String get lblSuccessfullyCheckOut;

  String get lblHoldOn;

  String get lblNote;

  String get lblTasks;

  String get lblNoticeBoard;

  String get lblMore;

  String get lblTaskSystemIsNotEnabled;

  String get lblUpcoming;

  String get lblHold;

  String get lblCompleted;

  String get lblNoRunningTask;

  String get lblTaskHeldSuccessfully;

  String get lblTaskCompletedSuccessfully;

  String get lblNoUpcomingTasks;

  String get lblTaskStartedSuccessfully;

  String get lblTaskResumedSuccessfully;

  String get lblNoTasksAreOnHold;

  String get lblNoCompletedTasks;

  String get lblResumeTask;

  String get lblAreYouSureYouWantToResumeThisTask;

  String get lblTaskId;

  String get lblStatus;

  String get lblTitle;

  String get lblStartedOn;

  String get lblDetails;

  String get lblResume;

  String get lblComplete;

  String get lblUpdates;

  String get lblHoldTask;

  String get lblAreYouSureYouWantToHoldThisTask;

  String get lblCompleteTask;

  String get lblAreYouSureYouWantToCompleteThisTask;

  String get lblAreYouSureYouWantToStartThisTask;

  String get lblTime;

  String get lblDescription;

  String get lblClose;

  String get lblStartTask;

  String get lblReset;

  String get lblApply;

  String get lblAttendanceHistory;

  String get lblRange;

  String get lblInTime;

  String get lblOutTime;

  String get lblInvalidInput;

  String get lblAttach;

  String get lblCamera;

  String get lblPhoto;

  String get lblVideo;

  String get lblFile;

  String get lblFailedToLoadImage;

  String get lblLocation;

  String get lblShare;

  String get lblForward;

  String get lblPickALocation;

  String get lblSelectChatToForwardTo;

  String get lblMessageForwardedSuccessfully;

  String get lblAudio;

  String get lblCopy;

  String get lblNewChat;

  String get lblNewGroup;

  String get lblSearch;

  String get lblEmergencyNotificationWillBeSentIn;

  String get lblSOSAlert;

  String get lblSOS;

  String get lblAreYouSureYouWantToExit;

  String get lblExitApp;

  String get lblPhone;

  String get lblActivity;

  String get lblUnableToDownloadTheFile;

  String get lblLocationInfo;

  String get lblAttachFile;

  String get lblTakePhoto;

  String get lblProfile;

  String get lblViewImage;

  String get lblFailedToSendSOS;

  String get lblAdminIsNotified;

  String get lblProceed;

  String get lblYourDeviceIsRestrictedToUseThisAppPleaseContactAdmin;

  String get lblSelectOrganization;

  String get lblNoOrganizationFound;

  String get lblSelectAOrganization;

  String get lblPleaseSelectAOrganization;

  String get lblOrganizations;

  String get lblChooseYourOrganizationFromTheListBelow;

  String get lblNoImageAvailableForThisVisit;

  String get lblDesignation;

  String get lblUnableToGetUserInfo;

  String get lblPaused;

  String get lblPause;

  String get lblUnableToGetLocationPleaseEnableLocationServices;

  String get lblTaskPausedSuccessfully;

  String get lblAreYouSureYouWantToPauseThisTask;

  String get lblMap;

  String get lblCall;

  String
      get lblForAnyQueriesCustomizationsInstallationOrFeedbackPleaseContactUsAt;

  String get lblThisWillOnlyTakeAFewSeconds;

  String get lblSettingThingsUpPleaseWait;

  String get lblSettingUp;

  String get lblScanQRCode;

  String get lblModules;

  String get lblEnabled;

  String get lblDisabled;

  String get lblPlaceQRCodeInTheScanWindow;

  String get lblProgress;

  String get lblNoTargetsFound;

  String get lblIncentiveAmount;

  String get lblIncentivePercentage;

  String get lblIncentiveDetails;

  String get lblPleaseAllowAllPermissionsToContinue;

  String get lblCreate;

  String get lblAchieved;

  String get lblTarget;

  String
      get lblNotificationPermissionEnsuresYouReceiveUpdatesOnAttendanceTasksAndOtherImportantEventsInRealTime;

  String get lblEnableNotificationsToKeepYouUpdatedWithImportantUpdates;

  String
      get lblActivityPermissionIsUsedToDetectYourPhysicalMovementsAndTravelEnablingTheAppToTrackAttendanceVisitsAndActivityStates;

  String get lblAllowAccessToYourActivityForAttendanceAndTravelTracking;

  String
      get lblLocationPermissionIsRequiredForTrackingAttendanceRecordingClientVisitsAndCalculatingDistancesTraveledEvenWhenTheAppIsNotInUse;

  String get lblToEnsureProperFunctionalityTheFollowingPermissionsAreRequired;

  String
      get lblAllowAccessToYourLocationForAttendanceAndTravelTrackingEvenWhenTheAppIsClosed;

  String get lblNext;

  String get lblForDate;

  String get lblHolidays;

  String get lblAllow;

  String get lblPermissions;

  String get lblMoreDetails;

  String get lblOrder;

  String get lblNoPayslipsFound;

  String get lblAddOrder;

  String get lblNetPay;

  String get lblYear;

  String get lblMonth;

  String get lblPayslips;

  String get lblLeaveTaken;

  String get lblWorkingDays;

  String get lblDownloadPayslip;

  String get lblRemove;

  String get lblEarnings;

  String get lblDeductions;

  String get lblNoRecordsFound;

  String get lblAddedToCart;

  String get lblRemovedFromCart;

  String get lblSubCategories;

  String get lblNoNotificationsFound;

  String get lblScanFace;

  String get lblFailedToInitiateChat;

  String get lblFailedToCreateGroupChat;

  String get lblSalesTargets;

  String get lblPayslip;

  String get lblCreateGroup;

  String get lblNoUsersFound;

  String get lblErrorFetchingData;

  String get lblErrorSearchingUsers;

  String get lblEnterGroupName;

  String get lblPleaseEnterAGroupNameAndSelectUsers;

  String get lblSearchUsers;

  String get lblLoanRequestCancelledSuccessfully;

  String get lblLeaveRequestCancelledSuccessfully;

  String get lblPleaseSelectFromDateFirst;

  String get lblPleaseSelectToDate;

  String get lblPleaseSelectFromDate;

  String get lblTodaysClientVisits;

  String get lblSomethingWentWrong;

  String get lblPeriod;

  String get lblFullDate;

  String get lblScanQRCodeToMarkAttendance;

  String get lblFaceRecognitionIsEnabled;

  String get lblOpenAttendance;

  String get lblDynamicQRCodeIsEnabled;

  String get lblNoHolidaysFoundForThisYear;

  String get lblFilterByYear;

  String get lblNoDesignation;

  String get lblGroupMembers;

  String get lblGroupInfo;

  String get lblFailedToLoadParticipants;

  String get lblNoDescription;

  String get lblExpenseRequestCancelledSuccessfully;

  String get lblAreYouSureYouWantToCancelThisRequest;

  String get lblNoDocumentRequestsFound;

  String get lblDownloadingFilePleaseWait;

  String get lblSelectStatus;

  String get lblEmployeeCode;

  String get lblDigitalIDCard;

  String get lblUnableToRegisterDevice;

  String get lblDeviceSuccessfullyRegistered;

  String get lblNoClientsFoundFor;

  String get lblTypeToSearchClients;

  String get lblNoClientsFound;

  String get lblNoChatsFound;

  String get lblTypeAMessage;

  String get lblFailedToSendMessage;

  String get lblFailedToSendAttachment;

  String get lblYesterday;

  String get lblMessageCopied;

  String get lblSharedFrom;

  String get lblNoMessagesYet;

  String get lblNoChatsAvailableToForward;

  String get lblChooseClient;

  String get lblImageNotAvailable;

  String get lblViewLocationInMaps;

  String get lblDocument;

  String get lblViewDocument;

  String get lblDownloadDocument;

  String get lblAdmin;

  String get lblSharedComments;

  String get lblStartedTheTask;

  String get lblPausedTheTask;

  String get lblResumedTheTask;

  String get lblCompletedTheTask;

  String get lblSharedAnImage;

  String get lblSharedADocument;

  String get lblSharedALocation;

  String get lblShared;

  String get lblTaskUpdates;

  String get lblTaskUpdate;

  String get lblTaskIsCompleted;

  String get lblPleaseCheckInToShareLocationOrFile;

  String get lblPleaseCheckInToSharePhoto;

  String get lblPleaseEnterMessage;

  String get lblPleaseCheckInToSendMessage;

  String get lblOnlyPDFFilesAreAllowed;

  String get lblUnableToPickFile;

  String get lblUnableToGetCurrentLocation;

  String get lblUnableToTakePhoto;

  String get lblMessageCannotBeEmpty;

  String get lblImage;

  String get lblUnableToGetFile;

  String get lblPages;

  String get lblPleaseSelectAClientToPlaceOrder;

  String get lblOrderPlacedSuccessfully;

  String get lblCart;

  String get lblCartIsEmpty;

  String get lblPlacingOrderPleaseWait;

  String get lblOrderingFor;

  String get lblNotes;

  String get lblTotal;

  String get lblItems;

  String get lblPlaceOrder;

  String get lblPleaseCheckInFirst;

  String get lblAreYouSureYouWantToPlaceTheOrder;

  String get lblPasswordChangedSuccessfully;

  String get lblChangePassword;

  String get lblConfirmNewPassword;

  String get lblOldPassword;

  String get lblOldPasswordIsRequired;

  String get lblNewPasswordIsRequired;

  String get lblMinimumLengthIs;

  String get lblConfirmPasswordIsRequired;

  String get lblPasswordDoesNotMatch;

  String get lblTeamChat;

  String get lblChatModuleIsNotEnabled;

  String get lblInvalidFileTypePleaseSelectAPngOrJpgFile;

  String get lblFailedToUploadImage;

  String get lblUnableToCheckDeviceStatus;

  String get lblRequestADocument;

  String get lblNoDocumentTypesAdded;

  String get lblDocumentType;

  String get lblDocumentRequestSubmittedSuccessfully;

  String get lblPleaseSelectADocumentType;

  String get lblNoExpenseTypesAreConfigured;

  String get lblExpenseRequests;

  String get lblUnableToUploadTheFile;

  String get lblSuccessfullyDeleted;

  String get lblRequestedOn;

  String get lblUnableToSendAnOTPTryAgainLater;

  String get lblOtpIsRequired;

  String get lblWrongOTP;

  String get lblUnableToChangeThePassword;

  String get lblCannotBeBlank;

  String get lblPhoneNumberDoesNotExists;

  String get lblSelectClient;

  String get lblPleaseChooseClient;

  String get lblFormSubmittedSuccessfully;

  String get lblPleaseEnter;

  String get lblPleaseEnterValidEmail;

  String get lblPleaseEnterValidURL;

  String get lblPleaseEnterValidNumber;

  String get lblForms;

  String get lblNoFormsAssigned;

  String get lblFormId;

  String get lblSubmissions;

  String get lblTrackedTime;

  String get lblGettingYourIPAddress;

  String get lblGettingYourAddress;

  String get lblUnableToGetAddress;

  String get lblIsYourIPAddress;

  String get lblSite;

  String get lblAttendanceType;

  String get lblPleaseEnterYourLateReason;

  String get lblInvalid;

  String get lblBreakModuleIsNotEnabled;

  String get lblAreYouSureYouWantToTakeABreak;

  String get lblBreak;

  String get lblEarlyCheckOut;

  String get lblPleaseEnterYourEarlyCheckOutReason;

  String get lblEarlyCheckOutReason;

  String get lblAreYouSureYouWantToResume;

  String get lblLateReason;

  String get lblScanQRToCheckIn;

  String get lblClientVisits;

  String get lblTotalVisits;

  String get lblYouAreOnBreakPleaseEndYourBreakToMarkVisit;

  String get lblOrders;

  String get lblProcessing;

  String get lblSuccessfully;

  String get lblAppliedOn;

  String get lblDuration;

  String get lblNoLeaveTypesAreConfigured;

  String get lblLeaveRequests;

  String get lblType;

  String get lblApprovedBy;

  String get lblApprovedOn;

  String get lblRequestLoan;

  String get lblEnterAmount;

  String get lblAmountCannotBeEmpty;

  String get lblLoanRequestSubmittedSuccessfully;

  String get lblLoans;

  String get lblOneTapLogin;

  String get lblLooksLikeYouAlreadyRegisteredThisDeviceYouCanUseOneTapLogin;

  String get lblIfYouWantToLoginWithDifferentAccountPleaseContactAdministrator;

  String get lblPleaseLoginToContinue;

  String get lblInvalidEmployeeId;

  String get lblEmployeeIdDoesNotExists;

  String get lblNoticeBoardIsNotEnabled;

  String get lblNoNoticesFound;

  String get lblPostedOn;

  String get lblBackOnline;

  String get lblServerUnreachable;

  String get lblOfflineMode;

  String get lblYouAreInOfflineMode;

  String
      get lblOptionsWillBeLimitedUntilYouAreBackOnlinePleaseCheckYourInternetConnection;

  String get lblOrderId;

  String get lblOrderDate;

  String get lblTotalItems;

  String get lblViewDetails;

  String get lblOrderDetails;

  String get lblProducts;

  String get lblProduct;

  String get lblQuantity;

  String get lblPrice;

  String get lblSlNo;

  String get lblOrderHistory;

  String get lblFilterByDate;

  String get lblFilter;

  String get lblNoOrdersFound;

  String get lblCancelled;

  String get lblTodayOrders;

  String get lblViewAll;

  String get lblNoOrders;

  String get lblChooseProductCategory;

  String get lblNoData;

  String get lblId;

  String get lblChooseProducts;

  String get lblCode;

  String get lblAddToCart;

  String get lblCollectPayment;

  String get lblSelectPaymentMode;

  String get lblSuccessfullyCreated;

  String get lblPaymentCollections;

  String get lblActivityPermission;

  String get lblWhyActivityPermissionIsRequired;

  String get lblContinue;

  String get lblOpenSettings;

  String get lblGrantPermission;

  String get lblLocationPermission;

  String get lblWhyLocationPermissionIsRequired;

  String get lblModulesStatus;

  String get lblChangeTheme;

  String get lblColorChangedSuccessfully;

  String get lblRecent;

  String get lblNoVisitsAdded;

  String get lblTodayVisits;

  String get lblToMarkVisitsPleaseAddClient;

  String get lblAddClient;

  String get lblUnableToGetModuleStatus;

  String get lblExpenseModuleIsNotEnabled;

  String get lblLoanModuleIsNotEnabled;

  String get lblLoanRequests;

  String get lblLeaveModuleIsNotEnabled;

  String get lblDocumentModuleIsNotEnabled;

  String get lblDocumentRequests;

  String get lblPaymentCollectionModuleIsNotEnabled;

  String get lblPaymentCollection;

  String get lblVisitModuleIsNotEnabled;

  String get lblWeAreUnableToConnectToTheServerPleaseTryAgainLater;

  String get lblRetry; /*

  String get lblBuyThisAppNow;*/

  String get lblYouAreLateYourShiftStartsAt;

  String get lblYourShiftStartsAt;

  String get lblYouAreOnBreak;

  String get lblYouCheckedInAt;

  String get lblYouCheckedOutAt;

  String get lblGoodAfternoon;

  String get lblGoodEvening;

  String get lblScanQRToCheckOut;

  String get lblPleaseSetupYourFingerprint;

  String get lblApprovals;

  String get lblFilters;

  String get lblUnsavedChanges;

  String get lblYouHaveUnsavedChangesDoYouWantToDiscard;

  String get lblDiscard;

  String get lblPleaseFillAllRequiredFields;

  String get lblIsRequired;

  String get lblFailedToSubmitForm;

  String get lblAnErrorOccurredWhileSubmittingTheForm;

  String get lblOverdue;

  String get lblNoFieldsAvailable;

  String get lblForm;

  String get lblSubmittingForm;

  String get lblError;

  String get lblSubmitted;

  // Loan Screen Keys
  String get lblEditLoanRequest;

  String get lblSelectLoanType;

  String get lblLoadingLoanTypes;

  String get lblLoanDetails;

  String get lblLoanAmount;

  String get lblEnterLoanAmount;

  String get lblTenureMonths;

  String get lblEnterTenure;

  String get lblCalculateEMI;

  String get lblPurpose;

  String get lblEnterPurpose;

  String get lblRemarksOptional;

  String get lblEnterRemarks;

  String get lblExpectedDisbursementDate;

  String get lblEMICalculation;

  String get lblMonthlyEMI;

  String get lblTotalAmount;

  String get lblTotalInterest;

  String get lblImportantNotes;

  String get lblSubmitRequest;

  String get lblUpdateRequest;

  String get lblSaveAsDraft;

  String get lblInterestRate;

  String get lblEMIAmount;

  String get lblTenure;

  String get lblLoanRequestUpdatedSuccessfully;

  String get lblLoanRequestSavedAsDraft;

  // Module Names Keys
  String get lblAttendance;

  String get lblTaskSystem;

  String get lblClientVisit;

  String get lblProductOrdering;

  String get lblDynamicForm;

  String get lblGeoFencing;

  String get lblIPBasedAttendance;

  String get lblUIDLogin;

  String get lblOfflineTracking;

  String get lblPayrollPayslip;

  String get lblSalesTarget;

  String get lblDigitalID;

  String get lblQRCodeAttendance;

  String get lblDynamicQRAttendance;

  String get lblBreakSystem;

  String get lblAIChatbot;

  String get lblBiometricVerification;

  String get lblCalendar;

  String get lblRecruitment;

  String get lblAccounting;

  String get lblManagerApp;

  String get lblFaceAttendance;

  String get lblAssetsManagement;

  String get lblDisciplinaryActions;

  String get lblHRPolicies;

  String get lblGoogleRecaptcha;

  String get lblSystemBackup;

  String get lblLearningManagement;

  String get lblFaceAttendanceDevice;

  String get lblRefreshing;

  String get lblRefreshed;

  // Demo Mode Keys
  String get lblDemoModeActive;

  String get lblDemoMode;

  String get lblLoginToAdminPanel;

  String get lblUseTenantLoginButton;

  String get lblVisitAdminPanel;

  String get lblDemoDetails;

  String get lblWelcomeTo;

  String get lblCreateDemoAccount;

  String get lblEnterOrganization;

  String get lblSelectOrganizationTitle;

  String get lblUseAcmeAsOrgName;

  String get lblEnterOrganizationNameOrDomain;

  String get lblEnterOrganizationName;

  String get lblOrganizationNotFound;

  String get lblFieldRequired;

  // Navigation & Dashboard Keys
  String get lblLeaves;

  String get lblDocuments;

  String get lblRegularization;

  String get lblPayroll;

  String get lblAssets;

  String get lblDisciplinary;

  String get lblGoodNight;

  String get lblQuickActions;

  String get lblHaveAProductiveDay;

  // Leave Management Keys
  String get lblLeaveManagement;

  String get lblNewLeave;

  String get lblLeaveBalance;

  String get lblNoLeaveBalanceAvailable;

  String get lblCompOff;

  String get lblViewAllLeaveTypes;

  String get lblAllLeaveBalances;

  String get lblCompensatoryOff;

  String get lblMyLeaves;

  String get lblStatistics;

  String get lblTeamCalendar;

  String get lblEntitled;

  String get lblUsed;

  String get lblCarriedForward;

  String get lblAdditional;

  String get lblThisYearOverview;

  String get lblUpcomingLeaves;

  String get lblDay;

  String get lblOf;

  // Leave Statistics Keys
  String get lblLeaveStatistics;

  String get lblSelectYear;

  String get lblNoLeaveDataAvailable;

  String get lblLeavesByType;

  String get lblErrorLoadingStatistics;

  String get lblNoStatisticsAvailable;

  // Leave Requests Filter Keys
  String get lblFilterLeaveRequests;


  String get lblResetFilters;

  String get lblAllTypes;

  String get lblErrorLoadingRequests;

  String get lblNewRequest;

  String get lblNoLeaveRequests;

  String get lblApplyForLeaveToSeeHere;

  // Team Calendar Keys
  String get lblNoTeamLeaves;

  String get lblNoTeamLeavesMessage;

  String get lblTeamMembersOnLeave;

  String get lblLegend;

  String get lblHasLeaves;

  String get lblThisMonthSummary;

  String get lblTotalLeaves;

  String get lblTeamMembers;

  String get lblCalendarView;

  String get lblListView;

  String get lblErrorLoadingCalendar;

  String get lblNoCalendarData;

  // Leave Request Form Keys
  String get lblSelectDate;

  String get lblPleaseSelectLeaveType;

  String get lblHalfDayDateError;

  String get lblFirstHalf;

  String get lblSecondHalf;

  String get lblFileSizeLimit;

  String get lblErrorLoadingLeaveTypes;

  String get lblErrorLoadingFormData;

  String get lblEditLeaveRequest;

  String get lblNewLeaveRequest;

  String get lblToDate;

  String get lblHalfDayLeave;

  String get lblHalfDayType;

  String get lblGoingAbroad;

  String get lblReasonForLeave;

  String get lblEnterReasonForLeave;

  String get lblEmergencyContactOptional;

  String get lblContactPersonName;

  String get lblEmergencyPhoneOptional;

  String get lblContactPhoneNumber;

  String get lblAbroadLocation;

  String get lblEnterDestination;

  String get lblSupportingDocument;

  String get lblDocumentRequired;

  String get lblUploadDocument;

  String get lblUploadedDocument;

  String get lblAvailableBalanceDays;

  String get lblUnableToLoadBalance;

  String get lblUseCompensatoryOff;

  String get lblCompensatoryOffsApplied;

  String get lblCompOffsCannotBeModified;

  String get lblCompOffWillBeApplied;

  String get lblCompOffsSelected;

  String get lblLeaveDays;

  String get lblCompOffApplied;

  String get lblFromLeaveBalance;

  String get lblSelectLeaveType;

  String get lblLoadingLeaveTypes;

  String get lblPleaseSelectHalfDayType;

  String get lblPleaseEnterReasonForLeave;

  String get lblInsufficientBalance;

  String get lblSelectCompensatoryOffs;

  String get lblCompOffDaysCannotExceed;

  String get lblLeaveRequestUpdatedSuccess;

  String get lblLeaveRequestSubmittedSuccess;

  String get lblFailedToSubmitLeaveRequest;

  // Leave Request Detail Keys
  String get lblCancelLeaveRequest;

  String get lblConfirmCancelLeave;

  String get lblCancellationReasonOptional;

  String get lblNoKeepIt;

  String get lblYesCancel;

  String get lblFailedToCancelLeave;

  String get lblCannotOpenDocument;

  String get lblLeaveRequested;

  String get lblPendingApproval;

  String get lblAwaitingReview;

  String get lblLeaveRequestDetails;

  String get lblLeaveDetails;

  String get lblStatusTimeline;

  String get lblErrorLoadingDetails;

  String get lblLeaveRequestNotFound;

  String get lblTotalDays;

  String get lblCompensatoryOffUsed;

  String get lblTotalCompOffsUsed;

  String get lblAppliedCompOffs;

  String get lblEmergencyContact;

  String get lblTravelInformation;

  String get lblDestination;

  String get lblTapToViewDocument;

  String get lblCancelRequestBtn;

  String get lblLeaveRequestCancelledSuccess;

  String get lblExpires;

  String get lblReason;

  // Compensatory Off Keys
  String get lblEditCompOff;

  String get lblRequestCompOff;

  String get lblCompOffCalculation;

  String get lblCompOffDetails;

  String get lblFilterCompensatoryOffs;

  String get lblDeleteCompOff;

  String get lblConfirmDeleteCompOff;

  String get lblCompOffRequested;

  String get lblExpired;

  String get lblCompOffDeletedSuccess;

  String get lblPleaseSelectWorkedDate;

  String get lblWorkedDateCannotBeFuture;

  String get lblHoursWorkedMinimum;

  String get lblPleaseEnterReason;

  String get lblCompOffUpdatedSuccess;

  String get lblCompOffRequestedSuccess;

  String get lblFailedToSubmitCompOff;

  String get lblFailedToDeleteCompOff;

  // Compensatory Off Form Keys
  String get lblDateWorked;

  String get lblSelectDateWorkedOvertime;

  String get lblHoursWorked;

  String get lblEnterHours;

  String get lblPleaseEnterHoursWorked;

  String get lblHoursMustBeAtLeastOne;

  String get lblHoursCannotExceedTwentyFour;

  String get lblCompOffDaysEarned;

  String get lblNotEligible;

  String get lblDaysWillBeCredited;

  String get lblMinimumFourHoursRequired;

  String get lblReasonForOvertime;

  String get lblExplainOvertimeReason;

  String get lblReasonMinLength;

  // Compensatory Off List Keys
  String get lblWorkedOn;

  String get lblHoursWorkedLabel;

  String get lblExpiresOn;

  String get lblUsedOn;

  String get lblExpiringSoonUse;

  String get lblCompOffBalance;

  String get lblNoBalanceDataAvailable;

  String get lblShowingStatusCompOffs;

  String get lblErrorLoadingCompOffs;

  String get lblNoCompensatoryOffs;

  String get lblRequestCompOffToSeeHere;

  // Compensatory Off Detail Keys
  String get lblErrorLoadingCompOffDetails;

  String get lblCompOffNotFound;

  String get lblCompOffExpired;

  String get lblCompOffExpiredOn;

  String get lblExpiringSoon;

  String get lblDaysRemainingUse;

  String get lblWorkedDate;

  String get lblCompOffDays;

  String get lblExpiryDate;

  String get lblUsedForLeave;

  String get lblLeaveDates;

  // Common Keys
  String get lblDelete;

  String get lblEdit;

  String get lblAvailable;

  String get lblAll;


  // Expense Management Keys (additional)
  String get lblExpenseDetails;

  String get lblSelectExpenseType;

  String get lblEnterRemarksOrDescription;

  String get lblUploadReceiptDocument;

  String get lblTapToSelectImageFile;

  String get lblPleaseSelectDate;

  String get lblPleaseSelectExpenseType;

  String get lblSubmitExpense;

  String get lblExpenseManagement;

  String get lblNewExpense;

  String get lblConfirmCancelExpense;

  String get lblYourExpenseRequestsWillAppearHere;

  // General/Common (new localization keys)
  String get lblGeneral;

  // Password Screen
  String get lblPasswordSettings;

  String get lblEnterOldPassword;

  String get lblEnterNewPassword;

  String get lblConfirmNewPasswordPlaceholder;

  String get lblPasswordRequirements;

  String get lblMinimumCharactersRequired;

  // Support Component
  String get lblCallSupport;

  String get lblMailSupport;

  String get lblWhatsApp;

  String get lblVisitWebsite;

  String get lblUnableToMakePhoneCall;

  String get lblUnableToSendEmail;

  String get lblUnableToOpenWhatsApp;

  String get lblUnableToOpenWebsite;

  // Document Management
  String get lblDocumentManagement;

  String get lblMyDocuments;

  String get lblRequestDocument;

  String get lblValid;

  String get lblGenerated;

  String get lblAlerts;

  String get lblExpiredDocuments;

  // Approval Screen
  String get lblApprovedAmount;

  String get lblAttachment;

  // Filters & Status
  String get lblAllStatus;

  String get lblAllYears;


  String get lblWithdrawn;

  String get lblProcessed;

  String get lblPaid;

  String get lblDraft;

  String get lblFilterPayrollRecords;

  String get lblFilterPayslips;


  // Attendance Regularization
  String get lblNoRegularizationRequestsFound;

  String get lblCreateRequest;

  String get lblRequestDetails;

  String get lblRequestInformation;

  // Form Builder
  String get lblErrorLoadingForms;

  String get lblThisFormIsOverdue;

  String get lblNoFormsFound;

  // Modules Screen
  String get lblFieldSales;

  String get lblAgoraVideoCall;

  String get lblLocationManagement;

  String get lblOcConnect;

  String get lblSiteAttendance;

  String get lblDataImportExport;

  String get lblSosEmergency;

  // Loan
  String get lblAdminRemarks;

  // Attendance History
  String get lblNoAttendanceRecords;

  String get lblAttendanceRecordsWillAppearHere;

  String get lblHoursOT;

  String get lblShiftInformation;

  String get lblHoursBreakdown;

  String get lblWorking;

  String get lblBreaks;

  String get lblOvertime;

  String get lblTimingIssues;

  String get lblLateBy;

  String get lblEarlyCheckoutBy;

  String get lblSession;

  String get lblOngoing;

  String get lblDailyActivities;

  // Document Management
  String get lblSearchByTitleOrNumber;

  String get lblExpiry;

  String get lblClearAll;

  String get lblNA;

  String get lblNumber;

  String get lblIssued;

  String get lblDownload;

  String get lblNoDocuments;

  String get lblDocumentsWillAppearHere;

  String get lblUnknown;

  String get lblVerificationStatus;

  String get lblExpiryStatus;

  String get lblDownloadingDocument;

  String get lblDocumentFileNotAvailable;

  String get lblFailedToDownloadDocument;

  String get lblDocumentDetails;

  String get lblDocumentInformation;

  String get lblFileName;

  String get lblFileType;

  String get lblFileSize;

  String get lblIssueDate;

  String get lblPendingVerification;

  String get lblVerifiedBy;

  String get lblVerifiedOn;

  String get lblDocumentExpired;

  String get lblDocumentValid;

  String get lblIssuingInformation;

  String get lblIssuingAuthority;

  String get lblCountry;

  String get lblPlace;

  String get lblAdditionalNotes;

  String get lblPreparingDownload;

  String get lblFailedToLoadStatistics;

  String get lblEnterRemarksOrReason;

  String get lblCategory;

  String get lblSelectDocumentType;

  String get lblSelectTheTypeOfDocument;

  String get lblProvideReasonForRequest;

  String get lblRequestReviewedByHR;

  String get lblNotifiedWhenReady;

  // Loan Module
  String get lblYourLoanRequestsWillAppearHere;
  String get lblErrorLoadingLoanDetails;
  String get lblErrorCalculatingEMI;
  String get lblInterestRatePercentage;
  String get lblMaxAmountFormat;
  String get lblUpToMonths;
  String get lblPleaseEnterValidAmount;
  String get lblAmountExceedsMaximumLimit;
  String get lblTenureCannotBeEmpty;
  String get lblPleaseEnterValidTenure;
  String get lblMinimumTenure;
  String get lblMaximumTenure;
  String get lblPurposeIsRequired;
  String get lblPurposeMinimumLength;
  String get lblPurposeMustBeAtLeast5Characters;
  String get lblLoanReviewNote1;
  String get lblLoanReviewNote2;
  String get lblLoanReviewNote3;
  String get lblLoanReviewNote4;
  String get lblYourLoanRequestWillBeReviewedByManagement;
  String get lblApprovalTimeMayVaryBasedOnLoanAmount;
  String get lblYouWillBeNotifiedOnceRequestIsProcessed;
  String get lblEnsureAllDetailsAreAccurateBeforeSubmitting;
  String get lblMonths;
  String get lblHistory;
  String get lblMax;
  String get lblUpTo;
  String get lblAreYouSureYouWantToDeleteThisDraft;
  String get lblDraftDeletedSuccessfully;
  String get lblUnknownError;
  String get lblRepayments;
  String get lblLoan;
  String get lblRequested;
  String get lblMonthsFormat;
  String get lblOutstandingAmount;
  String get lblDisbursement;
  String get lblExpectedDate;
  String get lblActualDate;
  String get lblApprover;
  String get lblReviewer;
  String get lblTimeline;
  String get lblCreatedAt;
  String get lblUpdatedAt;
  String get lblApprovedAt;
  String get lblNoRepaymentsYet;
  String get lblRepaymentScheduleAfterDisbursement;
  String get lblPaidOn;
  String get lblDueDate;
  String get lblPrincipal;
  String get lblInterest;
  String get lblNoHistoryAvailable;
  String get lblRequestedAmount;
  String get lblTimesMonths;
  String get lblOutstanding;

  // Payroll Module
  String get lblCurrentMonthOverview;
  String get lblTotalEarnings;
  String get lblTotalDeductions;
  String get lblMyPayslips;
  String get lblSalaryStructure;
  String get lblPayrollRecords;
  String get lblModifiers;
  String get lblRecentPayslips;
  String get lblCreatedOnDate;
  String get lblNoPayslipsAvailable;
  String get lblPayslipsWillAppearMessage;
  String get lblErrorLoadingData;
  String get lblSelectMonth;
  String get lblSearchPayslips;
  String get lblFailedToLoadPayslips;
  String get lblInvalidPayslipId;
  String get lblDownloadingPayslip;
  String get lblPayslipDownloadSuccess;
  String get lblPayslipDownloadFailed;
  String get lblNoPayslipsMatch;
  String get lblClearFilters;
  String get lblPayslipDetails;
  String get lblPayslipCode;
  String get lblNetSalary;
  String get lblBasicSalary;
  String get lblBenefits;
  String get lblEarningsAndBenefits;
  String get lblTotalBenefits;
  String get lblAttendanceSummary;
  String get lblWorkedDays;
  String get lblAbsentDays;
  String get lblTotalComponents;
  String get lblYourSalaryBreakdown;
  String get lblComponentsCount;
  String get lblTaxable;
  String get lblPercentage;
  String get lblFixed;
  String get lblValue;
  String get lblEffectiveFrom;
  String get lblEffectiveTo;
  String get lblActive;
  String get lblInactive;
  String get lblNoSalaryStructureFound;
  String get lblSalaryStructureNotConfigured;
  String get lblErrorLoadingSalaryStructure;
  String get lblGrossSalary;
  String get lblWorked;
  String get lblNoPayrollRecordsFound;
  String get lblPayrollRecordsMessage;
  String get lblErrorLoadingRecords;
  String get lblPayslipsGeneratedMessage;
  String get lblErrorLoadingPayslips;

  // Additional Payslip Detail Keys
  String get lblPayslipActions;
  String get lblDownloadPDF;
  String get lblPrint;
  String get lblOverview;
  String get lblWeekends;
  String get lblAdditionalDetails;
  String get lblLateDays;
  String get lblEarlyCheckoutDays;
  String get lblOvertimeDays;
  String get lblNoEarnings;
  String get lblNoAdditionalEarnings;
  String get lblEarningsBreakdown;
  String get lblNoDeductions;
  String get lblNoDeductionsForPeriod;
  String get lblDeductionsBreakdown;
  String get lblDownloading;
  String get lblLoadingPayslipDetails;
  String get lblPayslipDownloadedSuccessfully;
  String get lblPayslipNotFound;
  String get lblPrintFeatureComingSoon;
  String get lblStoragePermissionRequired;
  String get lblPayslipDownloadedTo;
  String get lblDownloadsFolder;
  String get lblDocumentsFolder;
  String get lblFailedToDownloadPayslip;
  String get lblNoAppToOpenPDF;
  String get lblPDFFileNotFound;
  String get lblFailedToOpenPDF;

  // Payroll Record Detail Keys
  String get lblSalaryBreakdown;
  String get lblTaxAmount;
  String get lblOvertimeHours;
  String get lblNoEarningsRecorded;
  String get lblNoDeductionsRecorded;
  String get lblPayrollCycle;
  String get lblCycleName;
  String get lblCycleCode;
  String get lblFrequency;
  String get lblPeriodStart;
  String get lblPeriodEnd;
  String get lblPayDate;
  String get lblRejectionReason;
  String get lblPayrollRecord;
  String get lblErrorLoadingRecord;
  String get lblUnexpectedError;
  String get lblRecordNotFound;

  // Server Unreachable Screen Keys
  String get lblTips;
  String get lblCheckYourInternetConnection;
  String get lblMakeSureServerIsRunning;
  String get lblContactITAdministrator;
  String get lblReconnecting;
  String get lblAppealWithdrawnSuccessfully;
  String get lblConfirmWithdraw;
  String get lblWithdrawAppealConfirm;
  String get lblSelectWarning;
  String get lblPleaseSelectWarning;
  String get lblPleaseEnterStatement;
  String get lblWarningToAppeal;
  String get lblNewAppeal;
  String get lblEditAppeal;

  // Disciplinary Actions Keys - Warnings
  String get lblWarningType;
  String get lblWarningNumber;
  String get lblWarningDetails;
  String get lblWarningInformation;
  String get lblAcknowledgeWarning;
  String get lblEffectiveDate;
  String get lblIssuedBy;
  String get lblIssuedOn;
  String get lblSubject;
  String get lblImprovementRequired;
  String get lblConsequences;
  String get lblAppealDeadline;
  String get lblNoWarningsFound;
  String get lblNoWarningsYet;
  String get lblWarningAcknowledged;
  String get lblConfirmAcknowledge;
  String get lblAcknowledgeWarningConfirm;
  String get lblVerbalWarning;
  String get lblWrittenWarning;
  String get lblFinalWarning;
  String get lblSuspension;
  String get lblTermination;
  String get lblAppealed;

  // Assets Keys
  String get lblAssetDetails;
  String get lblAssetInformation;
  String get lblAssetTag;
  String get lblReportIssue;
  String get lblResources;
  String get lblManufacturer;
  String get lblModel;
  String get lblSerialNumber;
  String get lblCondition;
  String get lblPurchaseDate;
  String get lblWarrantyExpiry;
  String get lblIssuesAndMaintenance;
  String get lblAssigned;
  String get lblReturned;
  String get lblMyAssets;
  String get lblAssignmentHistory;
  String get lblIssueDescription;
  String get lblSubmitReport;
  String get lblNoAssetsFound;
  String get lblNoAssetsAssigned;
  String get lblAssetNotFound;
  String get lblScanAssetQR;
  String get lblPointCameraAtQR;
  String get lblIssueReportedSuccessfully;
  String get lblPleaseEnterDescription;
  String get lblIssuePriority;
  String get lblLow;
  String get lblMedium;
  String get lblHigh;
  String get lblCritical;
  String get lblIssueType;
  String get lblDamage;
  String get lblMalfunction;
  String get lblMaintenance;
  String get lblLost;
  String get lblStolen;
  String get lblAssignedOn;
  String get lblReturnedOn;
  String get lblAssignedTo;
  String get lblNoHistoryFound;
  String get lblNew;
  String get lblGood;
  String get lblFair;
  String get lblPoor;

  // HR Policies Keys
  String get lblFilterByCategory;
  String get lblAllCategories;
  String get lblPolicyStatistics;
  String get lblTotalPolicies;
  String get lblAcknowledged;
  String get lblNoPolicies;
  String get lblNoPoliciesFound;
  String get lblAcknowledgePolicy;
  String get lblPolicyDetails;
  String get lblPolicyInformation;
  String get lblPolicyContent;
  String get lblEffectiveDatePolicy;
  String get lblExpiryDatePolicy;
  String get lblAssignedDate;
  String get lblMandatory;
  String get lblAcknowledgmentDetails;
  String get lblHasDocument;
  String get lblPolicyAcknowledged;
  String get lblConfirmAcknowledgePolicy;
  String get lblAcknowledgePolicyConfirm;
  String get lblPolicyCategory;
  String get lblGeneralPolicy;
  String get lblHRPolicy;
  String get lblSafetyPolicy;
  String get lblITPolicy;
  String get lblFinancePolicy;
  String get lblCompliancePolicy;
  String get lblAcknowledgedOn;
  String get lblDeadlinePassed;
  String get lblDaysRemaining;

  // Additional Assets Keys
  String get lblSearchAssets;
  String get lblInRepair;
  String get lblDamaged;
  String get lblTryAdjustingYourSearch;
  String get lblFailedToLoadAssets;
  String get lblNoIssuesReported;
  String get lblReportIssuesPrompt;
  String get lblNoDocumentsAvailable;
  String get lblAllIssuesAndMaintenance;
  String get lblWarrantyExpiresIn;
  String get lblViewAllIssues;

  // Asset QR Scanner & Report Issue Keys
  String get lblAssetFound;
  String get lblNoAssetFoundWithQR;
  String get lblFailedToScanQR;
  String get lblScanningAsset;
  String get lblPositionQRCodeInFrame;
  String get lblScannerWillAutoDetect;
  String get lblFailedToReportIssue;
  String get lblDescribeIssueInDetail;
  String get lblPleaseDescribeIssue;
  String get lblDescriptionMinLength;
  String get lblProvideDetailToResolve;

  // Digital ID Card Keys
  String get lblEmployeeIDCard;
  String get lblEmployeeID;
  String get lblScanForVerification;

  // Attendance Regularization Keys
  String get lblFilterRegularization;
  String get lblRegularizationType;
  String get lblRegularizationRequests;
  String get lblEditRegularization;
  String get lblNewRegularizationRequest;
  String get lblSelectType;
  String get lblPleaseSelectType;
  String get lblExplainReasonPlaceholder;
  String get lblAttachmentsOptional;
  String get lblPleaseProvideReason;
  String get lblSubmittedOn;
  String get lblRequestedTimes;
  String get lblCheckInTime;
  String get lblCheckOutTime;
  String get lblNotSpecified;
  String get lblActualAttendance;
  String get lblMissing;
  String get lblApprovalInformation;
  String get lblReviewedBy;
  String get lblReviewedOn;
  String get lblConfirmDelete;
  String get lblAreYouSureToDeleteRequest;

  // Notice Board Keys
  String get lblNoTitle;
  String get lblNoNotices;
  String get lblNoNoticesAvailable;
  String get lblNoticeDetails;

  // Calendar Keys
  String get lblNoEvents;
  String get lblNoEventsForSelectedDate;
  String get lblEventDetails;
  String get lblAddEvent;
  String get lblEditEvent;
  String get lblStartDate;
  String get lblEndDate;
  String get lblStartTime;
  String get lblEndTime;
  String get lblAllDayEvent;
  String get lblAttendees;
  String get lblSelectAttendees;
  String get lblUpdate;
  String get lblTitleIsRequired;
  String get lblEventTypeIsRequired;
  String get lblEventColor;
  String get lblMeetingLink;
  String get lblAttachments;
  String get lblSelect;

  // HR Policies Additional Keys
  String get lblShowAllPolicies;
  String get lblErrorLoadingPolicies;
  String get lblNoPendingPolicies;
  String get lblNoOverduePolicies;
  String get lblNoAcknowledgedPolicies;
  String get lblFailedToLoadDetails;

  // Attendance Regularization Additional Keys
  String get lblNoDatesAvailableForRegularization;
  String get lblFileSizeExceeds5MB;
  String get lblFailedToOpenAttachment;
  String get lblDeleteRequest;

  // Holidays Screen Keys
  String get lblFilterByType;
  String get lblGrouped;
  String get lblNoHolidaysFound;
  String get lblNoUpcomingHolidays;
  String get lblNoUpcomingHolidaysMessage;
  String get lblNoHolidaysToDisplay;
  String get lblOptionalHoliday;

  // Disciplinary Actions - Appeal Form Keys
  String get lblFileAppeal;
  String get lblAppealDetails;
  String get lblAppealReason;
  String get lblEnterAppealReason;
  String get lblPleaseEnterAppealReason;
  String get lblAppealReasonMinLength;
  String get lblYourStatement;
  String get lblProvideDetailedStatement;
  String get lblPleaseProvideStatement;
  String get lblStatementMinLength;
  String get lblSupportingDocumentsOptional;
  String get lblTapToSelectFiles;
  String get lblFilesSelected;
  String get lblAcceptedFormats;
  String get lblImportantInformation;
  String get lblAppealInfoBullet1;
  String get lblAppealInfoBullet2;
  String get lblAppealInfoBullet3;
  String get lblAppealInfoBullet4;
  String get lblSubmitAppeal;
  String get lblAppealSubmittedSuccessfully;
  String get lblFailedToSubmitAppeal;
  String get lblErrorPickingFiles;

  // Disciplinary Actions - Appeal Details Keys
  String get lblWithdrawAppeal;
  String get lblWithdrawAppealConfirmation;
  String get lblYesWithdraw;
  String get lblFailedToWithdrawAppeal;
  String get lblCouldNotOpenDocument;
  String get lblErrorOpeningDocument;
  String get lblErrorLoadingAppeal;
  String get lblAppealInformation;
  String get lblAppealNumber;
  String get lblAppealDate;
  String get lblRelatedWarning;
  String get lblReviewDecision;
  String get lblReviewComments;
  String get lblHearingInformation;
  String get lblHearingDate;

  // Disciplinary Actions - Appeals List Keys
  String get lblFilterAppeals;
  String get lblMyAppeals;
  String get lblUnderReview;
  String get lblApplyFilters;
  String get lblClear;
  String get lblErrorLoadingAppeals;
  String get lblNoAppeals;
  String get lblNoAppealsDescription;

  // Disciplinary Actions - Warning Details Keys
  String get lblAcknowledgeConfirmation;
  String get lblOptionalComments;
  String get lblWarningAcknowledgedSuccessfully;
  String get lblFailedToAcknowledgeWarning;
  String get lblCannotOpenAttachment;
  String get lblErrorOpeningAttachment;
  String get lblErrorLoadingWarning;
  String get lblAppealDeadlineMessage;
  String get lblAppealsCount;
  String get lblFiledOn;
  String get lblOutcome;

  // Disciplinary Actions - Warnings List Keys
  String get lblFilterWarnings;
  String get lblPendingAcknowledgment;
  String get lblActiveWarnings;
  String get lblDisciplinaryWarnings;
  String get lblErrorLoadingWarnings;
  String get lblNoWarnings;
  String get lblNoWarningsDescription;

  // Additional Missing Keys
  String get lblAcknowledge;
  String get lblReviewedDate;

  // Onboarding Screen Keys
  String get lblMyOnboardingChecklist;
  String get lblFileSizeExceedsLimit;
  String get lblErrorSelectingFile;
  String get lblCompletedOn;
  String get lblSubmittedPendingReview;
  String get lblUploadedFile;
  String get lblEnterAcknowledgement;
  String get lblAcknowledgeAddDetails;
  String get lblPleaseEnterAcknowledgement;
  String get lblSubmitTask;
  String get lblConfirmSubmission;
  String get lblFileUploaded;
  String get lblReplaceFile;
  String get lblUploadFile;
  String get lblMarkAsComplete;
  String get lblMarkTaskComplete;
  String get lblOnboardingNotAvailable;
  String get lblTaskTitle;
  String get lblDue;

  // Disciplinary & HR Policy Detail Screen Keys
  String get lblAddComments;
  String get lblFailedToAcknowledgePolicy;
  String get lblDocumentDownloadedTo;
  String get lblOpen;
  String get lblNoAppToOpenFile;
  String get lblFileNotFound;
  String get lblDeadline;
  String get lblDaysOverdue;
  String get lblDaysLeft;
  String get lblNoContentAvailable;
  String get lblYourComments;
  String get lblOverdueByDays;
  String get lblDueToday;
  String get lblDueTomorrow;
  String get lblDueInDays;
  String get lblPolicyNotFound;

  // Project Management Keys
  String get lblProjectManagement;
  String get lblNewProject;
  String get lblNoProjectsFound;
  String get lblProject;
  String get lblTimesheetCreated;
  String get lblTimesheetSubmitted;
  String get lblTaskCreated;
  String get lblTaskCompleted;
  String get lblTaskStarted;
  String get lblTaskStopped;
  String get lblElapsedHours;
  String get lblPleaseEnterTaskTitle;
  String get lblSelectTaskStatus;
  String get lblNewTask;
  String get lblCreateTask;
  String get lblMilestone;
  String get lblEstimatedHours;
  String get lblAssignTo;
  String get lblSelectMember;
  String get lblSelectPriority;
  String get lblNone;
  String get lblPriority;
  String get lblNoItemsFound;
}
