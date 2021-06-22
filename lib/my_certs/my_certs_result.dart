import 'package:greenpass_app/green_validator/payload/green_certificate.dart';

class MyCertsResult {
  final List<GreenCertificate> certificates;
  final int invalidCertificatesDeleted;

  MyCertsResult({required this.certificates, required this.invalidCertificatesDeleted});
}