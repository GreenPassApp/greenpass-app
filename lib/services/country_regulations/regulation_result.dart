class RegulationResult {
  final DateTime? validFrom;
  final DateTime? validUntil;

  static final RegulationResult invalid = RegulationResult(validFrom: null, validUntil: null);

  RegulationResult({required this.validFrom, required this.validUntil});

  get currentlyValid => !(this.isInvalid || this.hasExpired || this.needToWait);

  get hasExpired => validUntil != null && DateTime.now().isAfter(validUntil!);

  get needToWait => validFrom != null && DateTime.now().isBefore(validFrom!);

  get isInvalid => validFrom == null;
}