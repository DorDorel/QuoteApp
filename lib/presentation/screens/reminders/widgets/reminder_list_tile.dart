import 'package:QuoteApp/data/models/bid.dart';
import 'package:QuoteApp/data/models/reminder.dart';
import 'package:QuoteApp/data/providers/bids_provider.dart';
import 'package:QuoteApp/data/providers/reminder_provider.dart';
import 'package:QuoteApp/presentation/screens/bids/bid_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReminderListTile extends StatelessWidget {
  final Reminder reminder;

  const ReminderListTile({
    required this.reminder,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reminderData = Provider.of<ReminderProvider>(context);
    final Bid currentBid = _getBidObjectFromReminderObject(
      context,
      reminder,
    );
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => BidInfo(
                bid: currentBid,
              ),
            ),
          );
        },
        title: Text(
          "Quote ID: ${reminder.bidId}",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            reminder.note,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        trailing: IconButton(
          onPressed: () async {
            await reminderData.favoriteListManger(reminder.bidId);
          },
          icon: Icon(
            reminderData.getFavorites.contains(reminder.bidId)
                ? Icons.star
                : Icons.star_border,
            color: reminderData.getFavorites.contains(reminder.bidId)
                ? Colors.amber
                : Colors.grey,
            size: 30,
          ),
        ),
      ),
    );
  }
}

Bid _getBidObjectFromReminderObject(BuildContext context, Reminder reminder) {
  final bidsData = Provider.of<BidsProvider>(context);
  final String bidId = reminder.bidId;
  dynamic bid;
  for (final element in bidsData.allBids) {
    if (element.bidId == bidId) {
      bid = element;
    }
  }

  return bid;
}
