import 'package:country_codes/country_codes.dart';
import 'package:greenpass_app/green_validator/payload/certificate_type.dart';
import 'package:greenpass_app/green_validator/payload/person_info.dart';

import 'cert_entry.dart';

class GreenCertificate {
  final String rawData;

  final DateTime issuedAt;
  final DateTime expiresAt;
  final CountryDetails? issuer;
  final CertificateType certificateType;

  final PersonInfo personInfo;
  final List<CertEntry> entryList;

  GreenCertificate({
    required this.rawData,
    required this.issuedAt,
    required this.expiresAt,
    required this.issuer,
    required this.certificateType,
    required this.personInfo,
    required this.entryList,
  });
}