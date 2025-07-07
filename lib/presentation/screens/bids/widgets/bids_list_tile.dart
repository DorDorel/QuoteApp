import 'package:QuoteApp/data/models/bid.dart';
import 'package:QuoteApp/presentation/screens/bids/bid_info.dart';
import 'package:QuoteApp/services/email_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final bool isOpen = bid.openFlag ?? false;
    final Color primaryColor = isOpen ? Colors.green.shade700 : Colors.grey.shade600;

    return GestureDetector(
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
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.07),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Indicator
              Container(
                width: 8,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Client Name & Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              bid.clientName,
                              style: GoogleFonts.openSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          archiveScreen
                              ? IconButton(
                                  onPressed: () async {
                                    EmailService emailService = EmailService(
                                      to: bid.clientMail,
                                    );
                                    emailService.openDefaultMainAppWithAddressClient();
                                  },
                                  icon: Icon(Icons.email_outlined, color: Colors.grey.shade500),
                                  tooltip: 'Email Client',
                                )
                              : OpenTileMenu(
                                  bidId: bid.bidId,
                                  clientMail: bid.clientMail,
                                  phoneNumber: bid.clientPhone,
                                ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Sub-header: Quote ID
                      Text(
                        "Quote #${bid.bidId}",
                        style: GoogleFonts.openSans(
                          color: Colors.black54,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Divider(height: 24, thickness: 1),

                      // Details: Date and Price
                      Row(
                        children: [
                          _buildInfoChip(
                            icon: Icons.calendar_today_outlined,
                            text: DateFormat('MMM dd, yyyy').format(bid.date),
                          ),
                          const SizedBox(width: 12),
                          _buildInfoChip(
                            icon: Icons.monetization_on_outlined,
                            text: "${NumberFormat("#,##0.00", "en_US").format(bid.finalPrice)} ₪",
                            highlight: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text, bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: highlight ? Colors.blue.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: highlight ? Colors.blue.shade700 : Colors.grey.shade700,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.openSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: highlight ? Colors.blue.shade800 : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
