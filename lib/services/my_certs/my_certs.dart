import 'dart:convert';

import 'package:greenpass_app/green_validator/green_validator.dart';
import 'package:greenpass_app/green_validator/model/validation_result.dart';
import 'package:greenpass_app/green_validator/payload/green_certificate.dart';
import 'package:greenpass_app/services/my_certs/my_cert.dart';
import 'package:greenpass_app/services/my_certs/my_certs_result.dart';
import 'package:hive/hive.dart';

import 'package:greenpass_app/services/hive_provider.dart';

class MyCerts {
  static List<MyCert>? _myCerts;
  static late int _certSelection;

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

    _certSelection = await box.get('myCertsSelection') ?? 0;
    await _checkSelection();
  }

  static Future<void> setCertList(List<MyCert> newList) async {
    _myCerts = newList;
    await _checkSelection();
    await _saveCurrentList();
  }

  static Future<void> addCert(MyCert cert) async {
    _myCerts!.insert(0, cert);
    await _saveCurrentList();
  }

  static Future<void> removeCert(String qrCode) async {
    _myCerts!.removeWhere((c) => c.qrCode == qrCode);
    await _checkSelection();
    await _saveCurrentList();
  }

  static Future<void> setCertSelection(int selection) async {
    _certSelection = selection;
    Box box = await HiveProvider.getEncryptedBox(boxName: _hiveBoxName, boxKeyName: _hiveBoxKey);
    await box.put('myCertsSelection', selection);
    await box.compact();
  }

  static int getCertSelection() => _certSelection;

  static List<MyCert> getCurrentCerts() {
    return _myCerts!;
  }

  static Future<MyCertsResult> getGreenCerts() async {
    List<GreenCertificate> certs = [];
    List<MyCert> toRemove = [];
    _myCerts!.forEach((cert) {
      ValidationResult res = GreenValidator.validate(cert.qrCode);
      if (!res.success) {
        toRemove.add(cert);
      } else {
        certs.add(res.certificate!);
      }
    });

    if (toRemove.isNotEmpty) {
      toRemove.forEach((cert) {
        _myCerts!.remove(cert);
      });
      await _checkSelection();
      await _saveCurrentList();
    }

    return MyCertsResult(
      certificates: certs,
      invalidCertificatesDeleted: toRemove.length,
    );
  }

  static Future<void> _checkSelection() async {
    int max = _myCerts?.length ?? 0;
    if (_certSelection >= max) {
      _certSelection = max - 1;
      if (_certSelection < 0) _certSelection = 0;

      await setCertSelection(_certSelection);
    }
  }

  static Future<void> _saveCurrentList() async {
    Box box = await HiveProvider.getEncryptedBox(boxName: _hiveBoxName, boxKeyName: _hiveBoxKey);
    await box.put('myCerts', jsonEncode(_myCerts));
    await box.compact();
  }
}