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
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';
import 'package:greenpass_app/green_validator/payload/person_info.dart';
import 'package:greenpass_app/green_validator/utils/dgc_country_parser.dart';
import 'package:greenpass_app/green_validator/utils/dgc_date_parser.dart';

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

    // TODO refactor
    CoseResult result = Cose.decodeAndVerify(
      coseData,
      {
        'DEsVUSvpFAE=': '''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''',
        '2Rk3X8HntrI=': '''MIIBvTCCAWOgAwIBAgIKAXk8i88OleLsuTAKBggqhkjOPQQDAjA2MRYwFAYDVQQDDA1BVCBER0MgQ1NDQSAxMQswCQYDVQQGEwJBVDEPMA0GA1UECgwGQk1TR1BLMB4XDTIxMDUwNTEyNDEwNloXDTIzMDUwNTEyNDEwNlowPTERMA8GA1UEAwwIQVQgRFNDIDExCzAJBgNVBAYTAkFUMQ8wDQYDVQQKDAZCTVNHUEsxCjAIBgNVBAUTATEwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAASt1Vz1rRuW1HqObUE9MDe7RzIk1gq4XW5GTyHuHTj5cFEn2Rge37+hINfCZZcozpwQKdyaporPUP1TE7UWl0F3o1IwUDAOBgNVHQ8BAf8EBAMCB4AwHQYDVR0OBBYEFO49y1ISb6cvXshLcp8UUp9VoGLQMB8GA1UdIwQYMBaAFP7JKEOflGEvef2iMdtopsetwGGeMAoGCCqGSM49BAMCA0gAMEUCIQDG2opotWG8tJXN84ZZqT6wUBz9KF8D+z9NukYvnUEQ3QIgdBLFSTSiDt0UJaDF6St2bkUQuVHW6fQbONd731/M4nc='''
      },
    );

    // check if there is something wrong with the signature
    if (result.errorCode == CoseErrorCode.kid_mismatch || result.errorCode == CoseErrorCode.key_not_found)
      return ValidationResult(errorCode: ValidationErrorCode.invalid_signature);

    // check if there were any other errors parsing the certificate
    if (result.errorCode != CoseErrorCode.none || !result.verified)
      return ValidationResult(errorCode: ValidationErrorCode.unable_to_parse);

    GreenCertificate greenCert = _parseCoseResultPayload(result.payload);

    // check if the certificate has expired
    if (greenCert.expiresAt.isBefore(DateTime.now()))
      return ValidationResult(errorCode: ValidationErrorCode.certificate_expired);

    // all good
    return ValidationResult(certificate: greenCert);
  }

  static GreenCertificate _parseCoseResultPayload(var payload) {
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
      firstName: body['nam']['gn'],
      lastName: body['nam']['fn'],
      dateOfBirth: DGCDateParser.fromDateString(body['dob']),
    );

    return GreenCertificate(
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