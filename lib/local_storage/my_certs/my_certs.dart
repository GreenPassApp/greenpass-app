import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:greenpass_app/green_validator/green_validator.dart';
import 'package:greenpass_app/green_validator/model/validation_result.dart';
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';
import 'package:greenpass_app/local_storage/my_certs/my_cert.dart';
import 'package:greenpass_app/local_storage/my_certs/my_certs_result.dart';
import 'package:hive/hive.dart';

import 'package:greenpass_app/local_storage/hive_provider.dart';

class MyCerts {
  static List<MyCert>? _myCerts;

  static const String _hiveBoxName = 'myCerts';
  static const String _hiveBoxKey = 'myCertsKey';

  static Future<void> initAppStart() async {
    Box box = await HiveProvider.getEncryptedBox(boxName: _hiveBoxName, boxKeyName: _hiveBoxKey);
    if (await box.get('myCerts') == null) {
      await box.put('myCerts', jsonEncode([]));
      await box.put('myCertsVer', '1'); // in case something changes
    }

    _myCerts = (jsonDecode((await box.get('myCerts'))!) as List)
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
    Box box = await HiveProvider.getEncryptedBox(boxName: _hiveBoxName, boxKeyName: _hiveBoxKey);
    await box.put('myCerts', jsonEncode(_myCerts));
    await box.compact();
  }
}