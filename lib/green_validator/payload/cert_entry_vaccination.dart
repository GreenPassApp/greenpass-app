import 'package:country_codes/country_codes.dart';

import 'cert_entry.dart';

class CertEntryVaccination extends CertEntry {
  final String vaccineCode; // type, not the concrete product
  final String medicalProductCode;
  final String manufacturerCode;
  final int doseNumber;
  final int dosesNeeded;
  final DateTime dateOfVaccination;

  CertEntryVaccination({
    required String certificateIdentifier,
    required String certificateIssuer,
    required CountryDetails country,
    required String targetedDiseaseCode,

    required this.vaccineCode,
    required this.medicalProductCode,
    required this.manufacturerCode,
    required this.doseNumber,
    required this.dosesNeeded,
    required this.dateOfVaccination,
  }) : super(
    certificateIdentifier: certificateIdentifier,
    certificateIssuer: certificateIssuer,
    country: country,
    targetedDiseaseCode: targetedDiseaseCode,
  );
}