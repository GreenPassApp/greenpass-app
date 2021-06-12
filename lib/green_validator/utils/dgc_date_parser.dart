import 'package:intl/intl.dart';

class DGCDateParser {
  // calculate DateTime from cbor web token fields (comparable to JWT)
  static DateTime fromCwtSeconds(int cwtSeconds) {
    return DateTime.fromMillisecondsSinceEpoch(cwtSeconds * 1000, isUtc: true);
  }

  // convert ISO 8601 formatted dates (and times) to DateTime instance
  static DateTime fromDateString(String formattedDate) {
    return DateTime.parse(formattedDate);
  }
}