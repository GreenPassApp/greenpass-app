import 'package:greenpass_app/green_validator/payload/cert_entry_recovery.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_test.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_vaccination.dart';
import 'package:greenpass_app/green_validator/payload/certificate_type.dart';
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';
import 'package:greenpass_app/green_validator/payload/test_type.dart';
import 'package:greenpass_app/local_storage/country_regulations/regulation_result.dart';

class Regulation {
  Map<String, String> _regulationEntry;

  Regulation(this._regulationEntry);

  RegulationResult validate(GreenCertificate cert) {
    if (cert.certificateType == CertificateType.recovery) {
      CertEntryRecovery rec = cert.entryList[0] as CertEntryRecovery;
      if (rec.validFrom.isAfter(DateTime.now()))
        return RegulationResult.not_valid_yet;
      if (rec.validUntil.isBefore(DateTime.now()))
        return RegulationResult.not_valid_anymore;
    } else if (cert.certificateType == CertificateType.test) {
      CertEntryTest test = cert.entryList[0] as CertEntryTest;
      Duration validity;
      if (test.testType == TestType.pcr)
        validity = _durationFromISO8601(_regulationEntry['PCRTestDuration']!);
      else
        validity = _durationFromISO8601(_regulationEntry['rapidTestDuration']!);

      if (test.timeSampleCollection.isBefore(DateTime.now().subtract(validity)))
        return RegulationResult.not_valid_anymore;
    } else if (cert.certificateType == CertificateType.vaccination) {
      bool fullyVaccinated = cert.entryList.any((vac) => (vac as CertEntryVaccination).doseNumber == vac.dosesNeeded);
      var vacs = cert.entryList;
      vacs.sort((e1, e2) {
        e1 as CertEntryVaccination;
        e2 as CertEntryVaccination;
        return e1.doseNumber.compareTo(e2.doseNumber);
      });

      if (fullyVaccinated) {
        CertEntryVaccination lastVac = vacs.last as CertEntryVaccination;
        if (_regulationEntry.containsKey('validFromFullVac')) {
          if (lastVac.dateOfVaccination.isAfter(DateTime.now().subtract(_durationFromISO8601(_regulationEntry['validFromFullVac']!))))
            return RegulationResult.not_valid_yet;
        }
        if (_regulationEntry.containsKey('validUntilFullVac')) {
          if (lastVac.dateOfVaccination.isBefore(DateTime.now().subtract(_durationFromISO8601(_regulationEntry['validUntilFullVac']!))))
            return RegulationResult.not_valid_anymore;
        }
      } else {
        CertEntryVaccination firstKnownVac = vacs.first as CertEntryVaccination;
        if (_regulationEntry.containsKey('validFromPartialVac')) {
          if (firstKnownVac.dateOfVaccination.isAfter(DateTime.now().subtract(_durationFromISO8601(_regulationEntry['validFromPartialVac']!))))
            return RegulationResult.not_valid_yet;
        }
        if (_regulationEntry.containsKey('validUntilPartialVac')) {
          if (firstKnownVac.dateOfVaccination.isBefore(DateTime.now().subtract(_durationFromISO8601(_regulationEntry['validUntilPartialVac']!))))
            return RegulationResult.not_valid_anymore;
        }

        // special case: if the country haven't set a date for partial vaccinations, it is considered as invalid
        if (!_regulationEntry.containsKey('validFromPartialVac') && !_regulationEntry.containsKey('validUntilPartialVac'))
          return RegulationResult.not_valid_yet;
      }
    }
    return RegulationResult.valid;
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