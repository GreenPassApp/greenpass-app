import 'dart:convert';
import 'package:http/http.dart';

class CertFetcher {
  static const String _pubCertUrl = 'https://de.dscg.ubirch.com/trustList/DSC/';
  static const String _DscgCertServerPubKey = 'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAETHfi8foQF4UtSNVxSFxeu7W+gMxdSGElhdo7825SD3Lyb+Sqh4G6Kra0ro1BdrM6Qx+hsUx4Qwdby7QY0pzxyA==';

  // method to fetch and parse public certificates online
  static Future<Map<String, String>> fetchPublicCerts() async {
    Response res = await get(Uri.parse(_pubCertUrl));
    String body = res.body;

    int jsonStartIdx = body.indexOf('{');
    String signature = body.substring(0, jsonStartIdx);
    String jsonText = body.substring(jsonStartIdx);

    if (!_validateSignature(jsonText, _DscgCertServerPubKey))
      throw ('TrustList Signature is invalid.');

    List<dynamic> certificates = jsonDecode(jsonText)['certificates'];

    Map<String, String> toReturn = Map<String, String>();
    certificates.forEach((c) => toReturn[c['kid']] = c['rawData']);

    return toReturn;
  }

  static bool _validateSignature(String rawJson, String signature) {
    // TODO check signature
    return true;
  }
}