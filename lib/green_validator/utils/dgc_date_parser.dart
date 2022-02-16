class DGCDateParser {
  // calculate DateTime from cbor web token fields (comparable to JWT)
  static DateTime fromCwtSeconds(num cwtSeconds) {
    return DateTime.fromMillisecondsSinceEpoch(cwtSeconds.toInt() * 1000, isUtc: true).toLocal();
  }

  // convert ISO 8601 formatted dates (and times) to DateTime instance
  static DateTime fromDateString(String formattedDate) {
    return DateTime.parse(formattedDate).toLocal();
  }
}