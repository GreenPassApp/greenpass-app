import 'dart:convert';
import 'package:greenpass_app/services/update_check/android_update_check_result.dart';
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';

class UpdateCheck {
  static const String _currentVersionUrl = 'https://raw.githubusercontent.com/GreenPassApp/shared-data/main/current-app-version.json';

  static late final Future<AndroidUpdateCheckResult?> updateCheck;

  static void initAppStart() {
    updateCheck = _fetchCurrentVersion();
  }

  static Future<AndroidUpdateCheckResult?> _fetchCurrentVersion() async {
    try {
      Response res = await get(Uri.parse(_currentVersionUrl));
      Map<String, dynamic> parsedJson = jsonDecode(res.body);
      Map<String, dynamic> androidVerInfo = parsedJson['android'];

      return AndroidUpdateCheckResult(
        installedVersion: await _getVersionCode(),
        newestVersion: androidVerInfo['version'],
        updatedAt: DateTime.parse(androidVerInfo['updated_at']),
        downloadUrl: androidVerInfo['download']['url'],
        sha256Checksum: androidVerInfo['download']['sha256'],
        changelog: androidVerInfo.containsKey('changelog') ? androidVerInfo['changelog'] : null,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<String> _getVersionCode() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}