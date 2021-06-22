import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/green_validator/model/validation_result.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_recovery.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_test.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_vaccination.dart';
import 'package:greenpass_app/green_validator/payload/certificate_type.dart';
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';
import 'package:greenpass_app/green_validator/payload/test_result.dart';
import 'package:greenpass_app/green_validator/payload/test_type.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

class ModalCert extends StatelessWidget {
  final ValidationResult cert;

  const ModalCert({Key? key, required this.cert}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color cardColor = cert.success ? GPColors.blue : GPColors.red;
    
    // special case: recovery certificate not valid anymore
    if (cert.success && cert.certificate!.certificateType == CertificateType.recovery
      && (cert.certificate!.entryList[0] as CertEntryRecovery).validUntil.isBefore(DateTime.now())) {
      cardColor = GPColors.red;
    }

    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => Navigator.of(context).pop(),
          ),
          middle: Text('Certificate'.tr()),
        ),
        child: SafeArea(
          child: Container(
            constraints: BoxConstraints.expand(),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20.0,
                        spreadRadius: -25.0,
                        offset: Offset(4.0, 4.0),
                      ),
                    ],
                  ),
                  child: Card(
                    color: cardColor,
                    margin: EdgeInsets.all(25.0),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: cardColor, width: 1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                  margin: const EdgeInsets.all(20.0),
                                  padding: const EdgeInsets.all(20.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(150),
                                    border: Border.all(width: 4, color: Colors.white),
                                  ),
                                  child: Icon(
                                    _getCertIcon(cert),
                                    color: Colors.white,
                                    size: 40.0,
                                  ),
                                )
                              ),
                            ],
                          ),
                          if (cert.success) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                _getTypeText(cert.certificate!),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  _getDate(cert.certificate!),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(35.0),
                                  child: Text(
                                    _getDuration(cert.certificate!),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Invalid'.tr(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Flexible(
                                    child: Text(
                                      'This QR code is invalid. Please try to scan another one.'.tr(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                if (cert.success) ...[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesome5Solid.user,
                            size: 30,
                            color: GPColors.almost_black,
                          ),
                        ],
                      ),
                      title: Text(
                        cert.certificate!.personInfo.fullName,
                        style: TextStyle(
                          color: GPColors.almost_black,
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold
                        )
                      ),
                      subtitle: Text(
                        DateFormat('dd.MM.yyyy').format(cert.certificate!.personInfo.dateOfBirth),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15.0
                        )
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCertIcon(ValidationResult cert) {
    if (!cert.success)
      return FontAwesome5Solid.times;
    switch (cert.certificate!.certificateType) {
      case CertificateType.vaccination:
        return FontAwesome5Solid.syringe;
      case CertificateType.recovery:
        return FontAwesome5Solid.child;
      case CertificateType.test:
        return FontAwesome5Solid.vial;
      case CertificateType.unknown:
        return FontAwesome5Solid.times;
    }
  }

  Widget _getTypeText(GreenCertificate cert) {
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
      children: [
        Row(
          children: [
            Text(
              firstText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 25.0,
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
                    fontSize: 25.0,
                  ),
                );
              }(),
            ],
          ],
        ),
        if (cert.certificateType == CertificateType.test) ...[
          (){
            var test = (cert.entryList[0] as CertEntryTest);
            return Text(
              '(' + _testType(test.testType) + ')',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            );
          }(),
          Padding(padding: EdgeInsets.symmetric(vertical: 6.0)),
        ],
      ],
    );
  }

  String _testType(TestType type) {
    switch (type) {
      case TestType.pcr: return 'PCR test'.tr();
      case TestType.rapid: return 'Rapid test'.tr();
      case TestType.unknown: return 'Unknown test'.tr();
    }
  }

  String _getDate(GreenCertificate cert) {
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

  String _getDuration(GreenCertificate cert) {
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
