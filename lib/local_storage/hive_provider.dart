import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class HiveProvider {
  static Future<Box> getEncryptedBox({required String boxName, required String boxKeyName}) async {
    String? key = await FlutterSecureStorage().read(key: boxKeyName);

    if (key == null)
      await Hive.deleteBoxFromDisk(boxName); // delete box if exists

    if (!(await Hive.boxExists(boxName)))
      key = null; // generate new key if no box exists

    List<int> seq;
    if (key == null) {
      seq = Hive.generateSecureKey();
      await FlutterSecureStorage().write(key: boxKeyName, value: base64UrlEncode(seq));
    } else {
      seq = base64Url.decode(key);
    }

    return await Hive.openBox(boxName, encryptionCipher: HiveAesCipher(seq));
  }
}