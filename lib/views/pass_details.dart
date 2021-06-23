import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/connectivity/apple_wallet.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/elements/colored_card.dart';
import 'package:greenpass_app/elements/pass_info.dart';
import 'package:greenpass_app/elements/platform_alert_dialog.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_recovery.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_test.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_vaccination.dart';
import 'package:greenpass_app/green_validator/payload/certificate_type.dart';
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';
import 'package:greenpass_app/green_validator/payload/test_result.dart';
import 'package:greenpass_app/green_validator/payload/vaccine_type.dart';
import 'package:greenpass_app/my_certs/my_certs.dart';
import 'package:intl/intl.dart';

class PassDetails extends StatelessWidget {
  final GreenCertificate cert;

  const PassDetails({Key? key, required this.cert}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Certificate details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            FontAwesome5Solid.arrow_left,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              FontAwesome5Solid.trash_alt,
              color: Colors.black,
            ),
            onPressed: () {
              PlatformAlertDialog.showAlertDialog(
                context: context,
                title: 'Pass löschen?',
                text: 'Bist du sicher, dass du diesen Pass löschen möchtest? Die Wiederherstellung der Daten ist nicht möglich.',
                dismissButtonText: 'Abbruch',
                actionButtonText: 'Löschen',
                action: () async {
                  await MyCerts.removeQrCode(cert.rawData);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
                    child: ColoredCard.buildCard(
                      backgroundColor: GPColors.blue,
                      child: Row(
                        children: [
                          ColoredCard.buildIcon(cert, size: 25.0, circleBorder: 3, circlePadding: 15.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PassInfo.getTypeText(
                                cert,
                                textSize: 20.0,
                                additionalTextSize: 15.0,
                                showTestType: false,
                              ),
                              Padding(padding: const EdgeInsets.symmetric(vertical: 2.0)),
                              Text(
                                PassInfo.getDate(cert),
                                style: TextStyle(
                                  color: Colors.white,
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
            ),
            if (Platform.isIOS) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            height: 40.0,
                            width: 40.0,
                            image: AssetImage('assets/images/AppleWallet.png'),
                          ),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 6.0)),
                          Text(
                            'Add to Apple Wallet',
                            style: TextStyle(
                            ),
                          ),
                        ],
                      ),
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        backgroundColor: MaterialStateProperty.all(Colors.black),
                        overlayColor: MaterialStateProperty.all(GPColors.dark_grey),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),
                      ),
                      onPressed: () {
                        PlatformAlertDialog.showAlertDialog(
                          context: context,
                          title: 'Hinweis',
                          text: 'Das Zertifikat wird aus technischen Gründen an uns gesendet, um einen Apple Wallet-Pass erzeugen zu können. Dabei speichern dieses Zertifikat nicht länger, als für die Erzeugung notwendig, was im Normalfall wenige Sekunden dauert.',
                          dismissButtonText: 'Abbruch',
                          actionButtonText: 'Pass erzeugen',
                          action: () => AppleWallet.getAppleWalletPass(rawCert: cert.rawData, serialNumber: cert.personInfo.pseudoIdentifier),
                        );
                      }
                    ),
                  ],
                ),
              ),
            ],
            Padding(padding: const EdgeInsets.symmetric(vertical: 14.0)),
            _listPadding(_groupText('Person info')),
            _horizontalLine(),
            _entryText('Full name', cert.personInfo.fullName),
            _horizontalLine(),
            _entryText('Date of birth', DateFormat('dd.MM.yyyy').format(cert.personInfo.dateOfBirth)),
            Padding(padding: const EdgeInsets.symmetric(vertical: 30.0)),

            if (cert.certificateType == CertificateType.test) ...[
              _listPadding(_groupText('Test')),
              _horizontalLine(),
              _entryText('Test type', PassInfo.testType((cert.entryList[0] as CertEntryTest).testType)),
              _horizontalLine(),
              _entryText('Test result', _testResult((cert.entryList[0] as CertEntryTest).testResult)),
              _horizontalLine(),
              _entryText('Testing centre', (cert.entryList[0] as CertEntryTest).testingCentreName),
              _horizontalLine(),
              _entryText('Time of sample collection', DateFormat('hh:mm, dd.MM.yyyy').format((cert.entryList[0] as CertEntryTest).timeSampleCollection)),
              if ((cert.entryList[0] as CertEntryTest).timeTestResult != null) ...[
                _horizontalLine(),
                _entryText('Time of test result', DateFormat('hh:mm, dd.MM.yyyy').format((cert.entryList[0] as CertEntryTest).timeTestResult!)),
              ],
              if ((cert.entryList[0] as CertEntryTest).testName != null) ...[
                _horizontalLine(),
                _entryText('Test name', (cert.entryList[0] as CertEntryTest).testName!),
              ],
              if ((cert.entryList[0] as CertEntryTest).manufacturerName != null) ...[
                _horizontalLine(),
                _entryText('Test manufacturer', (cert.entryList[0] as CertEntryTest).manufacturerName!),
              ],
            ],

            if (cert.certificateType == CertificateType.recovery) ...[
              _listPadding(_groupText('Recovery')),
              _horizontalLine(),
              _entryText('First positive test result', DateFormat('dd.MM.yyyy').format((cert.entryList[0] as CertEntryRecovery).firstPositiveTestResult)),
              _horizontalLine(),
              _entryText('Certificate valid from', DateFormat('dd.MM.yyyy').format((cert.entryList[0] as CertEntryRecovery).validFrom)),
              _horizontalLine(),
              _entryText('Certificate valid until', DateFormat('dd.MM.yyyy').format((cert.entryList[0] as CertEntryRecovery).validUntil)),
              _horizontalLine(),
            ],

            if (cert.certificateType == CertificateType.vaccination) ...[
              for (CertEntryVaccination vac in cert.entryList.map((e) => e as CertEntryVaccination)) ...[
                _listPadding(_groupText('Vaccination (' + vac.doseNumber.toString() + '/' + vac.dosesNeeded.toString() + ')')),
                _horizontalLine(),
                _entryText('Vaccine type', _vaccineType(vac.vaccine)),
                _horizontalLine(),
                _entryText('Vaccine', vac.medicalProduct),
                _horizontalLine(),
                _entryText('Manufacturer', vac.manufacturer),
              ],
            ],

            Padding(padding: const EdgeInsets.symmetric(vertical: 30.0)),
            _listPadding(_groupText('Certificate info')),
            _horizontalLine(),
            _entryText('Issuer', cert.entryList[0].certificateIssuer),
            _horizontalLine(),
            _entryText('Issuing country', cert.entryList[0].country.localizedName!),
            _horizontalLine(),
            _entryText('Certificate identifier', cert.entryList[0].certificateIdentifier),
            Padding(padding: const EdgeInsets.symmetric(vertical: 20.0)),
          ],
        ),
      ),
    );
  }

  String _vaccineType(VaccineType vaccineType) {
    if (vaccineType == VaccineType.antigen) return 'Antigen';
    if (vaccineType == VaccineType.mRna) return 'mRNA';
    return 'Other';
  }

  String _testResult(TestResult testResult) {
    if (testResult == TestResult.negative) return 'Negative';
    if (testResult == TestResult.positive) return 'Positive';
    return 'Unknown';
  }

  Widget _horizontalLine() {
    return Divider(
      height: 25,
      thickness: 1,
    );
  }

  Widget _groupText(String txt) {
    return Text(
      txt,
      style: TextStyle(
        color: GPColors.dark_grey,
      ),
    );
  }

  Widget _entryText(String name, String val) {
    return _listPadding(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              color: GPColors.almost_black,
              fontSize: 12.0,
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: 1.0)),
          Text(
            val,
            style: TextStyle(
              color: GPColors.almost_black,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      )
    );
  }

  Widget _listPadding(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4.0),
      child: child,
    );
  }
}
