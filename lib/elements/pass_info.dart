import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/elements/flag_element.dart';
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
    bool useBoldText = true,
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
                fontWeight: useBoldText ? FontWeight.bold : null,
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

  static String getDate(GreenCertificate cert, {bool travelMode = false, bool showTime = true}) {
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
        return DateFormat('dd.MM.yyyy' + (showTime ? ' | HH:mm' : '')).format(test.timeSampleCollection);
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

  static Widget getSmallPassCard(BuildContext context, GreenCertificate cert, {bool travelMode = false}) {
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
              child: Column(
                children: [
                  if (RegulationsProvider.useColorValidation()) ...[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                        color: Colors.white24,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 26.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: FittedBox(
                                child: Text(
                                  RegulationsProvider.getRuleTranslation(RegulationsProvider.getUserSelection().rule, travelMode ? Locale.fromSubtags(languageCode: 'en') : context.locale).toUpperCase(),
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  Row(
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget getSmallSortCard(int idx, GreenCertificate cert) {
    Color cardColor = GPColors.blue;
    Color textColor = Colors.white;
    if (RegulationsProvider.useColorValidation()) {
      RegulationResult res = RegulationsProvider.getSelectedRuleset()!.validate(cert);
      cardColor = RegulationsProvider.getCardColor(res);
      textColor = RegulationsProvider.getCardTextColor(res);
    }

    return Container(
      child: Column(
        children: [
          Divider(height: 0, color: GPColors.dark_grey),
          Container(
            color: Colors.transparent,
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.all(20.0),
                  padding: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(150),
                    color: cardColor,
                  ),
                  child: Icon(
                    ColoredCard.getValidationIcon(cert),
                    color: textColor,
                    size: 25.0,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        child: Text(
                          cert.personInfo.fullName,
                          style: TextStyle(
                            color: GPColors.almost_black,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(padding: const EdgeInsets.symmetric(vertical: 2.0)),
                      FittedBox(
                        child: Row(
                          children: [
                            PassInfo.getTypeText(
                              cert,
                              textSize: 14.0,
                              showTestType: false,
                              color: GPColors.almost_black,
                              useBoldText: false,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Text(
                                '|',
                                style: TextStyle(fontSize: 14.0, color: GPColors.almost_black),
                              ),
                            ),
                            Text(
                              PassInfo.getDate(cert, showTime: false),
                              style: TextStyle(fontSize: 14.0, color: GPColors.almost_black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ReorderableDragStartListener(
                  key: Key(idx.toString()),
                  index: idx,
                  child: Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
                      child: Icon(
                        FontAwesome5Solid.sort,
                        color: GPColors.almost_black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget getCalculatedRegulationResult(RegulationResult res, {bool travelMode = false}) {
    Widget boldText(String text) => Text(
      text,
      style: TextStyle(
        color: GPColors.almost_black,
        fontSize: 17.0,
        fontWeight: FontWeight.bold
      ),
    );
    Widget greyText(String text) => Text(
      text,
      style: TextStyle(
        color: GPColors.dark_grey,
        fontSize: 15.0,
      ),
    );

    Widget title;
    Widget? subtitle;

    if (res.isInvalid) {
      title = greyText(Settings.translateTravelMode('This certificate is not valid', travelMode: travelMode));
    } else if (res.needToWait) {
      title = greyText(Settings.translateTravelMode('Expected to be valid from', travelMode: travelMode));
      subtitle = boldText(DateFormat('HH:mm, dd.MM.yyyy').format(res.validFrom!));
    } else if (res.hasExpired) {
      title = greyText(Settings.translateTravelMode('Expired since', travelMode: travelMode));
      subtitle = boldText(DateFormat('HH:mm, dd.MM.yyyy').format(res.validUntil!));
    } else if (res.currentlyValid) {
      if (res.validUntil == null) {
        title = greyText(Settings.translateTravelMode('Expected to be valid forever', travelMode: travelMode));
      } else {
        title = greyText(Settings.translateTravelMode('Expected to be valid until', travelMode: travelMode));
        subtitle = boldText(DateFormat('HH:mm, dd.MM.yyyy').format(res.validUntil!));
      }
    } else {
      title = greyText(Settings.translateTravelMode('Unknown', travelMode: travelMode));
    }

    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlagElement.buildFlag(flag: RegulationsProvider.getUserSelection().countryCode),
        ],
      ),
      title: title,
      subtitle: subtitle,
    );
  }

  static Widget getCurrentRegulationInfo(BuildContext context, {bool centerText = true, bool travelMode = false}) {
    List<String> translatedTextParts = Settings.translateTravelMode('Validation according to the regulations in {} (Last update: {})', travelMode: travelMode).split('{}');

    return Text.rich(
      TextSpan(
        style: TextStyle(color: GPColors.dark_grey, fontSize: 12.0),
        children: [
          TextSpan(text: translatedTextParts[0]),
          TextSpan(text: (RegulationsProvider.getCountryTranslation(RegulationsProvider.getUserSelection().countryCode) + ', '
              + RegulationsProvider.getSubregionTranslation(RegulationsProvider.getUserSelection().subregionCode, context.locale, travelMode)).replaceAll(' ', '\u00A0'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: translatedTextParts[1]),
          TextSpan(text: DateFormat('dd.MM.yyyy').format(RegulationsProvider.getSelectedRuleset()!.validFrom)),
          TextSpan(text: translatedTextParts[2]),
          TextSpan(text: '\n' + Settings.translateTravelMode('All information without guarantee', travelMode: travelMode)),
        ],
      ),
      textAlign: centerText ? TextAlign.center : TextAlign.start,
    );
  }
}