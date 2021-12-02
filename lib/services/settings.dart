import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class Settings {
  static SharedPreferences? _shared;

  static const String _settingsPrefix = 'setting_';
  static const String _keyTravelMode = _settingsPrefix + 'travel_mode';
  static const String _keyHidePassDetails = _settingsPrefix + 'hide_pass_details';

  static late bool _travelMode;
  static late bool _hidePassDetails;

  static const String _enTranslationPath = 'assets/translations/en.json';
  static late Map<String, dynamic> _enTranslations;

  static Future<void> initAppStart() async {
    _shared = await SharedPreferences.getInstance();
    _travelMode = _shared!.getBool(_keyTravelMode) ?? false;
    _hidePassDetails = _shared!.getBool(_keyHidePassDetails) ?? false;

    ByteData enJson = await rootBundle.load(_enTranslationPath);
    _enTranslations = jsonDecode(utf8.decode(enJson.buffer.asUint8List(enJson.offsetInBytes, enJson.lengthInBytes)));
  }

  static bool getTravelMode() => _travelMode;

  static Future<void> setTravelMode(bool enabled) async {
    _travelMode = enabled;
    await _shared!.setBool(_keyTravelMode, enabled);
  }

  static translateTravelMode(String en, {List<String>? args, bool? travelMode}) {
    if (travelMode != null ? travelMode : _travelMode) {
      if (args == null) {
        if (kReleaseMode) {
          return _enTranslations[en] ?? en;
        } else {
          String? res = _enTranslations[en];
          if (res == null) print('[WARNING] Localization key [' + en + '] not found');
          return res ?? en;
        }
      } else {
        RegExp toReplace = RegExp(r'{}');
        en = _enTranslations[en];
        args.forEach((replacement) => en = en.replaceFirst(toReplace, replacement));
        return en;
      }
    } else {
      return en.tr(args: args);
    }
  }

  static translatePluralTravelMode(String en, int units, {bool? travelMode}) {
    if (travelMode != null ? travelMode : _travelMode) {
      RegExp toReplace = RegExp(r'{}');
      en = _enTranslations[en][_getPluralKey(units)];
      return en.replaceFirst(toReplace, units.toString());
    } else {
      return en.plural(units);
    }
  }

  static String _getPluralKey(int units) {
    if (units == 0) return 'zero';
    if (units == 1) return 'one';
    if (units == 2) return 'two';
    if (units > 0) return 'many';
    return 'other';
  }

  static bool getHidePassDetails() => _hidePassDetails;

  static Future<void> setHidePassDetails(bool enabled) async {
    _hidePassDetails = enabled;
    await _shared!.setBool(_keyHidePassDetails, enabled);
  }
}