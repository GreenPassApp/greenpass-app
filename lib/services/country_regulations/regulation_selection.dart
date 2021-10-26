class RegulationSelection {

  final String countryCode;
  final String? subregionCode;
  final String? rule;

  RegulationSelection(this.countryCode, this.subregionCode, this.rule);

  @override
  bool operator ==(Object other) {
    if (!(other is RegulationSelection)) return false;
    return other.countryCode == countryCode && other.subregionCode == subregionCode && other.rule == rule;
  }

  @override
  int get hashCode => (countryCode + ';' + (subregionCode ?? '') + ';' + (rule ?? '')).hashCode;

  RegulationSelection copyWith({String countryCode = '\0', String? subregionCode = '\0', String? rule = '\0'}) {
    return RegulationSelection(
      countryCode == '\0' ? this.countryCode : countryCode,
      subregionCode == '\0' ? this.subregionCode : subregionCode,
      rule == '\0' ? this.rule : rule
    );
  }
}