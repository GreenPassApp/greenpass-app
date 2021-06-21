import 'package:country_codes/country_codes.dart';
import 'package:greenpass_app/green_validator/payload/test_result.dart';
import 'package:greenpass_app/green_validator/payload/test_type.dart';

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

  TestType get testType {
    if (testTypeCode == 'LP217198-3') return TestType.rapid;
    if (testTypeCode == 'LP6464-4') return TestType.pcr;
    return TestType.unknown;
  }

  TestResult get testResult {
    if (testResultCode == '260415000') return TestResult.negative;
    if (testResultCode == '260373001') return TestResult.positive;
    return TestResult.unknown;
  }
}