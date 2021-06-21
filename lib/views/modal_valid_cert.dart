import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/green_validator/green_validator.dart';
import 'package:greenpass_app/green_validator/model/validation_result.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_recovery.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_test.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_vaccination.dart';
import 'package:greenpass_app/green_validator/payload/certificate_type.dart';
import 'package:greenpass_app/green_validator/payload/test_result.dart';
import 'package:greenpass_app/green_validator/payload/test_type.dart';
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
            leading: Container(), middle: Text('Certificate')),
        child: SafeArea(
          bottom: false,
          child: Container(
            constraints: BoxConstraints.expand(),
            child: Column(
              children: [
                Container(
                  decoration: new BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.30),
                        blurRadius: 20.0, // soften the shadow
                        spreadRadius: -25.0, //extend the shadow
                        offset: Offset(
                          4.0,
                          4.0,
                        ),
                      )
                    ],
                  ),
                  child: Card(
                    color: Color(0xFFB135ACF),
                    margin: EdgeInsets.all(25.0),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Color(0xFFB135ACF), width: 1),
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
                                    padding: EdgeInsets.all(20.0),
                                    child: Container(
                                      margin: EdgeInsets.all(20),
                                      padding: EdgeInsets.all(30),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(150),
                                          border: Border.all(
                                              width: 4, color: Colors.white)),
                                      child: Icon(
                                        getIcon(cert),
                                        color: Colors.white,
                                        size: 60.0,
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
                                        color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold),
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
                                  padding: EdgeInsets.all(35.0),
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
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 5.0, left: 0.0),
                      child: Icon(
                        FontAwesome5Solid.user,
                        size: 30,
                      ),
                    ),
                    title: Text(
                        cert.certificate!.personInfo.firstName +
                            " " +
                            cert.certificate!.personInfo.lastName,
                        style: TextStyle(color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        DateFormat('dd.MM.yyyy').format(cert.certificate!.personInfo.dateOfBirth),
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
        return FontAwesome5Solid.syringe;
      case CertificateType.recovery:
        return FontAwesome5Solid.child;
      case CertificateType.test:
        return FontAwesome5Solid.vial;
      case CertificateType.unknown:
        return FontAwesome5Solid.times;
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
        return "Tested - " + (test.testType == TestType.pcr ? "PCR" : "Rapid") + " " +
            (test.testResult == TestResult.negative ? "Negative" : "Positive");
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
