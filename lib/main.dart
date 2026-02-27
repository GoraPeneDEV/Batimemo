import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/models/Assets/asset_assignment_model.dart';
import 'package:open_core_hr/models/Assets/asset_document_model.dart';
import 'package:open_core_hr/models/Assets/asset_model.dart';
import 'package:open_core_hr/models/Document/document_type_model.dart';
import 'package:open_core_hr/models/Expense/expense_type_model.dart';
import 'package:open_core_hr/models/leave_type_model.dart';
import 'package:open_core_hr/models/notice_model.dart';
import 'package:open_core_hr/routes.dart';
import 'package:open_core_hr/service/map_helper.dart';
import 'package:open_core_hr/service/module_service.dart';
import 'package:open_core_hr/service/permission_service.dart';
import 'package:open_core_hr/store/global_attendance_store.dart';
import 'package:open_core_hr/utils/app_constants.dart';
import 'package:open_core_hr/utils/app_theme.dart';

import 'package:provider/provider.dart';

import 'api/api_service.dart';
import 'firebase_options.dart';
import 'locale/app_localizations.dart';
import 'locale/languages.dart';
import 'screens/splash_screen.dart';
import 'service/SharedHelper.dart';
import 'store/AppStore.dart';
import 'store/asset_store.dart';
import 'store/form_builder_store.dart';
import 'store/payroll_store.dart';
import 'stores/leave_store.dart';
import 'stores/project_store.dart';
import 'utils/app_data_provider.dart';

AppStore appStore = AppStore();
GlobalAttendanceStore globalAttendanceStore = GlobalAttendanceStore();
FormBuilderStore formBuilderStore = FormBuilderStore();
PayrollStore payrollStore = PayrollStore();
AssetStore assetStore = AssetStore();
ApiService apiService = ApiService();
SharedHelper sharedHelper = SharedHelper();
MapHelper mapHelper = MapHelper();
PermissionService permissionService = PermissionService();
ModuleService moduleService = ModuleService();
late BaseLanguage language;

final DateFormat formatter = DateFormat('dd-MM-yyyy');

final DateFormat dateTimeFormatter = DateFormat('dd-MM-yyyy hh:mm a');

final DateFormat formDateFormatter = DateFormat('yyyy-MM-dd');

final timeFormat = DateFormat('hh:mm a');

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
  showFlutterNotification(message);
  log('Handling a background message ${message.messageId}');
}

late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !isWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
        ),
      ),
    );
  }
}

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  //Box 1
  Hive.registerAdapter(NoticeModelAdapter());
  await Hive.openBox<NoticeModel>('noticeBoardBox');

  //Box 2
  Hive.registerAdapter(LeaveTypeModelAdapter());
  await Hive.openBox<LeaveTypeModel>('leaveTypeBox');

  //Box 3
  Hive.registerAdapter(ExpenseTypeModelAdapter());
  await Hive.openBox<ExpenseTypeModel>('expenseTypeBox');

  //Box 4
  Hive.registerAdapter(DocumentTypeModelAdapter());
  await Hive.openBox<DocumentTypeModel>('documentTypeBox');

  //Asset Management Boxes (5-13)
  //Box 5 - Asset Model
  Hive.registerAdapter(AssetModelAdapter());
  //Box 6 - Asset Category Info
  Hive.registerAdapter(AssetCategoryInfoAdapter());
  //Box 7 - Assigned To Info
  Hive.registerAdapter(AssignedToInfoAdapter());
  //Box 8 - Asset Assignment Model
  Hive.registerAdapter(AssetAssignmentModelAdapter());
  //Box 9 - Assigned By Info
  Hive.registerAdapter(AssignedByInfoAdapter());
  //Box 10 - Returned To Info
  Hive.registerAdapter(ReturnedToInfoAdapter());
  //Box 11 - Asset Document Model
  Hive.registerAdapter(AssetDocumentModelAdapter());
  //Box 12 - Document Expiry Info
  Hive.registerAdapter(DocumentExpiryInfoAdapter());
  //Box 13 - Uploaded By Info
  Hive.registerAdapter(UploadedByInfoAdapter());

  await initialize(aLocaleLanguageList: languageList());

  appStore.toggleDarkMode(value: getBoolAsync(isDarkModeOnPref));
  appStore.toggleColorTheme();
  await appStore.setLanguage(
      getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: defaultLanguage));

  defaultRadius = 10;
  defaultToastGravityGlobal = ToastGravity.BOTTOM;

  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
    mapsImplementation.initializeWithRenderer(AndroidMapRenderer.latest);
  }

  if (!isWeb) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await setupFlutterNotifications();
  }
  const fatalError = true;
  // Non-async exceptions
  FlutterError.onError = (errorDetails) {
    if (fatalError) {
      // If you want to record a "fatal" exception
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      // ignore: dead_code
    } else {
      // If you want to record a "non-fatal" exception
      FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    }
  };
  // Async exceptions
  PlatformDispatcher.instance.onError = (error, stack) {
    if (fatalError) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      // ignore: dead_code
    } else {
      FirebaseCrashlytics.instance.recordError(error, stack);
    }
    return true;
  };
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LeaveStore>(create: (_) => LeaveStore()),
        Provider<AssetStore>(create: (_) => AssetStore()),
        Provider<ProjectStore>(create: (_) => ProjectStore()),
      ],
      child: Observer(
        builder: (_) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '$mainAppName${!isMobile ? ' ${platformName()}' : ''}',
          home: const SplashScreen(),
          theme: !appStore.isDarkModeOn
              ? AppThemeData.lightTheme
              : AppThemeData.darkTheme,
          routes: routes(),
          navigatorKey: navigatorKey,
          scrollBehavior: SBehavior(),
          supportedLocales: LanguageDataModel.languageLocales(),
          localizationsDelegates: const [
            AppLocalizations(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) => locale,
          locale: Locale(appStore.selectedLanguageCode),
        ),
      ),
    );
  }
}
