import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/ecc/ecc_fp.dart' as ecc_fp;

class CertFetcher {
  static const String _pubCertUrl = 'https://de.dscg.ubirch.com/trustList/DSC/';
  static const String _DscgCertServerPubKey = 'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAETHfi8foQF4UtSNVxSFxeu7W+gMxdSGElhdo7825SD3Lyb+Sqh4G6Kra0ro1BdrM6Qx+hsUx4Qwdby7QY0pzxyA==';

  // method to fetch and parse public certificates online
  static Future<Map<String, String>> fetchPublicCerts() async {
    Response res = await get(Uri.parse(_pubCertUrl));
    String body = res.body;

    int jsonStartIdx = body.indexOf('{');
    String signature = body.substring(0, jsonStartIdx).trim();
    String jsonText = body.substring(jsonStartIdx).trim();

    if (!_validateSignature(signature, jsonText))
      throw ('TrustList Signature is invalid.');

    List<dynamic> certificates = jsonDecode(jsonText)['certificates'];

    Map<String, String> toReturn = Map<String, String>();
    certificates.forEach((c) => toReturn[c['kid']] = c['rawData']);

    return toReturn;
  }

  static bool _validateSignature(String signature, String rawJson) {
    Signer signer = Signer('SHA-256/DET-ECDSA');
    signer.init(false, PublicKeyParameter(_pkcs8ECPublicKey(base64.decode(_DscgCertServerPubKey))));

    Uint8List sigBytes = base64.decode(signature);
    int len = sigBytes.length ~/ 2;

    return signer.verifySignature(Uint8List.fromList(rawJson.codeUnits), ECSignature(
      _bigIntFromBytes(sigBytes.sublist(0, len)),
      _bigIntFromBytes(sigBytes.sublist(len)),
    ));
  }

  static ECPublicKey _pkcs8ECPublicKey(Uint8List bytes) {
    final parser = ASN1Parser(bytes);
    final seq = parser.nextObject() as ASN1Sequence;
    if (seq.elements == null) throw 'Public key could not be parsed.';

    final oidSeq = seq.elements![0] as ASN1Sequence;
    if (oidSeq.elements == null) throw 'Public key could not be parsed.';
    final oid =
        (oidSeq.elements![1] as ASN1ObjectIdentifier).objectIdentifierAsString;
    final curve = const {
      '1.2.840.10045.3.1.7': 'prime256v1',
      '1.3.132.0.10': 'secp256k1',
      '1.3.132.0.34': 'secp384r1',
      '1.3.132.0.35': 'secp521r1',
    }[oid];

    if (curve == null) throw 'Public key could not be parsed.';

    var publicKeyBytes = seq.elements![1].valueBytes;
    if (publicKeyBytes == null) throw 'Public key could not be parsed.';
    if (publicKeyBytes[0] == 0) {
      publicKeyBytes = publicKeyBytes.sublist(1);
    }

    final compressed = publicKeyBytes[0] != 4;
    final x = publicKeyBytes.sublist(1, (publicKeyBytes.length / 2).round());
    final y = publicKeyBytes.sublist(1 + x.length, publicKeyBytes.length);
    final bigX = _decodeBigIntWithSign(1, x);
    final bigY = _decodeBigIntWithSign(1, y);
    final params = ECDomainParameters(curve);

    return ECPublicKey(
      ecc_fp.ECPoint(
        params.curve as ecc_fp.ECCurve,
        params.curve.fromBigInteger(bigX) as ecc_fp.ECFieldElement?,
        params.curve.fromBigInteger(bigY) as ecc_fp.ECFieldElement?,
        compressed,
      ),
      params,
    );
  }

  static BigInt _decodeBigIntWithSign(int sign, List<int> bytes) {
    if (sign == 0) return BigInt.zero;

    BigInt result;

    if (bytes.length == 1) {
      result = BigInt.from(bytes[0]);
    } else {
      result = BigInt.zero;

      for (var i = 0; i < bytes.length; i++) {
        var item = bytes[bytes.length - i - 1];
        result |= (BigInt.from(item) << (8 * i));
      }
    }

    if (result == BigInt.zero) return BigInt.zero;

    return sign < 0
        ? result.toSigned(result.bitLength)
        : result.toUnsigned(result.bitLength);
  }

  static BigInt _bigIntFromBytes(Uint8List bytes) => bytes.fold(BigInt.zero, (a, b) => a * BigInt.from(256) + BigInt.from(b));
}