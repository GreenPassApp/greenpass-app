import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greenpass_app/pub_certs/cert_fetcher.dart';

class PubCerts {
  static const Duration pubCertsOutdatedAfter = Duration(days: 1);
  static const String bundledPubCertsLocation = 'assets/pubCerts.json';

  static Map<String, String>? _currentPubCerts;

  static Future<void> initAppStart() async {
    if (await FlutterSecureStorage().read(key: 'pubCertsJson') == null) {
      ByteData bundledJson = await rootBundle.load(bundledPubCertsLocation);
      String jsonString = utf8.decode(bundledJson.buffer.asUint8List(bundledJson.offsetInBytes, bundledJson.lengthInBytes));

      await FlutterSecureStorage().write(key: 'pubCertsJson', value: jsonString);
      await FlutterSecureStorage().write(key: 'pubCertsJsonLastUpdate', value: DateTime.fromMicrosecondsSinceEpoch(0).toIso8601String());
      await FlutterSecureStorage().write(key: 'pubCertsJsonVer', value: '1'); // in case something changes
    }

    _currentPubCerts = (jsonDecode((await FlutterSecureStorage().read(key: 'pubCertsJson'))!) as Map)
      .map((key, value) => MapEntry(key, value.toString()));

    // can happen in the background, no need for async
    tryUpdateIfOutdated();
  }

  static Future<void> tryUpdateIfOutdated() async {
    String? lastUpdateStr = await FlutterSecureStorage().read(key: 'pubCertsJsonLastUpdate');
    if (lastUpdateStr == null
        || DateTime.parse(lastUpdateStr).isBefore(DateTime.now().subtract(pubCertsOutdatedAfter))) {
      try {
        Map<String, String> fetchedCerts = await CertFetcher.fetchPublicCerts();
        _currentPubCerts = fetchedCerts;
        await FlutterSecureStorage().write(key: 'pubCertsJson', value: jsonEncode(fetchedCerts));
        await FlutterSecureStorage().write(key: 'pubCertsJsonLastUpdate', value: DateTime.now().toIso8601String());
      } catch (e) {
        // do nothing
      }
    }
  }

  static Map<String, String> getCurrentCerts() {
    return _currentPubCerts!;
  }
}