import 'package:greenpass_app/green_validator/model/validation_error_code.dart';
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';

class ValidationResult {
  final GreenCertificate? certificate;
  final ValidationErrorCode errorCode;

  ValidationResult({
    this.certificate,
    this.errorCode = ValidationErrorCode.none,
  });

  get success {
    return errorCode == ValidationErrorCode.none;
  }
}