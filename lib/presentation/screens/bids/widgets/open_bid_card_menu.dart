import 'package:QuoteApp/data/providers/bids_provider.dart';
import 'package:QuoteApp/services/call_service.dart';
import 'package:QuoteApp/services/email_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OpenTileMenu extends StatelessWidget {
  final String bidId;
  final String clientMail;
  final String phoneNumber;

  const OpenTileMenu({
    required this.bidId,
    required this.clientMail,
    required this.phoneNumber,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bidsData = Provider.of<BidsProvider>(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Call button
        _buildActionButton(
          context,
          color: Colors.green,
          icon: Icons.phone_outlined,
          onTap: () async {
            final CallService callService = CallService(
              phoneNumber: phoneNumber,
            );
            await callService.callNow();
          },
        ),

        const SizedBox(width: 8),

        // Email button
        _buildActionButton(
          context,
          color: Colors.blue,
          icon: Icons.email_outlined,
          onTap: () async {
            EmailService emailService = EmailService(
              to: clientMail,
            );
            emailService.openDefaultMainAppWithAddressClient();
          },
        ),

        const SizedBox(width: 8),

        // Mark as complete button
        _buildActionButton(
          context,
          color: Colors.orange,
          icon: Icons.check_circle_outline_rounded,
          onTap: () {
            _showCompleteDialog(context, bidsData);
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color.fromARGB((0.1 * 255).round(), (color.value >> 16) & 0xFF, (color.value >> 8) & 0xFF, color.value & 0xFF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, BidsProvider bidsData) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.bottomSlide,
      title: 'Complete Bid',
      desc: 'Are you sure you want to mark this bid as completed?',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        await bidsData.updateBidFlag(bidId);
        bidsData.eraseAllUserBid();
      },
      btnOkText: 'Yes, Complete',
      btnCancelText: 'Cancel',
      btnOkColor: Colors.green,
      btnCancelColor: Colors.grey,
    ).show();
  }
}
