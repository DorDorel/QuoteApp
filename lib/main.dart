import 'dart:developer';
import 'package:QuoteApp/app/providers.dart';
import 'package:QuoteApp/app/routes.dart';
import 'package:QuoteApp/app/theme.dart';
import 'package:QuoteApp/data/local/local_reminder.dart';
import 'package:QuoteApp/data/local/tenant_cache_box.dart';
import 'package:QuoteApp/data/providers/tenant_provider.dart';
import 'package:QuoteApp/data/providers/user_info_provider.dart';
import 'package:QuoteApp/presentation/screens/home/main_dashboard.dart';
import 'package:QuoteApp/presentation/screens/root/root.dart';
import 'package:QuoteApp/presentation/screens/user/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await TenantCacheBox.openLocalTenantValidationBox();
  await LocalReminder.openBidRemindersBox();
  runApp(QuoteAppV2Root());
}

class QuoteAppV2Root extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        routes: appRoutes,
        home: AuthenticationWrapper(),
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

  @override
  Widget build(BuildContext context) {
    final firebaseUser = Provider.of<User?>(context);
    final tenantProvider = Provider.of<TenantProvider>(context, listen: false);
    final userInfoProvider =
        Provider.of<UserInfoProvider>(context, listen: false);

    // If no user is logged in, return login screen
    if (firebaseUser == null) {
      _initializedData = false;
      return LoginScreen();
    }

    // User is logged in, capture user info
    AuthenticationWrapper.userInfo = {
      "user": firebaseUser.email!,
      "uid": firebaseUser.uid,
      "tenant": TenantProvider.tenantId,
    };

    // Log auth info in debug mode
    if (kDebugMode && !_initializedData) {
      AuthenticationWrapper.userInfo.forEach(
        (key, value) {
          log('$key' ':' ' ' '$value');
        },
      );
    }

    // Initialize data loading process and check tenant validation
    // This will be called only once after authentication
    if (!_initializedData && !userInfoProvider.hasInitialized) {
      _initializedData = true;
      _initializeUserData(tenantProvider, userInfoProvider);
    }

    return RootScreen();
  }

  Future<void> _initializeUserData(
      TenantProvider tenantProvider, UserInfoProvider userInfoProvider) async {
    // Check tenant validation first
    await tenantProvider.tenantValidation();

    // If it's a first time user login on this device, store tenant ID
    if (TenantCacheBox.tenantCashBox!.isEmpty) {
      tenantProvider.setTenantIdInLocalCache();
    }

    // Fetch user data only if not already loaded
    if (!userInfoProvider.hasInitialized) {
      await userInfoProvider.fetchUserData();
    }
  }
}
