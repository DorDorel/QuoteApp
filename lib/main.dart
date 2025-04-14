import 'dart:developer';
import 'package:QuoteApp/app/providers.dart';
import 'package:QuoteApp/app/routes.dart';
import 'package:QuoteApp/app/theme.dart';
import 'package:QuoteApp/data/local/local_reminder.dart';
import 'package:QuoteApp/data/local/tenant_cache_box.dart';
import 'package:QuoteApp/data/providers/tenant_provider.dart';
import 'package:QuoteApp/data/providers/user_info_provider.dart';
import 'package:QuoteApp/logs/console_logger.dart';
import 'package:QuoteApp/presentation/screens/home/main_dashboard.dart';
import 'package:QuoteApp/presentation/screens/root/root.dart';
import 'package:QuoteApp/presentation/screens/user/login_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    final logger = Logger();
    logger.info("Firebase initialized successfully", tag: "App");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
  
  await TenantCacheBox.openLocalTenantValidationBox();
  await LocalReminder.openBidRemindersBox();
  runApp(QuoteAppV2Root());
}

class QuoteAppV2Root extends StatelessWidget {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final logger = Logger();
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        routes: appRoutes,
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        home: AuthenticationWrapper(),
        navigatorKey: GlobalKey<NavigatorState>(),
        onGenerateRoute: (settings) {
          // Track screen views with our logger
          logger.logScreenView(settings.name ?? 'unknown_screen');
          return null;
        },
      ),
    );
  }
}

//########################################################################
// This Wrapper check:
//  - User Auth
//  - Verification of user access to this current Tenant
//  - User Authorization (check if user is admin in current tenant)
//########################################################################
class AuthenticationWrapper extends StatefulWidget {
  static Map<String, String> userInfo = {};

  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool _initializedData = false;
  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    final firebaseUser = Provider.of<User?>(context);
    final tenantProvider = Provider.of<TenantProvider>(context, listen: false);
    final userInfoProvider =
        Provider.of<UserInfoProvider>(context, listen: false);

    if (firebaseUser == null) {
      _initializedData = false;
      logger.info("User not logged in, showing login screen", tag: "Auth");
      return LoginScreen();
    }

    AuthenticationWrapper.userInfo = {
      "user": firebaseUser.email!,
      "uid": firebaseUser.uid,
      "tenant": TenantProvider.tenantId,
    };

    if (!_initializedData) {
      logger.info(
        "User logged in: ${firebaseUser.email}", 
        tag: "Auth"
      );
      
      logger.logBusinessEvent("user_login", {
        "user_id": firebaseUser.uid,
        "email": firebaseUser.email,
        "tenant_id": TenantProvider.tenantId,
      });
      
      logger.setUserProperty("tenant_id", TenantProvider.tenantId);
      logger.setUserProperty("user_email", firebaseUser.email ?? "unknown");
    }

   
    if (!_initializedData && !userInfoProvider.hasInitialized) {
      _initializedData = true;
      _initializeUserData(tenantProvider, userInfoProvider);
    }

    logger.logScreenView("RootScreen");
    return RootScreen();
  }

  Future<void> _initializeUserData(
      TenantProvider tenantProvider, UserInfoProvider userInfoProvider) async {
    try {
      logger.info("Validating tenant access", tag: "Auth");
      await tenantProvider.tenantValidation();

      if (TenantCacheBox.tenantCashBox!.isEmpty) {
        logger.info("First time login, storing tenant ID", tag: "Auth");
        tenantProvider.setTenantIdInLocalCache();
      }

      if (!userInfoProvider.hasInitialized) {
        logger.info("Fetching user data", tag: "Auth");
        await userInfoProvider.fetchUserData();
        logger.logBusinessEvent("user_data_loaded", {
          "success": userInfoProvider.hasInitialized.toString(),
        });
      }
    } catch (e) {
      logger.error(
        "Error initializing user data", 
        tag: "Auth", 
        exception: e
      );
    }
  }
}
