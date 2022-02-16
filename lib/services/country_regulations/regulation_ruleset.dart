import 'package:age_calculator/age_calculator.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_recovery.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_test.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_vaccination.dart';
import 'package:greenpass_app/green_validator/payload/certificate_type.dart';
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';
import 'package:greenpass_app/green_validator/payload/test_type.dart';
import 'package:greenpass_app/services/country_regulations/regulation_result.dart';

class RegulationRuleset {

  final DateTime validFrom;
  Map<String, dynamic> _rulesetEntry;

  RegulationRuleset(this.validFrom, this._rulesetEntry);

  // checks, if a certificate is valid in the current country
  RegulationResult validate(GreenCertificate cert) {
    if (cert.certificateType == CertificateType.vaccination)
      return _validateVaccination(cert);
    if (cert.certificateType == CertificateType.recovery)
      return _validateRecovery(cert);
    if (cert.certificateType == CertificateType.test)
      return _validateTest(cert);
    throw 'An unknown certificate type was passed';
  }

  RegulationResult _validateVaccination(GreenCertificate cert) {
    if (_rulesetEntry['vac'] is! List)
      return RegulationResult.invalid;

    var vacs = cert.entryList;
    vacs.sort((e1, e2) {
      e1 as CertEntryVaccination;
      e2 as CertEntryVaccination;
      return e1.doseNumber.compareTo(e2.doseNumber);
    });
    CertEntryVaccination vac = vacs.last as CertEntryVaccination; // only relevant is the last vaccination

    String mp = vac.medicalProductCode;
    int dn = vac.doseNumber;
    int sd = vac.dosesNeeded;
    bool full = (dn >= sd);

    bool _numberCheck(int num, dynamic entry) {
      bool _atomicCheck(dynamic test) {
        if (test is int) {
          return num == test;
        } else if (test is String) {
          if (test.startsWith('>=')) {
            int? t = int.tryParse(test.replaceFirst('>=', ''));
            if (t == null) return false;
            return (num >= t);
          } else if (test.startsWith('<=')) {
            int? t = int.tryParse(test.replaceFirst('<=', ''));
            if (t == null) return false;
            return (num <= t);
          } else if (test.startsWith('>')) {
            int? t = int.tryParse(test.replaceFirst('>', ''));
            if (t == null) return false;
            return (num > t);
          } else if (test.startsWith('<')) {
            int? t = int.tryParse(test.replaceFirst('<', ''));
            if (t == null) return false;
            return (num < t);
          }
        }
        return false;
      }

      if (entry is List) {
        return entry.any((e) => _atomicCheck(e));
      } else {
        return _atomicCheck(entry);
      }
    }

    for (Map<String, dynamic> cond in _rulesetEntry['vac']) {
      if (cond['mp'] is List) {
        if (!(cond['mp'] as List).contains(mp)) continue;
      } else if (cond['mp'] is String) {
        if (cond['mp'] != mp) continue;
      }

      if (cond.containsKey('dn')) {
        if (!_numberCheck(dn, cond['dn'])) continue;
      }

      if (cond.containsKey('sd')) {
        if (!_numberCheck(sd, cond['sd'])) continue;
      }

      if (cond.containsKey('full')) {
        if (cond['full'] != full) continue;
      }

      if (cond.containsKey('age')) {
        int personAge = AgeCalculator.age(cert.personInfo.dateOfBirth).years;
        if (!_numberCheck(personAge, cond['age'])) continue;
      }
      // criteria passed

      if (cond['wait'] == false)
        return RegulationResult.invalid;

      DateTime validFrom = vac.dateOfVaccination;
      if (cond['wait'] is String)
        validFrom = validFrom.add(_durationFromISO8601(cond['wait']));

      DateTime? validUntil;
      if (cond['dur'] is String) {
        Duration dur = _durationFromISO8601(cond['dur']);
        if (dur > const Duration()) {
          validUntil = vac.dateOfVaccination.add(dur);
        } else {
          return RegulationResult.invalid;
        }
      }

      return RegulationResult(validFrom: validFrom, validUntil: validUntil);
    }

    return RegulationResult.invalid;
  }

  RegulationResult _validateRecovery(GreenCertificate cert) {
    CertEntryRecovery rec = cert.entryList[0] as CertEntryRecovery;

    if (_rulesetEntry['rec'] is String) {
      Duration dur = _durationFromISO8601(_rulesetEntry['rec']);
      if (dur > const Duration()) {
        return RegulationResult(
          validFrom: rec.validFrom,
          validUntil: rec.firstPositiveTestResult.add(dur)
        );
      }
    }

    if (_rulesetEntry['rec'] == true)
      return RegulationResult(validFrom: rec.validFrom, validUntil: rec.validUntil);

    return RegulationResult.invalid;
  }

  RegulationResult _validateTest(GreenCertificate cert) {
    CertEntryTest test = cert.entryList[0] as CertEntryTest;

    String relevantKey;
    if (test.testType == TestType.rapid) relevantKey = 'rTest';
    else if (test.testType == TestType.pcr) relevantKey = 'pTest';
    else return RegulationResult.invalid;

    if (_rulesetEntry[relevantKey] is! String)
      return RegulationResult.invalid;

    Duration dur = _durationFromISO8601(_rulesetEntry[relevantKey]);
    if (dur > const Duration())
      return RegulationResult(validFrom: test.timeSampleCollection, validUntil: test.timeSampleCollection.add(dur));

    return RegulationResult.invalid;
  }

  static Duration _durationFromISO8601(String duration) {
    if (!RegExp(r'^P((\d+W)?(\d+D)?)(T(\d+H)?(\d+M)?(\d+S)?)?$')
        .hasMatch(duration)) {
      throw ArgumentError('String does not follow correct format');
    }

    final weeks = _parseTime(duration, 'W');
    final days = _parseTime(duration, 'D');
    final hours = _parseTime(duration, 'H');
    final minutes = _parseTime(duration, 'M');
    final seconds = _parseTime(duration, 'S');

    return Duration(
      days: days + (weeks * 7),
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }

  static int _parseTime(String duration, String timeUnit) {
    final timeMatch = RegExp(r'\d+' + timeUnit).firstMatch(duration);

    if (timeMatch == null) {
      return 0;
    }
    final timeString = timeMatch.group(0);
    return int.parse(timeString!.substring(0, timeString.length - 1));
  }
}