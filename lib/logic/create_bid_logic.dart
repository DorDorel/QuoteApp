import 'package:flutter/material.dart';

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

  CreateBid({
    required this.currentBid,
    required this.phoneNumber,
    required this.creator,
  });

  Future<bool> startNewBidFlow() async {
    try {
      print("==== STARTING NEW BID CREATION FLOW ====");
      print("Bid ID: ${currentBid.bidId}");
      print("Client: ${currentBid.clientName}");
      print("Products: ${currentBid.selectedProducts.length}");

      /*
      setBidInDB getting the current bid doc id.
      */
      print("Attempting to write bid to database...");
      String setBidInDB = await BidsDb.addBidToBidCollection(currentBid);
      print("Result of database write: $setBidInDB");

      if (setBidInDB != 'null') {
        print("Bid document created successfully with ID: $setBidInDB");
        print("Updating bid counter...");
        bool counterUpdated = await SharedDb().updateBidId();
        if (!counterUpdated) {
          print("WARNING: Failed to update bid counter!");
        }

        // cloud function to send email and sms with link
        print("Creating BidFlowRunner for notifications...");
        final BidFlowRunner newRunner = BidFlowRunner(
          tenantId: TenantProvider.tenantId,
          tenantName: TenantProvider.tenantName,
          bidDocId: setBidInDB,
          customerEmail: currentBid.clientMail,
          customerPhone: phoneNumber,
          creator: creator,
        );

        print("Running notification flow...");
        await newRunner.runner();
        print("Notification flow completed");
        print("==== BID CREATION COMPLETED SUCCESSFULLY ====");
        return true;
      } else {
        print("ERROR: Failed to create bid document in database");
        return false;
      }
    } catch (exp) {
      print("CRITICAL ERROR in startNewBidFlow: ${exp.toString()}");
      return false;
    }
  }
}
