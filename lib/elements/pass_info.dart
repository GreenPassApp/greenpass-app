import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_recovery.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_test.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_vaccination.dart';
import 'package:greenpass_app/green_validator/payload/certificate_type.dart';
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';
import 'package:greenpass_app/green_validator/payload/test_result.dart';
import 'package:greenpass_app/green_validator/payload/test_type.dart';

class PassInfo {
  static Widget getTypeText(GreenCertificate cert, {
    double textSize = 25.0,
    double additionalTextSize = 20.0,
    bool showTestType = true,
  }) {
    String firstText;
    switch (cert.certificateType) {
      case CertificateType.vaccination:
        firstText = 'Vaccinated'.tr();
        break;
      case CertificateType.recovery:
        firstText = 'Recovered'.tr();
        break;
      case CertificateType.test:
        var test = (cert.entryList[0] as CertEntryTest);
        firstText = test.testResult == TestResult.negative ? 'Tested negative'.tr() : 'Tested positive'.tr();
        break;
      case CertificateType.unknown:
        firstText = 'Unknown'.tr();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              firstText,
              style: TextStyle(
                color: Colors.white,
                fontSize: textSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (cert.certificateType == CertificateType.vaccination) ...[
              Padding(padding: EdgeInsets.symmetric(horizontal: 2.0)),
              (){
                var vacs = cert.entryList;
                vacs.sort((e1, e2) {
                  e1 as CertEntryVaccination;
                  e2 as CertEntryVaccination;
                  return e1.doseNumber.compareTo(e2.doseNumber);
                });
                var vac = (vacs[0] as CertEntryVaccination);
                return Text(
                  '(' + vac.doseNumber.toString() + '/' + vac.dosesNeeded.toString() + ')',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: textSize,
                  ),
                );
              }(),
            ],
          ],
        ),
        if (cert.certificateType == CertificateType.test && showTestType) ...[
          (){
            var test = (cert.entryList[0] as CertEntryTest);
            return Text(
              '(' + testType(test.testType) + ')',
              style: TextStyle(
                color: Colors.white,
                fontSize: additionalTextSize,
              ),
            );
          }(),
          Padding(padding: EdgeInsets.symmetric(vertical: 6.0)),
        ],
      ],
    );
  }

  static String testType(TestType type) {
    switch (type) {
      case TestType.pcr: return 'PCR test'.tr();
      case TestType.rapid: return 'Rapid test'.tr();
      case TestType.unknown: return 'Unknown test'.tr();
    }
  }

  static String getDate(GreenCertificate cert) {
    switch (cert.certificateType) {
      case CertificateType.vaccination:
        var vacs = cert.entryList;
        vacs.sort((e1, e2) {
          e1 as CertEntryVaccination;
          e2 as CertEntryVaccination;
          return e1.doseNumber.compareTo(e2.doseNumber);
        });
        var vac = (vacs[0] as CertEntryVaccination);
        return DateFormat('dd.MM.yyyy').format(vac.dateOfVaccination);
      case CertificateType.recovery:
        var rec = (cert.entryList[0] as CertEntryRecovery);
        return DateFormat('dd.MM.yyyy').format(rec.validFrom);
      case CertificateType.test:
        var test = (cert.entryList[0] as CertEntryTest);
        return DateFormat('dd.MM.yyyy | hh:mm').format(test.timeSampleCollection);
      case CertificateType.unknown:
        return 'Unknown time'.tr();
    }
  }

  static String getDuration(GreenCertificate cert) {
    switch (cert.certificateType) {
      case CertificateType.vaccination:
        var vacs = cert.entryList;
        vacs.sort((e1, e2) {
          e1 as CertEntryVaccination;
          e2 as CertEntryVaccination;
          return e1.doseNumber.compareTo(e2.doseNumber);
        });
        var vac = (vacs[0] as CertEntryVaccination);
        int timeDiff = DateTime.now()
            .difference(vac.dateOfVaccination)
            .inDays;
        return '{} days ago'.plural(timeDiff, args: [timeDiff.toString()]);
      case CertificateType.recovery:
        var rec = (cert.entryList[0] as CertEntryRecovery);
        int timeDiff = DateTime.now()
            .difference(rec.validFrom)
            .inDays;
        return 'Since {} days'.plural(timeDiff, args: [timeDiff.toString()]);
      case CertificateType.test:
        var test = (cert.entryList[0] as CertEntryTest);
        int timeDiff = DateTime.now()
            .difference(test.timeSampleCollection)
            .inHours;
        return '{} hours ago'.plural(timeDiff, args: [timeDiff.toString()]);
      case CertificateType.unknown:
        return 'Unknown'.tr();
    }
  }
}