class APIRoutes {
  // BaseUrl to change
  // !!! For live deployment just paste the Url like this "https://{your_website_url}/api/V1/" !!!

  static const baseURL = "https://batimemo.com/api/V1/";

  static const domains = 'getTenantDomains';

  // Tenant/Organization Management (SaaS Mode)
  static const organizationLookup = 'organization/lookup';

  static const String getSalesTargets = 'salesTargets/getAll';

  static const String getHolidays = 'holidays/getAll';

  static const String getNotifications = 'notification/getAll';

  static const demoModeCheck = "checkDemoMode";

  static const meURL = 'account/me';

  static const profileURL = 'UserProfiles/';

  static const loginURL = 'login';

  static const loginWithUidURL = 'loginWithUid';

  static const forgotPasswordURL = 'forgotPassword';

  static const resetPasswordURL = 'resetPassword';

  static const changePasswordURL = 'changePassword';

  static const verifyOTPURL = 'verifyOTP';

  static const phoneNumberCheckURL = "checkPhoneNumber";

  static const userNameCheckURL = "checkUsername";

  static const getScheduleURL = 'getSchedule';

  static const checkDeviceUid = 'checkUid';

  static const addMessagingTokenURL = 'messagingToken';

  //Payroll & Payslips (New API)
  static const getPayrollRecords = 'payroll/my-records';
  static const getPayrollRecordDetails = 'payroll/my-records'; // + /{id}
  static const getMySalaryStructure = 'payroll/my-salary-structure';
  static const getMyPayrollStatistics = 'payroll/my-statistics';
  static const getMyPayslips = 'payroll/my-payslips';
  static const getPayslipDetails = 'payroll/my-payslips'; // + /{id}
  static const downloadPayslipPdf = 'payroll/download-payslip'; // + /{id}
  static const getMyAdjustments = 'payroll/my-modifiers';

  // Backward compatibility (Old Payslip API - deprecated)
  @Deprecated('Use getMyPayslips instead')
  static const getPayslipsURL = 'payroll/my-payslips';
  @Deprecated('Use downloadPayslipPdf instead')
  static const downloadPayslip = 'payroll/download-payslip';

  //Loan (Legacy - Deprecated)
  @Deprecated('Use loan repository with Dio API instead')
  static const getLoans = 'loan/getAll';
  @Deprecated('Use loan repository with Dio API instead')
  static const requestLoan = 'loan/create';
  @Deprecated('Use loan repository with Dio API instead')
  static const cancelLoanRequest = 'loan/cancel';

  // Loan Management (New Dio API)
  static const loanRequests = 'loan/requests';
  static const loanTypes = 'loan/types';
  static const loanCalculateEmi = 'loan/calculate-emi';
  static const loanStatistics = 'loan/statistics';

  //Sales & Products

  static const getSalesTarget = 'getSalesTarget';

  static const getSalesTargetHistory = 'getSalesTargetHistory';

  //Payment Collection
  static const getPaymentCollection = 'paymentCollection/getAll';

  static const createPaymentCollection = 'paymentCollection/create';

  //Task
  static const taskStatusUpdate = 'task/updateStatus';
  static const taskStatusUpdateFile = 'task/updateStatusFile';
  static const getTaskUpdates = 'task/getTaskUpdates';
  static const getTasks = 'task/GetAll';
  static const startTask = 'task/startTask';

  static const holdTask = 'task/holdTask';
  static const resumeTask = 'task/resumeTask';
  static const completeTask = 'task/completeTask';

  //Notice
  static const getNotices = 'notice/getAll';

  //Product
  static const getProductsURL = 'product/getAll';

  static const getProductCategoriesURL = 'product/getCategories';

  static const getProductsByCategoryURL = 'product/getProductsByCategory';

  //Order
  static const placeOrderURL = 'order/create';

  static const getOrdersHistoryURL = 'order/getHistory';

  static const getOrderCounts = 'order/getOrdersCount';

  //Document Requests
  static const getDocumentTypesURL = 'documentRequest/getDocumentTypes';

  static const createDocumentRequestURL = 'documentRequest/create';

  static const getDocumentRequestsURL = 'documentRequest/getAll';

  static const cancelDocumentRequestURL = 'documentRequest/cancel';

  static const getDocumentFileUrl = 'documentRequest/getFilePath';

  //Forms
  static const getForms = 'forms/getAssignedForms';
  static const submitForm = 'forms/submitForm';

  //Visits
  static const createVisitURL = 'visit/create';
  static const getVisitsHistoryURL = 'visit/getHistory';

  static const getVisitsCount = 'visit/getVisitsCount';

  //Settings
  static const getAppSettings = 'settings/getAppSettings';

  static const getModuleSettings = 'settings/getModuleSettings';

  //Dashboard
  static const getDashboardData = 'getDashboardData';

  //Leave
  static const getLeaveTypesURL = 'getLeaveTypes';
  static const addLeaveRequest = 'createLeaveRequest';
  static const uploadLeaveDocument = 'uploadLeaveDocument';
  static const getLeaveRequests = 'getLeaveRequests';
  static const cancelLeaveRequest = 'cancelLeaveRequest';

  //Device
  static const checkDevice = 'checkDevice';
  static const validateDevice = 'validateDevice';
  static const registerDevice = 'registerDevice';
  static const updateDeviceStatus = 'updateDeviceStatus';

  static const createDemoUser = 'createDemoUser';

  //Attendance
  static const checkInOut = 'attendance/checkInOut';
  static const updateAttendanceStatus = 'attendance/statusUpdate';
  static const checkAttendanceStatus = 'attendance/checkStatus';
  static const getAttendanceHistory = 'attendance/getHistory';

  static const startStopBreak = 'attendance/startStopBreak';

  static const validateGeoLocation = 'attendance/validateGeoLocation';

  static const validateIpAddress = 'attendance/validateIpAddress';

  static const canCheckOut = 'attendance/canCheckOut';

  static const setEarlyCheckoutReason = 'attendance/setEarlyCheckoutReason';

  //Qr Attendance
  static const verifyQr = 'qrAttendance/verifyCode';

  static const verifyDynamicQr = 'dynamicQr/verifyCode';

  //New Chat
  static const String getChats = 'chats';

  static const String getChatMessages = 'chats/messages';

  static const String getNewChatMessages = 'chats/getNewChatMessages';

  //User Search
  static const String searchUsers = 'user/search';
  static const String getAllUsers = 'user/getAll';
  static const String getUserInfo = 'user';

  static const String initiateCall = 'calls/initiate';
  static const String test = 'calls/testToken';

  static const searchUser = "user/search";

  //TeamChat
  static const postChat = 'chat/postChat';
  static const postChatImage = 'chat/postImageChat';

  //Expense
  static const getExpenseTypes = 'expense/getExpenseTypes';
  static const addExpenseRequest = 'expense/createExpenseRequest';
  static const cancelExpenseRequest = 'expense/cancel';
  static const getExpenseRequests = 'expense/getExpenseRequests';
  static const uploadExpenseDocument = 'expense/uploadExpenseDocument';

  //Client
  static const getClients = 'client/getAllClients';
  static const clientsSearch = 'client/search';
  static const addClient = 'client/create';

  //SignBoard
  static const addSignBoardRequest = 'signBoard/createRequest';

  //Offline
  static const bulkDeviceStatusUpdateURL =
      'offlineTracking/bulkDeviceStatusUpdate';
  static const bulkActivityStatusUpdateURL =
      'offlineTracking/bulkActivityStatusUpdate';

  //Face Attendance
  static const getFaceDataImageUrl = 'faceAttendance/getFaceDataAsImage';
  static const addOrUpdateFaceData = 'faceAttendance/addOrUpdateFaceData';
  static const getFaceData = 'faceAttendance/getFaceData';
  static const isFaceDataAdded = 'faceAttendance/isFaceDataAdded';

  //Approvals
  static const getApprovalLeaveRequests = 'approvals/leaveRequests';
  static const getApprovalExpenseRequests = 'approvals/expenseRequests';
  static const takeLeaveActionForApproval = 'approvals/leaveAction';
  static const takeExpenseActionForApproval = 'approvals/expenseAction';

  static const events = 'events';

  // My Onboarding Checklist
  static const String getMyOnboardingChecklist = 'myOnboardingChecklist'; // GET
  static const String updateMyChecklistItemStatus =
      'myOnboardingChecklist/{id}/updateStatus'; // POST - placeholder for ID
  static const String uploadMyChecklistFile =
      'myOnboardingChecklist/{id}/uploadFile'; // POST
  static const String downloadMyChecklistFile =
      'myOnboardingChecklist/{id}/downloadFile'; // GET

  // Project Management (PMCore)
  static const String projects = 'projects';
  static const String projectStatistics = 'projects/statistics';
  static const String projectTimesheets = 'projects/timesheets';
}
