enum ValidationErrorCode {
  none,
  unable_to_parse,
  invalid_signature,
  not_against_sars_cov_2, // positive test or wrong target disease
  certificate_expired,
}