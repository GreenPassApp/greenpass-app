import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenpass_app/green_validator/green_validator.dart';
import 'package:greenpass_app/green_validator/model/validation_result.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_recovery.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_test.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_vaccination.dart';
import 'package:greenpass_app/green_validator/payload/certificate_type.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ModalValidCert extends StatelessWidget {
  final ValidationResult cert;

  const ModalValidCert({Key? key, required this.cert}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            leading: Container(), middle: Text('Modal Page')),
        child: SafeArea(
          bottom: false,
          child: Container(
            constraints: BoxConstraints.expand(),
            child: Column(
              children: [
                Card(
                  color: Color(0xFFB135ACF),
                  margin: EdgeInsets.all(25.0),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.white70, width: 1),
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
                                  padding: EdgeInsets.all(50.0),
                                  child: Container(
                                    margin: EdgeInsets.all(20),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        border: Border.all(
                                            width: 4, color: Colors.white)),
                                    child: Icon(
                                      getIcon(cert),
                                      color: Colors.white,
                                      size: 100.0,
                                    ),
                                  )),
                            ]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.all(00.0),
                                child: Text(
                                  getTypeText(cert),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 22.0),
                                ))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.all(00.0),
                                child: Text(
                                  getDate(cert),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15.0),
                                ))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Text(
                                  getDuration(cert),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15.0),
                                ))
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 5.0, left: 0.0),
                      child: Icon(
                        Icons.person,
                        size: 35,
                      ),
                    ),
                    title: Text(
                        cert.certificate!.personInfo.firstName +
                            " " +
                            cert.certificate!.personInfo.lastName,
                        style: TextStyle(color: Colors.black, fontSize: 17.0)),
                    subtitle: Text(
                        cert.certificate!.personInfo.dateOfBirth.toString(),
                        style: TextStyle(color: Colors.grey, fontSize: 15.0)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData getIcon(ValidationResult cert) {
    switch (cert.certificate!.certificateType) {
      case CertificateType.vaccination:
        return Icons.check;
      case CertificateType.recovery:
        return Icons.record_voice_over_rounded;
      case CertificateType.test:
        return Icons.restaurant_menu;
      case CertificateType.unknown:
        return Icons.device_unknown;
    }
  }

  String getTypeText(ValidationResult cert) {
    switch (cert.certificate!.certificateType) {
      case CertificateType.vaccination:
        var vac = (cert.certificate!.entryList[0] as CertEntryVaccination);
        return "Vaccinated (" +
            vac.doseNumber.toString() +
            "/" +
            vac.dosesNeeded.toString() +
            ")";
      case CertificateType.recovery:
        return "Recovered";
      case CertificateType.test:
        var test = (cert.certificate!.entryList[0] as CertEntryTest);
        return "Tested " + test.testTypeCode;
      case CertificateType.unknown:
        return "Unknown";
    }
  }

  String getDate(ValidationResult cert) {
    switch (cert.certificate!.certificateType) {
      case CertificateType.vaccination:
        var vac = (cert.certificate!.entryList[0] as CertEntryVaccination);
        return DateFormat('dd.MM.yyyy').format(vac.dateOfVaccination);
      case CertificateType.recovery:
        var rec = (cert.certificate!.entryList[0] as CertEntryRecovery);
        return DateFormat('dd.MM.yyyy').format(rec.validUntil);
      case CertificateType.test:
        var test = (cert.certificate!.entryList[0] as CertEntryTest);
        return DateFormat('dd.MM.yyyy').format(test.timeSampleCollection);
      case CertificateType.unknown:
        return "Unknown";
    }
  }

  String getDuration(ValidationResult cert) {
    switch (cert.certificate!.certificateType) {
      case CertificateType.vaccination:
        var vac = (cert.certificate!.entryList[0] as CertEntryVaccination);
        return DateTime.now()
                .difference(vac.dateOfVaccination)
                .inDays
                .toString() +
            " Days since first vac";
      case CertificateType.recovery:
        var rec = (cert.certificate!.entryList[0] as CertEntryRecovery);
        return rec.validUntil
            .difference(DateTime.now())
            .inDays
            .toString() +
            " Days still valid";
      case CertificateType.test:
        var test = (cert.certificate!.entryList[0] as CertEntryTest);
        return DateTime.now()
            .difference(test.timeSampleCollection)
            .inHours
            .toString() +
            " Hours";
      case CertificateType.unknown:
        return "Unknown";
    }
  }
}
