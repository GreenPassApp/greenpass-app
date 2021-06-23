import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greenpass_app/green_validator/green_validator.dart';
import 'package:greenpass_app/green_validator/model/validation_result.dart';
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';
import 'package:greenpass_app/my_certs/my_certs_result.dart';

class MyCerts {
  static List<String>? _myQrCodes;

  static Future<void> initAppStart() async {
    if (await FlutterSecureStorage().read(key: 'myCerts') == null) {
      await FlutterSecureStorage().write(key: 'myCerts', value: jsonEncode([]));
      await FlutterSecureStorage().write(key: 'myCertsVer', value: '1'); // in case something changes
    }

    _myQrCodes = (jsonDecode((await FlutterSecureStorage().read(key: 'myCerts'))!) as List)
      .map((e) => e as String).toList();
  }

  static Future<void> setQrCodeList(List<String> newList) async {
    _myQrCodes = newList;
    await _saveCurrentList();
  }

  static Future<void> addQrCode(String qrCode) async {
    _myQrCodes!.insert(0, qrCode);
    await _saveCurrentList();
  }

  static Future<void> removeQrCode(String qrCode) async {
    _myQrCodes!.remove(qrCode);
    await _saveCurrentList();
  }

  static List<String> getCurrentQrCodes() {
    return _myQrCodes!;
  }

  static Future<MyCertsResult> getGreenCerts() async {
    List<GreenCertificate> certs = [];
    int deleted = 0;
    _myQrCodes!.forEach((qrCode) {
      ValidationResult res = GreenValidator.validate(qrCode);
      if (!res.success) {
        _myQrCodes!.remove(qrCode);
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
    await FlutterSecureStorage().write(key: 'myCerts', value: jsonEncode(_myQrCodes));
  }
}