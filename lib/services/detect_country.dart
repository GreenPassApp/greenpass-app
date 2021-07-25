import 'dart:ui';

import 'package:country_codes/country_codes.dart';

class DetectCountry {
  static String? countryCode;

  // Method to retrieve the country set in the device's settings
  static String? getCountryCode() {
    Locale? l = CountryCodes.getDeviceLocale();
    if (l != null)
      return countryCode = l.countryCode;
    return null;
  }
}