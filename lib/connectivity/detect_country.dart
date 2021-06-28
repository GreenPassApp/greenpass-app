import 'dart:io';

import 'package:http/http.dart';

class DetectCountry {
  static const String _countryApiUri = 'https://api.greenpassapp.eu/user/countryCode';

  static String? countryCode;

  static Future<String?> getCountryCode() async {
    try {
      Response res = await get(Uri.parse(_countryApiUri));
      if (res.statusCode == HttpStatus.ok) {
        countryCode = res.body;
      }
    } catch (_) {
      // ignore
    }
    return null;
  }
}