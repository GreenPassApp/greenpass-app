import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greenpass_app/green_validator/green_validator.dart';
import 'package:greenpass_app/green_validator/model/validation_result.dart';
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';
import 'package:greenpass_app/my_certs/my_cert.dart';
import 'package:greenpass_app/my_certs/my_certs_result.dart';

class MyCerts {
  static List<MyCert>? _myCerts;

  static Future<void> initAppStart() async {
    if (await FlutterSecureStorage().read(key: 'myCerts') == null) {
      await FlutterSecureStorage().write(key: 'myCerts', value: jsonEncode([]));
      await FlutterSecureStorage().write(key: 'myCertsVer', value: '1'); // in case something changes
    }

    _myCerts = (jsonDecode((await FlutterSecureStorage().read(key: 'myCerts'))!) as List)
      .map((e) => MyCert.fromJson(e)).toList();
  }

  static Future<void> setCertList(List<MyCert> newList) async {
    _myCerts = newList;
    await _saveCurrentList();
  }

  static Future<void> addCert(MyCert cert) async {
    _myCerts!.insert(0, cert);
    await _saveCurrentList();
  }

  static Future<void> removeCert(String qrCode) async {
    _myCerts!.removeWhere((c) => c.qrCode == qrCode);
    await _saveCurrentList();
  }

  static List<MyCert> getCurrentCerts() {
    return _myCerts!;
  }

  static Future<MyCertsResult> getGreenCerts() async {
    List<GreenCertificate> certs = [];
    int deleted = 0;
    _myCerts!.forEach((cert) {
      ValidationResult res = GreenValidator.validate(cert.qrCode);
      if (!res.success) {
        _myCerts!.remove(cert);
        deleted++;
      } else {
        certs.add(res.certificate!);
      }
    });

    if (deleted != 0)
      await _saveCurrentList();

    return MyCertsResult(
      certificates: certs,
      invalidCertificatesDeleted: deleted,
    );
  }

  static Future<void> _saveCurrentList() async {
    await FlutterSecureStorage().write(key: 'myCerts', value: jsonEncode(_myCerts));
  }
}