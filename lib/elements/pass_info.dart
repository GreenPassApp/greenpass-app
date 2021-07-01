import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_recovery.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_test.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_vaccination.dart';
import 'package:greenpass_app/green_validator/payload/certificate_type.dart';
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';
import 'package:greenpass_app/green_validator/payload/test_result.dart';
import 'package:greenpass_app/green_validator/payload/test_type.dart';
import 'package:greenpass_app/local_storage/country_regulations/regulation_result.dart';
import 'package:greenpass_app/local_storage/country_regulations/regulation_result_type.dart';
import 'package:greenpass_app/local_storage/country_regulations/regulations_provider.dart';

import 'colored_card.dart';

class PassInfo {
  static Widget getTypeText(GreenCertificate cert, {
    double textSize = 25.0,
    double additionalTextSize = 20.0,
    bool showTestType = true,
    Color color = Colors.white,
    RegulationResult? regulationResult,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (regulationResult != null && RegulationsProvider.getUserSetting() != RegulationsProvider.defaultCountry) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Icon(regulationResult.type == RegulationResultType.valid ? FontAwesome5Solid.check_circle
                    : regulationResult.type == RegulationResultType.not_valid_yet ? FontAwesome5Solid.hourglass_half : FontAwesome5Solid.times_circle, color: color, size: 22.0),
              ),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0)),
            ],
            Text(
              firstText,
              style: TextStyle(
                color: color,
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
                var vac = (vacs.last as CertEntryVaccination);
                return Text(
                  '(' + vac.doseNumber.toString() + '/' + vac.dosesNeeded.toString() + ')',
                  style: TextStyle(
                    color: color,
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
                color: color,
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
        return 'For {} days'.plural(timeDiff, args: [timeDiff.toString()]);
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

  static Widget getSmallPassCard(GreenCertificate cert) {
    Color cardColor = GPColors.blue;
    Color textColor = Colors.white;
    if (RegulationsProvider.getUserSetting() != RegulationsProvider.defaultCountry) {
      RegulationResult res = RegulationsProvider.getUserRegulation().validate(cert);
      cardColor = RegulationsProvider.getCardColor(res);
      textColor = RegulationsProvider.getCardTextColor(res);
    }

    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
            child: ColoredCard.buildCard(
              backgroundColor: cardColor,
              child: Row(
                children: [
                  ColoredCard.buildIcon(icon: ColoredCard.getValidationIcon(cert), size: 25.0, circleBorder: 3, circlePadding: 15.0, color: textColor),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PassInfo.getTypeText(
                        cert,
                        textSize: 20.0,
                        additionalTextSize: 15.0,
                        showTestType: false,
                        color: textColor,
                      ),
                      Padding(padding: const EdgeInsets.symmetric(vertical: 2.0)),
                      Text(
                        PassInfo.getDate(cert),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}