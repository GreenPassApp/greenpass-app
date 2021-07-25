import 'dart:convert';

import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OutdatedCheck {
  static const String _outdatedVersionsUrl = 'https://raw.githubusercontent.com/GreenPassApp/shared-data/main/outdated-app-versions.json';
  static SharedPreferences? _shared;

  static const String _outdatedCheckPrefix = 'outdated_check_';
  static const String _keyTriggeredVersion = _outdatedCheckPrefix + 'triggered_version';

  static String? _triggeredVersion;

  static Future<void> initAppStart() async {
    _shared = await SharedPreferences.getInstance();

    String? savedVersion = _shared!.getString(_keyTriggeredVersion);
    if (savedVersion == await _getVersionCode())
      _triggeredVersion = savedVersion;
    else if (savedVersion != null)
      _shared!.remove(_keyTriggeredVersion);

    _doOutdatedCheck(); // do in background
  }

  static get isOutdated => _triggeredVersion != null;

  static Future<void> _doOutdatedCheck() async {
    try {
      Response res = await get(Uri.parse(_outdatedVersionsUrl));
      Map<String, dynamic> parsedJson = jsonDecode(res.body);
      List<String> disableValidationList = List<String>.from(parsedJson['disable_validation']);

      String currentVersion = await _getVersionCode();

      for (String regex in disableValidationList) {
        if (_checkIfMatching(regex, currentVersion)) {
          _triggeredVersion = currentVersion;
          _shared!.setString(_keyTriggeredVersion, _triggeredVersion!);
          return;
        }
      }

      // no regex matched: remove triggered version if there was one saved
      if (_triggeredVersion != null) {
        _shared!.remove(_keyTriggeredVersion);
        _triggeredVersion = null;
      }
    } catch (_) {
      // do nothing
    }
  }

  static bool _checkIfMatching(String regex, String version) {
    try {
      RegExp exp = RegExp(regex);
      return exp.hasMatch(version);
    } catch (_) {
      // fallback: just compare the two strings
      return regex == version;
    }
  }

  static Future<String> _getVersionCode() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}