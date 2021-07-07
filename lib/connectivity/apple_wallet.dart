import 'package:url_launcher/url_launcher.dart';

class AppleWallet {

  // TODO refactor
  // Method to open a download url of an Apple Wallet Pass in the browser
  static Future<void> getAppleWalletPass({required String rawCert, required String serialNumber}) async {
    await _pkPassDownload(url: 'https://api.greenpassapp.eu/user/pass?'
      + 'cert=' + Uri.encodeQueryComponent(rawCert)
      + '&serialNumber=' + Uri.encodeQueryComponent(serialNumber));
  }

  static Future<void> _pkPassDownload({required String url}) async {
    assert(url.isNotEmpty);
    if (await canLaunch(url)) {
      try{
        await launch(url);
      } on Exception catch (_) {
        print('Launch problem');
      }
    } else {
      throw 'Could not launch Apple Wallet url';
    }
  }
}