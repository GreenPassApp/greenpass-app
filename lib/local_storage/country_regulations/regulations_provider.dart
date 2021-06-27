import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/local_storage/country_regulations/regulation.dart';
import 'package:greenpass_app/local_storage/country_regulations/regulation_result.dart';
import 'package:greenpass_app/local_storage/country_regulations/regulation_result_type.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';

import 'package:greenpass_app/local_storage/hive_provider.dart';

class RegulationsProvider {
  static const String _regulationsUrl = 'https://raw.githubusercontent.com/GreenPassApp/shared-data/main/validationByCountry.json';
  static const String defaultCountry = 'EU';

  static const Duration regulationsOutdatedAfter = Duration(days: 1);
  static const String bundledRegulationsLocation = 'assets/validationByCountry.json';

  static Map<String, Regulation>? _currentRegulations;
  static String? _userSetting;

  static const String _hiveBoxName = 'regulations';
  static const String _hiveBoxKey = 'regulationsKey';

  static Future<void> initAppStart() async {
    Box box = await HiveProvider.getEncryptedBox(boxName: _hiveBoxName, boxKeyName: _hiveBoxKey);
    if (await box.get('regulationsJson') == null) {
      ByteData bundledJson = await rootBundle.load(bundledRegulationsLocation);
      String jsonString = utf8.decode(bundledJson.buffer.asUint8List(bundledJson.offsetInBytes, bundledJson.lengthInBytes));

      await box.put('regulationsJson', jsonString);
      await box.put('regulationsJsonLastUpdate', DateTime.fromMicrosecondsSinceEpoch(0).toIso8601String());
      await box.put('regulationsJsonVer', '1'); // in case something changes

      await box.put('regulationsUserSetting', defaultCountry);
    }

    _currentRegulations = _parseRegulationsJson(jsonDecode(await box.get('regulationsJson')));
    _userSetting = await box.get('regulationsUserSetting');

    // can happen in the background, no need for async
    tryUpdateIfOutdated();
  }

  static Future<void> tryUpdateIfOutdated() async {
    Box box = await HiveProvider.getEncryptedBox(boxName: _hiveBoxName, boxKeyName: _hiveBoxKey);
    String? lastUpdateStr = await box.get('regulationsJsonLastUpdate');
    if (lastUpdateStr == null
        || DateTime.parse(lastUpdateStr).isBefore(DateTime.now().subtract(regulationsOutdatedAfter))) {
      try {
        Map<String, dynamic> fetchedRegulations = await _fetchRegulations();
        _currentRegulations = _parseRegulationsJson(fetchedRegulations);
        await box.put('regulationsJson', jsonEncode(fetchedRegulations));
        await box.put('regulationsJsonLastUpdate', DateTime.now().toIso8601String());
        await box.compact();
      } catch (e) {
        // do nothing
      }
    }
  }

  static Map<String, Regulation> _parseRegulationsJson(Map<String, dynamic> jsonData) {
    Map<String, Regulation> parsedRegulations = Map<String, Regulation>();

    jsonData.forEach((key, value) {
      value as List;
      var currentRegulation;
      DateTime? currentRegulationValidFrom;

      value.forEach((element) {
        element as Map<String, dynamic>;
        DateTime validFrom = DateTime.parse(element['validFrom']!);
        if (validFrom.isBefore(DateTime.now())) {
          if (currentRegulationValidFrom == null || validFrom.isAfter(currentRegulationValidFrom!)) {
            currentRegulation = element;
            currentRegulationValidFrom = validFrom;
          }
        }
      });

      if (currentRegulation != null)
        parsedRegulations[key] = Regulation(key.toUpperCase(), currentRegulation);
    });

    return parsedRegulations;
  }

  static Future<Map<String, dynamic>> _fetchRegulations() async {
    Response res = await get(Uri.parse(_regulationsUrl));
    return jsonDecode(res.body);
  }

  static Map<String, Regulation> getCurrentRegulations() {
    return _currentRegulations!;
  }

  static String getUserSetting() {
    return _userSetting!;
  }

  static Regulation getUserRegulation() {
    return getCurrentRegulations()[getUserSetting()]!;
  }

  static Future<void> setUserSetting(String newCountry) async {
    _userSetting = newCountry;
    Box box = await HiveProvider.getEncryptedBox(boxName: _hiveBoxName, boxKeyName: _hiveBoxKey);
    await box.put('regulationsUserSetting', newCountry);
    await box.compact();
  }

  static Color getCardTextColor(RegulationResult result) {
    if (result.type == RegulationResultType.not_valid_yet) return GPColors.almost_black;
    return Colors.white;
  }

  static Color getCardColor(RegulationResult result) {
    if (result.type == RegulationResultType.not_valid_anymore) return GPColors.red;
    if (result.type == RegulationResultType.not_valid_yet) return GPColors.yellow;
    return GPColors.green;
  }
}