import 'package:country_codes/country_codes.dart';

abstract class CertEntry {
  final String certificateIdentifier;
  final String certificateIssuer;
  final CountryDetails country;
  final String targetedDiseaseCode;

  CertEntry({
    required this.certificateIdentifier,
    required this.certificateIssuer,
    required this.country,
    required this.targetedDiseaseCode,
  });
}