import 'dart:convert';
import 'dart:io';

import 'package:greenpass_app/connectivity/share_certificate_result.dart';
import 'package:http/http.dart' as http;

class ShareCertificate {
  static const String shareLinkPrefix = 'https://greenpassapp.eu/s/';

  static const String _insertUri = 'https://api.greenpassapp.eu/user/insert';
  static const String _updateUri = 'https://api.greenpassapp.eu/user/update';
  static const String _deleteUri = 'https://api.greenpassapp.eu/user/delete';

  static Future<ShareCertificateResult?> insert(String qrCode, DateTime validUntil) async {
    try {
      http.Response res = await http.post(Uri.parse(_insertUri).replace(queryParameters: {
        'validUntil': validUntil.toIso8601String()
      }), body: jsonEncode({
        'data': qrCode
      }), headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      });
      if (res.statusCode != HttpStatus.ok) return null;
      Map<String, dynamic> json = jsonDecode(res.body);

      return ShareCertificateResult(jwt: json['token'], url: json['link']);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> update(String qrCode, DateTime validUntil, String jwt) async {
    try {
      http.Response res = await http.post(Uri.parse(_updateUri).replace(queryParameters: {
        'validUntil': validUntil.toIso8601String()
      }), body: jsonEncode({
        'data': qrCode
      }), headers: {
        'Authorization': 'Bearer ' + jwt,
        'Content-type' : 'application/json',
        'Accept': 'application/json',
      });
      return (res.statusCode == HttpStatus.noContent);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> delete(String jwt) async {
    try {
      http.Response res = await http.delete(Uri.parse(_deleteUri), headers: {
        'Authorization': 'Bearer ' + jwt,
      });
      return (res.statusCode == HttpStatus.noContent);
    } catch (_) {
      return false;
    }
  }
}