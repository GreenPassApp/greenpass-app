import 'package:country_codes/country_codes.dart';

import 'cert_entry.dart';

class CertEntryRecovery extends CertEntry {
  final DateTime firstPositiveTestResult;
  final DateTime validFrom;
  final DateTime validUntil;

  CertEntryRecovery({
    required String certificateIdentifier,
    required String certificateIssuer,
    required CountryDetails? country,
    required String targetedDiseaseCode,

    required this.firstPositiveTestResult,
    required this.validFrom,
    required this.validUntil,
  }) : super(
    certificateIdentifier: certificateIdentifier,
    certificateIssuer: certificateIssuer,
    country: country,
    targetedDiseaseCode: targetedDiseaseCode,
  );
}