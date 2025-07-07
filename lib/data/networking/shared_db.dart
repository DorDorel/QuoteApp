import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:logger/logger.dart';

import '../../auth/tenant_repository.dart';
import 'constants/shared_firestore_constants.dart';
import 'database_exception.dart';

@immutable
class SharedDb {
  static final Logger _logger = Logger();

  static Future<int> getCurrentBidId() async {
    final tenantRef = await TenantRepositoryImpl().getTenantReference();
    if (tenantRef == null) {
      throw DatabaseException("Could not get tenant reference");
    }

    try {
      final sharedCollection = tenantRef.collection(
        SharedFirestoreConstants.sharedCollectionString,
      );

      final bidConfigDoc = sharedCollection.doc(
        SharedFirestoreConstants.bidConfigDocString,
      );

      final bidConfigDocObj = await bidConfigDoc.get();

      if (!bidConfigDocObj.exists) {
        throw DatabaseException("Bid config document not found");
      }

      final data = bidConfigDocObj.data();
      if (data == null || !data.containsKey(SharedFirestoreConstants.currentBidIdString)) {
        throw DatabaseException("'currentBidId' not found in bid config document");
      }

      return data[SharedFirestoreConstants.currentBidIdString];
    } catch (e, stackTrace) {
      _logger.e(
        "Error getting current bid ID",
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        "Error getting current bid ID",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> updateBidId() async {
    try {
      _logger.d("Starting bid ID update process...");
      final tenantRef = await TenantRepositoryImpl().getTenantReference();

      if (tenantRef == null) {
        throw DatabaseException("Could not get tenant reference for bid ID update");
      }

      final sharedCollection = tenantRef.collection(
        SharedFirestoreConstants.sharedCollectionString,
      );

      final bidConfigDoc = sharedCollection.doc(
        SharedFirestoreConstants.bidConfigDocString,
      );

      final currentId = await getCurrentBidId();
      _logger.d("Current bid ID is: $currentId");
      final newId = currentId + 1;

      final updated = {
        SharedFirestoreConstants.currentBidIdString: newId,
      };

      _logger.d("Updating bid ID to: $newId");
      await bidConfigDoc.update(updated);
      _logger.d("Bid ID successfully updated to: $newId");
    } catch (e, stackTrace) {
      _logger.e(
        "ERROR updating bid ID: ${e.toString()}",
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        "ERROR updating bid ID",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
