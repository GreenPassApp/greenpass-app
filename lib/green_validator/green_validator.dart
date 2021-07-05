import 'dart:io';
import 'dart:typed_data';

import 'package:dart_base45/dart_base45.dart';
import 'package:dart_cose/dart_cose.dart';
import 'package:greenpass_app/green_validator/model/validation_error_code.dart';
import 'package:greenpass_app/green_validator/model/validation_result.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_recovery.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_test.dart';
import 'package:greenpass_app/green_validator/payload/cert_entry_vaccination.dart';
import 'package:greenpass_app/green_validator/payload/certificate_type.dart';
import 'package:greenpass_app/green_validator/payload/disease_type.dart';
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';
import 'package:greenpass_app/green_validator/payload/person_info.dart';
import 'package:greenpass_app/green_validator/payload/test_result.dart';
import 'package:greenpass_app/green_validator/utils/dgc_country_parser.dart';
import 'package:greenpass_app/green_validator/utils/dgc_date_parser.dart';
import 'package:greenpass_app/local_storage/pub_certs/pub_certs.dart';

class GreenValidator {

  // the current green certificate must start with "HC1:"
  static const String _health_certificate_prefix = 'HC1:';

  static const int _res_issued_by = 1;
  static const int _res_expires_at = 4;
  static const int _res_issued_at = 6;
  static const int _res_body = -260;
  static const int _res_body_dgc_v1 = 1;

  static ValidationResult validate(String rawInput) {
    // check if the right prefix is present
    if (!rawInput.startsWith(_health_certificate_prefix))
      return ValidationResult(errorCode: ValidationErrorCode.unable_to_parse);

    // decode base45 string (after prefix)
    Uint8List compressedData = Base45.decode(rawInput.replaceFirst(_health_certificate_prefix, ''));

    // decompress data
    List<int> coseData = zlib.decode(compressedData);

    CoseResult result = Cose.decodeAndVerify(coseData, PubCerts.getCurrentCerts());

    // check if there is something wrong with the signature
    if (result.errorCode == CoseErrorCode.kid_mismatch || result.errorCode == CoseErrorCode.key_not_found)
      return ValidationResult(errorCode: ValidationErrorCode.invalid_signature);

    // check if there were any other errors parsing the certificate
    if (result.errorCode != CoseErrorCode.none || !result.verified)
      return ValidationResult(errorCode: ValidationErrorCode.unable_to_parse);

    GreenCertificate greenCert = _parseCoseResultPayload(rawInput, result.payload);

    // check if the certificate helps against SARS-CoV-2
    if (!greenCert.entryList.any((entry) => entry.targetedDisease == DiseaseType.covid_19))
      return ValidationResult(errorCode: ValidationErrorCode.not_against_sars_cov_2);

    // check if test certificate contains negative test
    if (greenCert.certificateType == CertificateType.test
        && (greenCert.entryList[0] as CertEntryTest).testResult != TestResult.negative) {
      return ValidationResult(errorCode: ValidationErrorCode.not_against_sars_cov_2);
    }

    // check if the certificate has expired
    if (greenCert.expiresAt.isBefore(DateTime.now()))
      return ValidationResult(errorCode: ValidationErrorCode.certificate_expired);

    // check if recovery certificate has expired
    if (greenCert.certificateType == CertificateType.recovery
      && (greenCert.entryList[0] as CertEntryRecovery).validUntil.isBefore(DateTime.now())) {
      return ValidationResult(errorCode: ValidationErrorCode.certificate_expired);
    }

    // all good
    return ValidationResult(certificate: greenCert);
  }

  static GreenCertificate _parseCoseResultPayload(String rawInput, var payload) {
    Map body = payload[_res_body][_res_body_dgc_v1];

    CertificateType type;
    if (body.containsKey('v'))
      type = CertificateType.vaccination;
    else if (body.containsKey('r'))
      type = CertificateType.recovery;
    else if (body.containsKey('t'))
      type = CertificateType.test;
    else
      type = CertificateType.unknown;

    PersonInfo pInfo = PersonInfo(
      firstName: body['nam']['gn'].toString().trim(),
      lastName: body['nam']['fn'].toString().trim(),
      dateOfBirth: DGCDateParser.fromDateString(body['dob']),
    );

    return GreenCertificate(
      rawData: rawInput,
      issuedAt: DGCDateParser.fromCwtSeconds(payload[_res_issued_at]),
      expiresAt: DGCDateParser.fromCwtSeconds(payload[_res_expires_at]),
      issuer: DGCCountryParser.fromCountryCode(payload[_res_issued_by]),
      certificateType: type,
      personInfo: pInfo,
      entryList: _createEntryList(body, type),
    );
  }

  static List<CertEntry> _createEntryList(Map certBody, CertificateType certType) {
    switch (certType) {
      case CertificateType.vaccination:
        return _createVaccinationList(certBody);
      case CertificateType.recovery:
        return _createRecoveryList(certBody);
      case CertificateType.test:
        return _createTestList(certBody);
      case CertificateType.unknown:
      default:
        return List<CertEntry>.empty(growable: false);
    }
  }

  static List<CertEntryVaccination> _createVaccinationList(Map certBody) {
    List<CertEntryVaccination> vacs = [];
    (certBody['v'] as List).forEach((v) {
      vacs.add(CertEntryVaccination(
        certificateIdentifier: v['ci'],
        certificateIssuer: v['is'],
        country: DGCCountryParser.fromCountryCode(v['co']),
        targetedDiseaseCode: v['tg'],

        vaccineCode: v['vp'],
        medicalProductCode: v['mp'],
        manufacturerCode: v['ma'],
        doseNumber: v['dn'],
        dosesNeeded: v['sd'],
        dateOfVaccination: DGCDateParser.fromDateString(v['dt']),
      ));
    });
    return vacs;
  }

  static List<CertEntryRecovery> _createRecoveryList(Map certBody) {
    List<CertEntryRecovery> recs = [];
    (certBody['r'] as List).forEach((r) {
      recs.add(CertEntryRecovery(
        certificateIdentifier: r['ci'],
        certificateIssuer: r['is'],
        country: DGCCountryParser.fromCountryCode(r['co']),
        targetedDiseaseCode: r['tg'],

        firstPositiveTestResult: DGCDateParser.fromDateString(r['fr']),
        validFrom: DGCDateParser.fromDateString(r['df']),
        validUntil: DGCDateParser.fromDateString(r['du']),
      ));
    });
    return recs;
  }

  static List<CertEntryTest> _createTestList(Map certBody) {
    List<CertEntryTest> tests = [];
    (certBody['t'] as List).forEach((t) {
      tests.add(CertEntryTest(
        certificateIdentifier: t['ci'],
        certificateIssuer: t['is'],
        country: DGCCountryParser.fromCountryCode(t['co']),
        targetedDiseaseCode: t['tg'],

        testTypeCode: t['tt'],
        testResultCode: t['tr'],
        testingCentreName: t['tc'],
        timeSampleCollection: DGCDateParser.fromDateString(t['sc']),
        timeTestResult: (t as Map).containsKey('dr') ? DGCDateParser.fromDateString(t['dr']) : null,
        testName: t.containsKey('nm') ? t['nm'] : null,
        manufacturerName: t.containsKey('ma') ? t['ma'] : null,
      ));
    });
    return tests;
  }
}