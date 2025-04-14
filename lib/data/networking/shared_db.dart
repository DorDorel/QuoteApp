import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable;

import '../../auth/tenant_repository.dart';
import 'constants/shared_firestore_constants.dart';

@immutable
class SharedDb {
  static Future<int> getCurrentBidId() async {
    int currentBidId = 0;

    final DocumentReference<Object?>? tenantRef =
        await TenantRepositoryImpl().getTenantReference();

    final CollectionReference<Map<String, dynamic>> sharedCollection =
        tenantRef!.collection(
      SharedFirestoreConstants.sharedCollectionString,
    );

    final DocumentReference<Map<String, dynamic>> bidConfigDoc =
        sharedCollection.doc(
      SharedFirestoreConstants.bidConfigDocString,
    );

    final bidConfigDocObj = await bidConfigDoc.get();

    bidConfigDocObj.data()!.forEach(
      (key, value) {
        if (key == SharedFirestoreConstants.currentBidIdString) {
          currentBidId = value;
        }
      },
    );
    return currentBidId;
  }

  Future<bool> updateBidId() async {
    try {
      print("Starting bid ID update process...");
      final DocumentReference<Object?>? tenantRef =
          await TenantRepositoryImpl().getTenantReference();

      if (tenantRef == null) {
        print("ERROR: Could not get tenant reference for bid ID update");
        return false;
      }

      final CollectionReference<Map<String, dynamic>> sharedCollection =
          tenantRef.collection(
        SharedFirestoreConstants.sharedCollectionString,
      );

      final DocumentReference<Map<String, dynamic>> bidConfigDoc =
          sharedCollection.doc(
        SharedFirestoreConstants.bidConfigDocString,
      );

      int currentId = await getCurrentBidId();
      print("Current bid ID is: $currentId");
      int newId = currentId + 1;

      Map<String, int> updated = {
        SharedFirestoreConstants.currentBidIdString: newId,
      };

      print("Updating bid ID to: $newId");
      await bidConfigDoc.update(updated);
      print("Bid ID successfully updated to: $newId");

      return true;
    } catch (exp) {
      print("ERROR updating bid ID: ${exp.toString()}");
      return false;
    }
  }
}
