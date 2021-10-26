import 'dart:convert';

import 'package:country_codes/country_codes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/services/country_regulations/regulation_result.dart';
import 'package:greenpass_app/services/country_regulations/regulation_ruleset.dart';
import 'package:greenpass_app/services/country_regulations/regulation_selection.dart';
import 'package:greenpass_app/services/outdated_check.dart';
import 'package:greenpass_app/services/settings.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:greenpass_app/services/hive_provider.dart';

class RegulationsProvider {
  static const String _regulationsUrl = 'https://raw.githubusercontent.com/GreenPassApp/shared-data/main/validation-by-country-v2.min.json';
  static const String defaultCountry = 'EU';
  static const String defaultLanguage = 'en';
  static const String _langPrefixSubregion = 'subr_';
  static const String _langPrefixRule = 'rule_';
  static const String _fallbackTranslation = '?';

  static const Duration regulationsOutdatedAfter = Duration(days: kReleaseMode ? 1 : 0);
  static const String bundledRegulationsLocation = 'assets/validationByCountry.json';

  static Map<RegulationSelection, RegulationRuleset> _currentRegulations = {};
  static Map<String, dynamic> _translations = {};
  static late RegulationSelection _userSelection;

  static Function? _userSelectionChangeCallback;

  static const String _hiveBoxName = 'regulations';
  static const String _hiveBoxKey = 'regulationsKey';

  // loads the saved version of the country regulations
  // copies the bundled country regulations if none are present
  // tries to update the country regulations if outdated
  static Future<void> initAppStart() async {
    Box box = await HiveProvider.getEncryptedBox(boxName: _hiveBoxName, boxKeyName: _hiveBoxKey);

    bool userUpdated = await box.get('regulationsJsonVer') == '1';

    if (await box.get('regulationsJson') == null || userUpdated) {
      ByteData bundledJson = await rootBundle.load(bundledRegulationsLocation);
      String jsonString = utf8.decode(bundledJson.buffer.asUint8List(bundledJson.offsetInBytes, bundledJson.lengthInBytes));

      await box.put('regulationsJson', jsonString);
      await box.put('regulationsJsonLastUpdate', DateTime.fromMicrosecondsSinceEpoch(0).toIso8601String());
      await box.put('regulationsJsonVer', '2'); // in case something changes

      await box.put('regulationsUserCountry', defaultCountry);
      await box.put('regulationsUserSubregion', null);
      await box.put('regulationsUserRule', null);
    }

    Map<String, dynamic> jsonData = jsonDecode(await box.get('regulationsJson'));
    _currentRegulations = _parseRegulationsJson(jsonData);
    _translations = jsonData['lang'];
    _userSelection = RegulationSelection(
      await box.get('regulationsUserCountry'),
      await box.get('regulationsUserSubregion'),
      await box.get('regulationsUserRule')
    );

    if (userUpdated) {
      String oldCountry = await box.get('regulationsUserSetting');
      Map<String, List<String?>> availableRegions = getAvailableRegions();
      if (availableRegions.containsKey(oldCountry) && availableRegions[oldCountry]!.contains(null)) {
        selectRegion(oldCountry, null);
      }
      await box.delete('regulationsUserSetting');
    }

    await _repairUserSelection();

    // can happen in the background, no need for async
    tryUpdateIfOutdated();
  }

  // checks, if the current version of the country regulations are outdated
  // if so, fetch a new version of the country regulations online
  static Future<void> tryUpdateIfOutdated() async {
    Box box = await HiveProvider.getEncryptedBox(boxName: _hiveBoxName, boxKeyName: _hiveBoxKey);
    String? lastUpdateStr = await box.get('regulationsJsonLastUpdate');
    if (lastUpdateStr == null
        || DateTime.parse(lastUpdateStr).isBefore(DateTime.now().subtract(regulationsOutdatedAfter))) {
      try {
        Map<String, dynamic> fetchedRegulations = await _fetchRegulations();
        _currentRegulations = _parseRegulationsJson(fetchedRegulations);
        _translations = fetchedRegulations['lang'];
        await box.put('regulationsJson', jsonEncode(fetchedRegulations));
        await box.put('regulationsJsonLastUpdate', DateTime.now().toIso8601String());
        await box.compact();
        await _repairUserSelection();
      } catch (e) {
        // do nothing
      }
    }
  }

  static RegulationSelection getUserSelection() => OutdatedCheck.isOutdated ? RegulationSelection(defaultCountry, null, '') : _userSelection;

  static RegulationRuleset? getSelectedRuleset() => _currentRegulations[getUserSelection()] ?? _currentRegulations[getUserSelection().copyWith(subregionCode: null)];

  static bool useColorValidation() => !OutdatedCheck.isOutdated && _userSelection.countryCode != defaultCountry && getSelectedRuleset() != null;

  static String getCountryTranslation(String countryCode) {
    if (countryCode.toUpperCase() == defaultCountry.toUpperCase())
      return 'European Union'.tr();
    try {
      return CountryCodes.detailsForLocale(Locale.fromSubtags(countryCode: RegulationsProvider.getUserSelection().countryCode)).localizedName!;
    } catch (_) {
      return 'Unknown'.tr();
    }
  }

  static String getSubregionTranslation(String? subregion, Locale locale, [bool travelMode = false]) {
    if (subregion == null)
      return Settings.translateTravelMode('Nationwide', travelMode: travelMode);
    return _getTranslations(travelMode ? Locale.fromSubtags(languageCode: 'en') : locale)[_langPrefixSubregion + subregion] ?? _fallbackTranslation;
  }

  static String getRuleTranslation(String? rule, Locale locale) => _getTranslations(locale)[_langPrefixRule + (rule ?? '')] ?? _fallbackTranslation;

  static Future<void> selectRegion(String countryCode, String? subregion) async {
    Box box = await HiveProvider.getEncryptedBox(boxName: _hiveBoxName, boxKeyName: _hiveBoxKey);

    if (countryCode == defaultCountry) {
      await box.put('regulationsUserCountry', countryCode);
      await box.put('regulationsUserSubregion', null);
      await box.put('regulationsUserRule', null);
    } else {
      Map<String, RegulationRuleset> availableRules = getAvailableRules(countryCode, subregion);
      await box.put('regulationsUserCountry', countryCode);
      await box.put('regulationsUserSubregion', subregion);
      await box.put('regulationsUserRule', availableRules.keys.first);
    }

    await _loadUserSelection();
  }

  static Future<void> selectRule(String rule) async {
    Box box = await HiveProvider.getEncryptedBox(boxName: _hiveBoxName, boxKeyName: _hiveBoxKey);

    Map<String, RegulationRuleset> availableRules = getAvailableRules(_userSelection.countryCode, _userSelection.subregionCode);
    await box.put('regulationsUserRule', availableRules.containsKey(rule) ? rule : availableRules.keys.first);

    await _loadUserSelection();
  }

  static void setUserSelectionChangeCallback(Function? callback) => _userSelectionChangeCallback = callback;

  static Map<String, List<String?>> getAvailableRegions() {
    Map<String, List<String?>> result = {};
    _currentRegulations.keys.forEach((sel) {
      if (!result.containsKey(sel.countryCode)) result[sel.countryCode] = [];
      if (!result[sel.countryCode]!.contains(sel.subregionCode))
        result[sel.countryCode]!.add(sel.subregionCode);
    });
    return result;
  }

  static Map<String, RegulationRuleset> getAvailableRules(String countryCode, String? subregion) {
    Map<String, RegulationRuleset> result = {};
    _currentRegulations.forEach((sel, rul) {
      if (sel.countryCode == countryCode && ((sel.subregionCode == null && !result.containsKey(sel.rule)) || sel.subregionCode == subregion))
        result[sel.rule!] = rul;
    });
    return result;
  }

  static Future<void> _loadUserSelection() async {
    Box box = await HiveProvider.getEncryptedBox(boxName: _hiveBoxName, boxKeyName: _hiveBoxKey);
    _userSelection = RegulationSelection(
      await box.get('regulationsUserCountry'),
      await box.get('regulationsUserSubregion'),
      await box.get('regulationsUserRule')
    );
    if (_userSelectionChangeCallback != null)
      _userSelectionChangeCallback!();
  }

  // reset user selection when new regulations don't contain old selection
  static Future<void> _repairUserSelection() async {
    if (_userSelection.countryCode == defaultCountry) return;

    Box box = await HiveProvider.getEncryptedBox(boxName: _hiveBoxName, boxKeyName: _hiveBoxKey);

    Future<void> _fullReset() async {
      await box.put('regulationsUserCountry', defaultCountry);
      await box.put('regulationsUserSubregion', null);
      await box.put('regulationsUserRule', null);
      await _loadUserSelection();
    }

    Map<String, List<String?>> availableRegions = getAvailableRegions();
    if (!availableRegions.containsKey(_userSelection.countryCode)) {
      await _fullReset();
      return;
    }

    Map<String, RegulationRuleset> availableRules = getAvailableRules(_userSelection.countryCode, _userSelection.subregionCode);
    if (!availableRegions[_userSelection.countryCode]!.contains(_userSelection.subregionCode)) {
      if (_userSelection.subregionCode == null) {
        await _fullReset();
      } else {
        await box.put('regulationsUserSubregion', null);
        await box.put('regulationsUserRule', availableRules.keys.first);
        await _loadUserSelection();
      }
      return;
    }

    if (!availableRules.containsKey(_userSelection.rule)) {
      await box.put('regulationsUserRule', availableRules.keys.first);
      await _loadUserSelection();
      return;
    }
  }

  static Color getCardTextColor(RegulationResult result) {
    if (result.needToWait) return GPColors.almost_black;
    return Colors.white;
  }

  static Color getCardColor(RegulationResult result) {
    if (result.currentlyValid) return GPColors.green;
    if (result.needToWait) return GPColors.yellow;
    return GPColors.red;
  }

  static Map<String, String> _getTranslations(Locale locale) {
    String langCode = defaultLanguage;
    if (_translations.containsKey(locale.languageCode))
      langCode = locale.languageCode;
    return Map<String, String>.from(_translations[langCode]);
  }

  static Map<RegulationSelection, RegulationRuleset> _parseRegulationsJson(Map<String, dynamic> jsonData) {
    Map<String, dynamic> rulesets = jsonData['rulesets'] ?? {};

    Map<RegulationSelection, RegulationRuleset> parsedRegulations = {};

    Map<String, dynamic>? _findCurrent(List<dynamic> entries) {
      Map<String, dynamic>? currentRegulation;
      DateTime? currentRegulationValidFrom;

      entries.forEach((e) {
        e as Map<String, dynamic>;
        DateTime validFrom = DateTime.parse(e['validFrom']!);

        if (e['validUntil'] is String && DateTime.parse(e['validUntil']!).isBefore(DateTime.now()))
          return;

        if (validFrom.isBefore(DateTime.now())) {
          if (currentRegulationValidFrom == null || validFrom.isAfter(currentRegulationValidFrom!)) {
            currentRegulation = e;
            currentRegulationValidFrom = validFrom;
          }
        }
      });

      return currentRegulation;
    }

    void _insertRegulations(String countryCode, String? subregion, Map<String, dynamic> regionMap) {
      if (regionMap.containsKey('rules')) {
        regionMap['rules'].forEach((key, value) {
          String rule = key;
          Map<String, dynamic>? currentRegulation = _findCurrent(value);
          if (currentRegulation != null) {
            if (currentRegulation.containsKey('ruleset')) {
              Map<String, dynamic> rulesetJson = {};

              var ruleset = currentRegulation['ruleset'];
              if (ruleset is List) {
                ruleset.forEach((e) {
                  rulesetJson.addAll(rulesets[e]);
                });
              } else {
                rulesetJson.addAll(rulesets[ruleset]);
              }

              rulesetJson.addAll(currentRegulation);
              parsedRegulations[RegulationSelection(countryCode, subregion, rule)] = RegulationRuleset(DateTime.parse(currentRegulation['validFrom']), rulesetJson);
            } else {
              parsedRegulations[RegulationSelection(countryCode, subregion, rule)] = RegulationRuleset(DateTime.parse(currentRegulation['validFrom']), currentRegulation);
            }
          }
        });
      }
    }

    jsonData['countries'].forEach((countryCode, value) {
      value as Map<String, dynamic>;
      _insertRegulations(countryCode, null, value);
      if (value.containsKey('subregions')) {
        value['subregions'].forEach((subregion, value) {
          _insertRegulations(countryCode, subregion, value);
        });
      }
    });

    return parsedRegulations;
  }

  static Future<Map<String, dynamic>> _fetchRegulations() async {
    Response res = await get(Uri.parse(_regulationsUrl));
    return jsonDecode(res.body);
  }
}