import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../data/models/bid.dart';
import '../data/networking/bids_db.dart';
import '../data/networking/shared_db.dart';
import '../data/providers/tenant_provider.dart';
import 'bid_flow_runner.dart';

@immutable
class CreateBid {
  final Bid currentBid;
  final String phoneNumber;
  final String creator;

  static final Logger _logger = Logger();

  CreateBid({
    required this.currentBid,
    required this.phoneNumber,
    required this.creator,
  });

  Future<bool> startNewBidFlow() async {
    try {
      _logger.d("==== STARTING NEW BID CREATION FLOW ====");
      _logger.d("Bid ID: ${currentBid.bidId}");
      _logger.d("Client: ${currentBid.clientName}");
      _logger.d("Products: ${currentBid.selectedProducts.length}");

      /*
      setBidInDB getting the current bid doc id.
      */
      _logger.d("Attempting to write bid to database...");
      String? setBidInDB = await BidsDb.addBidToBidCollection(currentBid);
      _logger.d("Result of database write: $setBidInDB");

      if (setBidInDB != null) {
        _logger.d("Bid document created successfully with ID: $setBidInDB");
        _logger.d("Updating bid counter...");
        await SharedDb().updateBidId();
        _logger.d("Bid counter updated");

        // cloud function to send email and sms with link
        _logger.d("Creating BidFlowRunner for notifications...");
        final BidFlowRunner newRunner = BidFlowRunner(
          tenantId: TenantProvider.tenantId,
          tenantName: TenantProvider.tenantName,
          bidDocId: setBidInDB,
          customerEmail: currentBid.clientMail,
          customerPhone: phoneNumber,
          creator: creator,
        );

        _logger.d("Running notification flow...");
        await newRunner.runner();
        _logger.d("Notification flow completed");
        _logger.d("==== BID CREATION COMPLETED SUCCESSFULLY ====");
        return true;
      } else {
        _logger.e("ERROR: Failed to create bid document in database");
        return false;
      }
    } catch (exp, stackTrace) {
      _logger.e("CRITICAL ERROR in startNewBidFlow: ${exp.toString()}",
          error: exp, stackTrace: stackTrace);
      return false;
    }
  }
}