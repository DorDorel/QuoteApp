import 'package:QuoteApp/data/providers/products_provider.dart';
import 'package:QuoteApp/data/providers/reminder_provider.dart';
import 'package:QuoteApp/data/providers/tenant_provider.dart';
import 'package:flutter/material.dart' show ChangeNotifier, BuildContext;
import 'package:provider/provider.dart';

import '../../auth/auth_repository.dart';
import '../models/user.dart';
import '../networking/user_data_db.dart';
import 'bids_provider.dart';

class UserInfoProvider with ChangeNotifier {
  CustomUser? userData;
  bool _isLoading = true;
  bool _hasInitialized = false;

  bool get isLoading => _isLoading;
  bool get hasInitialized => _hasInitialized;

  Future<void> fetchUserData() async {
    // Don't fetch if we already have data or are in the process of loading
    if (userData != null || (_isLoading && _hasInitialized)) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final user = await UserDataService().getUserDataFromUserCollection();

      if (user == null) {
        print("Problem with user model sync");
      }
      userData = user;
      _hasInitialized = true;
    } catch (err) {
      print(err.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to manually refresh data when needed
  Future<void> refreshUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Use the refreshUserData method that clears cache before fetching
      final user = await UserDataService().refreshUserData();
      if (user == null) {
        print("Problem with user model sync during refresh");
      }
      userData = user;
    } catch (err) {
      print(err.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void cleanUserMemory(BuildContext context, bool isLogout) async {
    if (isLogout) {
      final AuthenticationRepository auth = AuthenticationRepositoryImpl();
      await auth.signOut();
      notifyListeners();
    }

    if (userData != null) {
      userData = null;
      _hasInitialized = false;

      try {
        context.read<ReminderProvider>().removeAllReminders();
        context.read<ProductProvider>().removeAllProducts();
        context.read<BidsProvider>().eraseAllUserBid();
        context.read<TenantProvider>().removeTenantIdFromLocalCache();
      } catch (err) {
        print(err.toString());
      }
    }
  }
}
