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
import 'package:greenpass_app/services/country_regulations/regulation_result.dart';
import 'package:greenpass_app/services/country_regulations/regulations_provider.dart';
import 'package:greenpass_app/services/settings.dart';

import 'colored_card.dart';

class PassInfo {
  static Widget getTypeText(GreenCertificate cert, {
    double textSize = 25.0,
    double additionalTextSize = 20.0,
    bool showTestType = true,
    bool hideDetails = false,
    Color color = Colors.white,
    RegulationResult? regulationResult,
    bool travelMode = false,
  }) {
    String firstText;
    String validText = '';
    if (hideDetails) {
      if (regulationResult == null) {
        validText = 'Valid';
      } else {
        if (regulationResult.currentlyValid)
          validText = 'Valid';
        else if (regulationResult.needToWait)
          validText = 'Not valid yet';
        else
          validText = 'Invalid';
      }
    }
    switch (cert.certificateType) {
      case CertificateType.vaccination:
        firstText = Settings.translateTravelMode(hideDetails ? validText : 'Vaccinated', travelMode: travelMode);
        break;
      case CertificateType.recovery:
        firstText = Settings.translateTravelMode(hideDetails ? validText : 'Recovered', travelMode: travelMode);
        break;
      case CertificateType.test:
        var test = (cert.entryList[0] as CertEntryTest);
        firstText = test.testResult == TestResult.negative ? Settings.translateTravelMode(hideDetails ? validText : 'Tested negative', travelMode: travelMode) : Settings.translateTravelMode(hideDetails ? validText : 'Tested positive', travelMode: travelMode);
        break;
      case CertificateType.unknown:
        firstText = Settings.translateTravelMode('Unknown', travelMode: travelMode);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (regulationResult != null && RegulationsProvider.useColorValidation()) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Icon(regulationResult.currentlyValid ? FontAwesome5Solid.check_circle
                  : regulationResult.needToWait ? FontAwesome5Solid.hourglass_half : FontAwesome5Solid.times_circle, color: color, size: 22.0),
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
            if (!hideDetails) ...[
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
          ],
        ),
        if (cert.certificateType == CertificateType.test && showTestType && !hideDetails) ...[
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

  static String testType(TestType type, {bool travelMode = false}) {
    switch (type) {
      case TestType.pcr: return Settings.translateTravelMode('PCR test', travelMode: travelMode);
      case TestType.rapid: return Settings.translateTravelMode('Rapid test', travelMode: travelMode);
      case TestType.unknown: return Settings.translateTravelMode('Unknown test', travelMode: travelMode);
    }
  }

  static String getDate(GreenCertificate cert, {bool travelMode = false}) {
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
        return DateFormat('dd.MM.yyyy | HH:mm').format(test.timeSampleCollection);
      case CertificateType.unknown:
        return Settings.translateTravelMode('Unknown time', travelMode: travelMode);
    }
  }

  static String getDuration(GreenCertificate cert, {bool travelMode = false}) {
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
        return Settings.translatePluralTravelMode('{} days ago', timeDiff, travelMode: travelMode);
      case CertificateType.recovery:
        var rec = (cert.entryList[0] as CertEntryRecovery);
        int timeDiff = DateTime.now()
            .difference(rec.validFrom)
            .inDays;
        return Settings.translatePluralTravelMode('For {} days', timeDiff, travelMode: travelMode);
      case CertificateType.test:
        var test = (cert.entryList[0] as CertEntryTest);
        int timeDiff = DateTime.now()
            .difference(test.timeSampleCollection)
            .inHours;
        return Settings.translatePluralTravelMode('{} hours ago', timeDiff, travelMode: travelMode);
      case CertificateType.unknown:
        return Settings.translateTravelMode('Unknown', travelMode: travelMode);
    }
  }

  static Widget getSmallPassCard(GreenCertificate cert, {bool travelMode = false}) {
    Color cardColor = GPColors.blue;
    Color textColor = Colors.white;
    if (RegulationsProvider.useColorValidation()) {
      RegulationResult res = RegulationsProvider.getSelectedRuleset()!.validate(cert);
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
                        travelMode: travelMode,
                      ),
                      Padding(padding: const EdgeInsets.symmetric(vertical: 2.0)),
                      Text(
                        PassInfo.getDate(cert, travelMode: travelMode),
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