import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/connectivity/apple_wallet.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/elements/list_elements.dart';
import 'package:greenpass_app/elements/pass_info.dart';
import 'package:greenpass_app/elements/platform_alert_dialog.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_recovery.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_test.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_vaccination.dart';
import 'package:greenpass_app/green_validator/payload/certificate_type.dart';
import 'package:greenpass_app/green_validator/payload/disease_type.dart';
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';
import 'package:greenpass_app/green_validator/payload/test_result.dart';
import 'package:greenpass_app/green_validator/payload/vaccine_type.dart';
import 'package:greenpass_app/local_storage/my_certs/my_certs.dart';
import 'package:greenpass_app/local_storage/settings.dart';
import 'package:intl/intl.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class PassDetails extends StatefulWidget {
  final GreenCertificate cert;

  const PassDetails({Key? key, required this.cert}) : super(key: key);

  @override
  _PassDetailsState createState() => _PassDetailsState(cert: cert);
}

class _PassDetailsState extends State<PassDetails> {
  final GreenCertificate cert;

  _PassDetailsState({required this.cert});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Certificate details'.tr(),
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
            onPressed: () => _delete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PassInfo.getSmallPassCard(cert, travelMode: Settings.getTravelMode()),
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
                          Text('Add to Apple Wallet'.tr()),
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
                          title: 'Notice'.tr(),
                          text: 'The certificate is sent to us for technical reasons in order to generate an Apple Wallet pass. This certificate is not stored longer than necessary for generation, which normally takes a few seconds.'.tr(),
                          dismissButtonText: 'Cancel'.tr(),
                          actionButtonText: 'Create pass'.tr(),
                          action: () => AppleWallet.getAppleWalletPass(rawCert: cert.rawData, serialNumber: cert.personInfo.pseudoIdentifier),
                        );
                      }
                    ),
                  ],
                ),
              ),
              Padding(padding: const EdgeInsets.symmetric(vertical: 7.0)),
            ],
            Padding(padding: const EdgeInsets.symmetric(vertical: 14.0)),
            ListElements.listPadding(ListElements.groupText(Settings.translateTravelMode('Person info'))),
            ListElements.horizontalLine(),
            ListElements.entryText(Settings.translateTravelMode('Full name'), cert.personInfo.fullName),
            ListElements.horizontalLine(),
            ListElements.entryText(Settings.translateTravelMode('Date of birth'), DateFormat('dd.MM.yyyy').format(cert.personInfo.dateOfBirth)),
            Padding(padding: const EdgeInsets.symmetric(vertical: 30.0)),

            if (cert.certificateType == CertificateType.test) ...[
              ListElements.listPadding(ListElements.groupText(Settings.translateTravelMode('Test'))),
              ListElements.horizontalLine(),
              ListElements.entryText(Settings.translateTravelMode('Tested for'), _targetedDisease(cert.entryList[0].targetedDisease)),
              ListElements.horizontalLine(),
              ListElements.entryText(Settings.translateTravelMode('Test type'), PassInfo.testType((cert.entryList[0] as CertEntryTest).testType, travelMode: Settings.getTravelMode())),
              ListElements.horizontalLine(),
              ListElements.entryText(Settings.translateTravelMode('Test result'), _testResult((cert.entryList[0] as CertEntryTest).testResult)),
              ListElements.horizontalLine(),
              ListElements.entryText(Settings.translateTravelMode('Testing centre'), (cert.entryList[0] as CertEntryTest).testingCentreName),
              ListElements.horizontalLine(),
              ListElements.entryText(Settings.translateTravelMode('Time of sample collection'), DateFormat('HH:mm, dd.MM.yyyy').format((cert.entryList[0] as CertEntryTest).timeSampleCollection)),
              if ((cert.entryList[0] as CertEntryTest).timeTestResult != null) ...[
                ListElements.horizontalLine(),
                ListElements.entryText(Settings.translateTravelMode('Time of test result'), DateFormat('HH:mm, dd.MM.yyyy').format((cert.entryList[0] as CertEntryTest).timeTestResult!)),
              ],
              if ((cert.entryList[0] as CertEntryTest).testName != null) ...[
                ListElements.horizontalLine(),
                ListElements.entryText(Settings.translateTravelMode('Test name'), (cert.entryList[0] as CertEntryTest).testName!),
              ],
              if ((cert.entryList[0] as CertEntryTest).manufacturerName != null) ...[
                ListElements.horizontalLine(),
                ListElements.entryText(Settings.translateTravelMode('Test manufacturer'), (cert.entryList[0] as CertEntryTest).manufacturerName!),
              ],
            ],

            if (cert.certificateType == CertificateType.recovery) ...[
              ListElements.listPadding(ListElements.groupText(Settings.translateTravelMode('Recovery'))),
              ListElements.horizontalLine(),
              ListElements.entryText(Settings.translateTravelMode('Recovered from'), _targetedDisease(cert.entryList[0].targetedDisease)),
              ListElements.horizontalLine(),
              ListElements.entryText(Settings.translateTravelMode('First positive test result'), DateFormat('dd.MM.yyyy').format((cert.entryList[0] as CertEntryRecovery).firstPositiveTestResult)),
              ListElements.horizontalLine(),
              ListElements.entryText(Settings.translateTravelMode('Certificate valid from'), DateFormat('dd.MM.yyyy').format((cert.entryList[0] as CertEntryRecovery).validFrom)),
              ListElements.horizontalLine(),
              ListElements.entryText(Settings.translateTravelMode('Certificate valid until'), DateFormat('dd.MM.yyyy').format((cert.entryList[0] as CertEntryRecovery).validUntil)),
            ],

            if (cert.certificateType == CertificateType.vaccination) ...[
              for (CertEntryVaccination vac in cert.entryList.map((e) => e as CertEntryVaccination)) ...[
                ListElements.listPadding(ListElements.groupText(Settings.translateTravelMode('Vaccination ({}/{})', args: [vac.doseNumber.toString(), vac.dosesNeeded.toString()]))),
                ListElements.horizontalLine(),
                ListElements.entryText(Settings.translateTravelMode('Vaccinated against'), _targetedDisease(vac.targetedDisease)),
                ListElements.horizontalLine(),
                ListElements.entryText(Settings.translateTravelMode('Vaccine type'), _vaccineType(vac.vaccine)),
                ListElements.horizontalLine(),
                ListElements.entryText(Settings.translateTravelMode('Vaccine'), vac.medicalProduct),
                ListElements.horizontalLine(),
                ListElements.entryText(Settings.translateTravelMode('Manufacturer'), vac.manufacturer),
              ],
            ],

            Padding(padding: const EdgeInsets.symmetric(vertical: 30.0)),
            ListElements.listPadding(ListElements.groupText(Settings.translateTravelMode('Certificate info'))),
            ListElements.horizontalLine(),
            ListElements.entryText(Settings.translateTravelMode('Issuer'), cert.entryList[0].certificateIssuer),
            ListElements.horizontalLine(),
            ListElements.entryText(Settings.translateTravelMode('Issuing country'), Settings.getTravelMode() ? cert.entryList[0].country.name! : cert.entryList[0].country.localizedName!),
            ListElements.horizontalLine(),
            ListElements.entryText(Settings.translateTravelMode('Certificate identifier'), cert.entryList[0].certificateIdentifier),
            Padding(padding: const EdgeInsets.symmetric(vertical: 15.0)),
            AspectRatio(
              aspectRatio: 1,
              child: FittedBox(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(const Radius.circular(4.0))
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: PrettyQr(
                            data: cert.rawData,
                            errorCorrectLevel: QrErrorCorrectLevel.L,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(FontAwesome5Solid.trash_alt, size: 18.0),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(GPColors.red),
                        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8.0))
                      ),
                      label: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Delete certificate'.tr(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      onPressed: () => _delete(context),
                    ),
                  ],
                ),
              ],
            ),
            Padding(padding: const EdgeInsets.symmetric(vertical: 20.0)),
          ],
        ),
      ),
    );
  }

  void _delete(BuildContext context) {
    PlatformAlertDialog.showAlertDialog(
      context: context,
      title: 'Delete pass?'.tr(),
      text: 'Are you sure you want to delete this pass? The restoration of the pass will not be possible.'.tr(),
      dismissButtonText: 'Cancel'.tr(),
      actionButtonText: 'Delete'.tr(),
      action: () async {
        await MyCerts.removeCert(cert.rawData);
        Navigator.of(context).pop();
      },
    );
  }

  String _targetedDisease(DiseaseType targetedDisease) {
    if (targetedDisease == DiseaseType.covid_19) return Settings.translateTravelMode('COVID-19');
    return Settings.translateTravelMode('Other');
  }

  String _vaccineType(VaccineType vaccineType) {
    if (vaccineType == VaccineType.antigen) return Settings.translateTravelMode('Antigen');
    if (vaccineType == VaccineType.mRna) return Settings.translateTravelMode('mRNA');
    return Settings.translateTravelMode('Other');
  }

  String _testResult(TestResult testResult) {
    if (testResult == TestResult.negative) return Settings.translateTravelMode('Negative');
    if (testResult == TestResult.positive) return Settings.translateTravelMode('Positive');
    return Settings.translateTravelMode('Unknown');
  }
}