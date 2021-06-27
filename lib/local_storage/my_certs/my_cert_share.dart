import 'package:greenpass_app/connectivity/share_certificate.dart';

class MyCertShare {
  final String url;
  final String token;
  final DateTime validUntil;

  MyCertShare({required this.url, required this.token, required this.validUntil});

  MyCertShare.fromJson(Map<String, dynamic> json)
    : this.url = json['u'], this.token = json['t'], this.validUntil = DateTime.parse(json['vu']);

  Map<String, dynamic> toJson() => {
    'u': this.url,
    't': this.token,
    'vu': this.validUntil.toIso8601String(),
  };

  String get fullUri {
    return ShareCertificate.shareLinkPrefix + this.url;
  }
}