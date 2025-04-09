import 'package:QuoteApp/data/models/bid.dart';
import 'package:QuoteApp/presentation/screens/bids/bid_info.dart';
import 'package:QuoteApp/services/email_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'open_bid_card_menu.dart';

class BidTile extends StatelessWidget {
  final bool archiveScreen;
  final Bid bid;
  const BidTile({
    required this.bid,
    required this.archiveScreen,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String bidId = bid.bidId;
    final bool? isOpen = bid.openFlag;
    final String clientName = bid.clientName;
    final oCcy = NumberFormat("#,##0.00", "en_US");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: GestureDetector(
        onTap: () {
          if (!archiveScreen) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => BidInfo(bid: bid),
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isOpen == true
                  ? [
                      Colors.white,
                      Color(0xFFE8F5E9)
                    ] // Light green tint for open bids
                  : [
                      Colors.white,
                      Colors.grey.shade100
                    ], // Neutral for closed bids
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Bid Status Indicator
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: isOpen == true ? Colors.green : Colors.grey.shade400,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Client info section
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isOpen == true
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.person_outline_rounded,
                                  color: isOpen == true
                                      ? Colors.green.shade700
                                      : Colors.grey.shade700,
                                  size: 22,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      clientName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Quote #${bidId}",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 13,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "${oCcy.format(bid.finalPrice)} ₪",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action buttons
                        archiveScreen
                            ? IconButton(
                                onPressed: () async {
                                  EmailService emailService = EmailService(
                                    to: bid.clientMail,
                                  );
                                  emailService
                                      .openDefaultMainAppWithAddressClient();
                                },
                                icon: Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.email_outlined,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              )
                            : OpenTileMenu(
                                bidId: bidId,
                                clientMail: bid.clientMail,
                                phoneNumber: bid.clientPhone,
                              ),
                      ],
                    ),

                    // Date indicator
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(bid.date),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
