import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:QuoteApp/logs/console_logger.dart';

@immutable
class EmailService {
  final String to;
  final logger = Logger();

  EmailService({required this.to});

  Future<void> sendBidInMail(
    String tenant,
    String tenantName,
    String bidDocId,
    String creator,
  ) async {
    final FirebaseFunctions functions = FirebaseFunctions.instance;
    try {
      final HttpsCallable callable = functions.httpsCallable('sendBidInEmail');
      await callable(
        {
          "clientMail": to,
          "tenantId": tenant,
          "tenantName": tenantName,
          "bidDocId": bidDocId,
          "creator": creator,
          // "ClientPhone": customerPhone,
        },
      );
      logger.info("Email sent successfully", tag: "EmailService");
    } catch (exp) {
      logger.error("Failed to send email", tag: "EmailService", exception: exp);
    }
  }

  Future<void> openDefaultMainAppWithAddressClient() async {
    final url = 'mailto:$to';
    if (!await launchUrlString(url)) {
      logger.error("Could not launch $url", tag: "EmailService");
      throw 'Could not launch $url';
    } else {
      logger.info("Launched email client with $to", tag: "EmailService");
      await launchUrlString(url);
    }
  }
}
