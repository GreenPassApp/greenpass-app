import 'package:url_launcher/url_launcher.dart';

class AppleWallet {
  static Future<void> pkPassDownload({required String url}) async {
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