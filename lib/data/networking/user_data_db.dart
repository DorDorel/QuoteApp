import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show immutable, kDebugMode;
import 'package:logger/logger.dart';

import '../../auth/auth_firestore_const.dart';
import '../../auth/auth_repository.dart';
import '../../auth/tenant_repository.dart';
import '../models/user.dart';
import '../providers/tenant_provider.dart';
import 'database_exception.dart';

@immutable
class UserDataService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final Logger _logger = Logger();

  // Cache the user data to prevent redundant Firestore queries
  static CustomUser? _cachedUserData;

  // Collections reference
  final CollectionReference companiesCollection =
      _db.collection(AuthFirestoreConstants.tenantCollectionString);
  final CollectionReference usersCollection =
      _db.collection(AuthFirestoreConstants.usersCollectionString);

  // cid is a companyId (String)
  // docRef is a reference to firestore document Object
  Future<DocumentReference<Object?>> findCompanyByCid(String cid) async {
    return companiesCollection.doc(cid);
  }

  Future<CustomUser?> getUserDataFromUserCollection() async {
    if (kDebugMode) {
      _logger.d(
          "Database Query - getUserDataFromUserCollection from DatabaseService reading");
    }

    // Return cached data if available
    if (_cachedUserData != null) {
      if (kDebugMode) {
        _logger.d("Returning cached user data");
      }
      return _cachedUserData;
    }

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw DatabaseException("User not logged in");
      }

      // More efficient query that directly filters on the server side
      final userRef = await usersCollection
          .where(AuthFirestoreConstants.userIdString, isEqualTo: uid)
          .limit(1)
          .get();

      if (userRef.docs.isEmpty) {
        _logger.d("No user document found with uid: $uid");
        return null;
      }

      // Cache the data before returning
      _cachedUserData = CustomUser.fromMap(
          userRef.docs.first.data() as Map<String, dynamic>);
      return _cachedUserData;
    } catch (e, stackTrace) {
      _logger.e(
        "Error fetching user data: ${e.toString()}",
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        "Error fetching user data",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Force refresh user data from Firestore
  Future<CustomUser?> refreshUserData() async {
    _cachedUserData = null;
    return getUserDataFromUserCollection();
  }

  // Clear cached user data
  static void clearCache() {
    _cachedUserData = null;
  }

  Future<void> addUserToUserCollection({required CustomUser user}) async {
    try {
      await usersCollection.add(
        user.toMap(),
      );
    } catch (e, stackTrace) {
      _logger.e(
        "Error adding user to user collection: ${e.toString()}",
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        "Error adding user to user collection",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> addUserToCompanyUserList(
      {required String cid, required CustomUser user}) async {
    try {
      final docRef = await findCompanyByCid(cid);
      await docRef
          .collection(
            AuthFirestoreConstants.usersCollectionString,
          )
          .doc(
            user.uid,
          )
          .set(
            user.toMap(),
          );
    } catch (e, stackTrace) {
      _logger.e(
        "Error adding user to company user list: ${e.toString()}",
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        "Error adding user to company user list",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Object?> findUserInCompanyCollectionByUid(
    String uid,
    String tenantId,
  ) async {
    final tenantDoc = companiesCollection.doc(
      tenantId,
    );
    final userList = tenantDoc.collection(
      AuthFirestoreConstants.usersCollectionString,
    );
    try {
      final userUid = await userList
          .where(
            AuthFirestoreConstants.userIdString,
            isEqualTo: uid,
          )
          .get();

      if (userUid.docs.isEmpty) {
        return null;
      }

      return userUid.docs.first.data()[AuthFirestoreConstants.userIdString];
    } catch (e, stackTrace) {
      _logger.e(
        "Error finding user in company collection by uid: ${e.toString()}",
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        "Error finding user in company collection by uid",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<bool> isAdmin() async {
    try {
      final uid = AuthenticationRepositoryImpl.getCurrentUserUID;
      final tenantId = TenantProvider.tenantId;

      final tenantDoc = companiesCollection.doc(
        tenantId,
      );
      final userList = tenantDoc.collection(
        AuthFirestoreConstants.usersCollectionString,
      );

      final userUid = await userList
          .where(
            AuthFirestoreConstants.userIdString,
            isEqualTo: uid,
          )
          .get();

      if (userUid.docs.isEmpty) {
        return false;
      }

      return userUid.docs.first.data()[AuthFirestoreConstants.isAdminString] ?? false;
    } catch (e, stackTrace) {
      _logger.e(
        "Error checking if user is admin: ${e.toString()}",
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        "Error checking if user is admin",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
