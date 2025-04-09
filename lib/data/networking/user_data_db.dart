import 'dart:developer';

import 'package:QuoteApp/auth/auth_firestore_const.dart';
import 'package:QuoteApp/auth/auth_repository.dart';
import 'package:QuoteApp/auth/tenant_repository.dart';
import 'package:QuoteApp/data/models/user.dart';
import 'package:QuoteApp/data/providers/tenant_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show immutable, kDebugMode;

@immutable
class UserDataService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String tenant = TenantRepositoryImpl.currentTenantId;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

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
    DocumentReference<Object?> companyRef = companiesCollection.doc(cid);
    return companyRef;
  }

  Future<CustomUser?> getUserDataFromUserCollection() async {
    if (kDebugMode) {
      log("🐛  *DEBUG LOG* : Database Query - getUserDataFromUserCollection from DatabaseService reading");
    }

    // Return cached data if available
    if (_cachedUserData != null) {
      if (kDebugMode) {
        log("🐛  *DEBUG LOG* : Returning cached user data");
      }
      return _cachedUserData;
    }

    try {
      // More efficient query that directly filters on the server side
      final QuerySnapshot<Object?> userRef = await usersCollection
          .where(AuthFirestoreConstants.userIdString, isEqualTo: uid)
          .limit(1)
          .get();

      if (userRef.docs.isEmpty) {
        log("No user document found with uid: $uid");
        return null;
      }

      // Cache the data before returning
      _cachedUserData = CustomUser.fromMap(userRef.docs.first.data() as Map<String, dynamic>);
      return _cachedUserData;
    } catch (err) {
      log("Error fetching user data: ${err.toString()}");
      print(err.toString());
    }
    return null;
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
    } catch (exp) {
      print(exp.toString());
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
    } catch (exp) {
      print(
        exp.toString(),
      );
    }
  }

  Future<Object?> findUserInCompanyCollectionByUid(
    String uid,
    String tenantId,
  ) async {
    final DocumentReference tenantDoc = companiesCollection.doc(
      tenantId,
    );
    final CollectionReference<Map<String, dynamic>> userList =
        tenantDoc.collection(
      AuthFirestoreConstants.usersCollectionString,
    );
    try {
      QuerySnapshot<Map<String, dynamic>> userUid = await userList
          .where(
            AuthFirestoreConstants.userIdString,
            isEqualTo: uid,
          )
          .get();
      return userUid.docs.first.data()[AuthFirestoreConstants.userIdString];
    } catch (exp) {
      print(exp.toString());
      return null;
    }
  }

  Future<bool> isAdmin() async {
    String uid = AuthenticationRepositoryImpl.getCurrentUserUID;
    String tenantId = TenantProvider.tenantId;

    final DocumentReference tenantDoc = companiesCollection.doc(
      tenantId,
    );
    final CollectionReference<Map<String, dynamic>> userList =
        tenantDoc.collection(
      AuthFirestoreConstants.usersCollectionString,
    );
    try {
      QuerySnapshot<Map<String, dynamic>> userUid = await userList
          .where(
            AuthFirestoreConstants.userIdString,
            isEqualTo: uid,
          )
          .get();
      bool isAdmin =
          await userUid.docs.first.data()[AuthFirestoreConstants.isAdminString];

      return isAdmin;
    } catch (exp) {
      print(exp.toString());
    }
    return false;
  }
}
