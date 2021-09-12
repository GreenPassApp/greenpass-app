class AndroidUpdateCheckResult {
  String installedVersion;
  String newestVersion;
  DateTime updatedAt;
  String downloadUrl;
  String sha256Checksum;
  Map<String, dynamic>? changelog;

  AndroidUpdateCheckResult({
    required this.installedVersion,
    required this.newestVersion,
    required this.updatedAt,
    required this.downloadUrl,
    required this.sha256Checksum,
    this.changelog,
  });

  get updateAvailable => this.installedVersion != this.newestVersion;
}