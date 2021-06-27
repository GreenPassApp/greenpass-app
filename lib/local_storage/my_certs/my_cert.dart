import 'package:greenpass_app/local_storage/my_certs/my_cert_share.dart';

class MyCert {
  final String qrCode;
  MyCertShare? share;

  MyCert({required this.qrCode, this.share});

  MyCert.fromJson(Map<String, dynamic> json)
    : this.qrCode = json['qr'], this.share = json.containsKey('s') ? MyCertShare.fromJson(json['s']) : null;

  Map<String, dynamic> toJson() => {
    'qr': this.qrCode,
    if (share != null) 's': share,
  };
}