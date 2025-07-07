import 'package:flutter/foundation.dart' show immutable, kDebugMode;
import 'package:logger/logger.dart';

import '../../auth/auth_repository.dart';
import '../../auth/tenant_repository.dart';
import '../models/bid.dart';
import 'constants/bids_firestore_constants.dart';
import 'database_exception.dart';

@immutable
class BidsDb {
  static final Logger _logger = Logger();

  static Future<String> addBidToBidCollection(Bid bid) async {
    try {
      _logger.d("Starting to add bid to collection: ${bid.bidId}");
      final tenantRef = await TenantRepositoryImpl().getTenantReference();

      if (tenantRef == null) {
        throw DatabaseException("Could not get tenant reference");
      }

      final bidsCollection =
          tenantRef.collection(BidsFirestoreConstants.bidsCollectionString);

      _logger.d("Converting bid to map for storage...");
      final bidMap = bid.toMap();
      _logger.d("Bid map created successfully");

      final docRef = await bidsCollection.add(bidMap);
      _logger.d("Bid added successfully with ID: ${docRef.id}");
      return docRef.id;
    } catch (e, stackTrace) {
      _logger.e(
        "CRITICAL ERROR in addBidToBidCollection: ${e.toString()}",
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        "Failed to add bid to collection",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<List<Bid>> getAllUserBids() async {
    final uID = AuthenticationRepositoryImpl.getCurrentUserUID;
    final tenantRef = await TenantRepositoryImpl().getTenantReference();

    if (tenantRef == null) {
      throw DatabaseException("Could not get tenant reference for getAllUserBids");
    }

    try {
      final bidsCollection = await tenantRef
          .collection(
            BidsFirestoreConstants.bidsCollectionString,
          )
          .where(BidsFirestoreConstants.createdByString, isEqualTo: uID)
          .get();

      final allBids = bidsCollection.docs.map((doc) {
        try {
          return Bid.fromMap(doc.data());
        } catch (e, stackTrace) {
          _logger.e(
            "ERROR parsing bid document: ${doc.id}, error: ${e.toString()}",
            error: e,
            stackTrace: stackTrace,
          );
          return null;
        }
      }).whereType<Bid>().toList();

      allBids.sort((a, b) => a.bidId.compareTo(b.bidId));
      return allBids;
    } catch (e, stackTrace) {
      _logger.e(
        "ERROR FROM getAllUserBids: ${e.toString()}",
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        "Failed to get all user bids",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<Bid?> findBidByBidId(String bidId) async {
    final tenantRef = await TenantRepositoryImpl().getTenantReference();

    if (tenantRef == null) {
      throw DatabaseException("Could not get tenant reference for findBidByBidId");
    }

    try {
      final currentBid = await tenantRef
          .collection(
            BidsFirestoreConstants.bidsCollectionString,
          )
          .where(
            BidsFirestoreConstants.bidIdString,
            isEqualTo: bidId,
          )
          .get();

      if (currentBid.docs.isEmpty) {
        _logger.d("No bid found with bidId: $bidId");
        return null;
      }

      if (kDebugMode) {
        _logger.d(
            "Database Query - findBidByBidId from BidsDb reading for bidId: $bidId");
      }

      return Bid.fromMap(currentBid.docs.first.data());
    } catch (e, stackTrace) {
      _logger.e(
        "Error finding bid by bidId: ${e.toString()}",
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        "Error finding bid by bidId",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<String> _findBidDocIdByBidId(String bidId) async {
    final tenantRef = await TenantRepositoryImpl().getTenantReference();

    if (tenantRef == null) {
      throw DatabaseException(
          "Could not get tenant reference for _findBidDocIdByBidId");
    }

    try {
      final currentBid = await tenantRef
          .collection(
            BidsFirestoreConstants.bidsCollectionString,
          )
          .where(
            BidsFirestoreConstants.bidIdString,
            isEqualTo: bidId,
          )
          .get();

      if (currentBid.docs.isEmpty) {
        throw DatabaseException("No bid document found with bidId: $bidId");
      }

      if (kDebugMode) {
        _logger.d(
            "Database Query - _findBidDocIdByBidId from BidsDb reading for bidId: $bidId");
      }

      return currentBid.docs.first.id;
    } catch (e, stackTrace) {
      _logger.e(
        "Error finding bid document by bidId: ${e.toString()}",
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        "Error finding bid document by bidId",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<void> closeBidFlag(String bidId) async {
    final tenantRef = await TenantRepositoryImpl().getTenantReference();

    if (tenantRef == null) {
      throw DatabaseException("Could not get tenant reference for closeBidFlag");
    }

    try {
      final bidDocId = await _findBidDocIdByBidId(bidId);
      final bidsList =
          tenantRef.collection(BidsFirestoreConstants.bidsCollectionString);

      await bidsList.doc(bidDocId).update({
        BidsFirestoreConstants.openFlagString: false,
      });

      if (kDebugMode) {
        _logger.d(
            "Database Query - closeBidFlag from BidsDb reading for bidId: $bidId");
      }
    } catch (e, stackTrace) {
      _logger.e(
        "Error closing bid flag for bidId: ${e.toString()}",
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        "Error closing bid flag for bidId",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}