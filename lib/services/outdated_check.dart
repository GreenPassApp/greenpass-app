import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/elements/colored_card.dart';
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

  static Widget getInfoCard() {
    return ColoredCard.buildCard(
      backgroundColor: GPColors.yellow,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Icon(
                FontAwesome5Solid.exclamation_triangle,
                color: GPColors.almost_black,
                size: 18.0,
              ),
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Outdated app version'.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 2.0)),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          "Your app version is outdated, so certificate checking and color validation have been disabled. To re-enable these features, you need to update the app.".tr(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}