import 'package:flutter/foundation.dart' show immutable;

@immutable
class BidsFirestoreConstants {
  static const String bidsCollectionString = 'bids';
  static const String bidIdString = 'bidId';
  static const String openFlagString = 'openFlag';

  const BidsFirestoreConstants._();
}
