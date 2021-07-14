import 'package:country_codes/country_codes.dart';
import 'package:greenpass_app/green_validator/payload/disease_type.dart';

abstract class CertEntry {
  final String certificateIdentifier;
  final String certificateIssuer;
  final CountryDetails? country;
  final String targetedDiseaseCode;

  CertEntry({
    required this.certificateIdentifier,
    required this.certificateIssuer,
    required this.country,
    required this.targetedDiseaseCode,
  });

  DiseaseType get targetedDisease {
    if (targetedDiseaseCode == '840539006') return DiseaseType.covid_19;
    return DiseaseType.unknown;
  }
}