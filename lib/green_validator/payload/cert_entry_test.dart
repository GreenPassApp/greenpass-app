import 'package:country_codes/country_codes.dart';

import 'cert_entry.dart';

class CertEntryTest extends CertEntry {
  final String testTypeCode;
  final String testResultCode;
  final String testingCentreName;
  final DateTime timeSampleCollection;
  final DateTime? timeTestResult;
  final String? testName;
  final String? manufacturerName;

  CertEntryTest({
    required String certificateIdentifier,
    required String certificateIssuer,
    required CountryDetails country,
    required String targetedDiseaseCode,

    required this.testTypeCode,
    required this.testResultCode,
    required this.testingCentreName,
    required this.timeSampleCollection,
    this.timeTestResult,
    this.testName,
    this.manufacturerName,
  }) : super(
    certificateIdentifier: certificateIdentifier,
    certificateIssuer: certificateIssuer,
    country: country,
    targetedDiseaseCode: targetedDiseaseCode,
  );
}