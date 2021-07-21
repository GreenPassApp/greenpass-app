import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_wallet/flutter_wallet.dart';
import 'package:greenpass_app/consts/private.dart';

class AppleWallet {
  static const String _appleWalletApiUri = 'http://localhost:8080/user/pass'; // TODO: change

  // Method to request and add an Apple Wallet Pass
  static Future<void> getAppleWalletPass({required String rawCert, required String serialNumber}) async {
    Response res = await Dio().get(
      _appleWalletApiUri,
      options: Options(
        headers: {
          'Authorization': Private.greenpassApiKey,
          'X-Digital-Certificate': rawCert,
          'X-Serial-Number': sha256.convert(serialNumber.codeUnits).toString(),
        },
        responseType: ResponseType.bytes,
      ),
    );

    await FlutterWallet.addPass(pkpass: res.data);
  }
}