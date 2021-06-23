import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:greenpass_app/consts/vibration.dart';
import 'package:greenpass_app/elements/platform_alert_dialog.dart';
import 'package:greenpass_app/green_validator/green_validator.dart';
import 'package:greenpass_app/green_validator/model/validation_result.dart';
import 'package:greenpass_app/my_certs/my_certs.dart';
import 'package:greenpass_app/views/qr_code_scanner.dart';

class AddMyPassPage extends StatefulWidget {
  const AddMyPassPage({Key? key}) : super(key: key);

  @override
  _AddMyPassPageState createState() => _AddMyPassPageState();
}

class _AddMyPassPageState extends State<AddMyPassPage> {
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    bool stopScanning = false;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Add QR code'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(FontAwesome5Solid.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          QRCodeScanner(callback: (code) async {
            if (!stopScanning) {
              stopScanning = true;

              ValidationResult res = GreenValidator.validate(code);

              if (!res.success) {
                GPVibration.error();
                PlatformAlertDialog.showAlertDialog(
                  context: context,
                  title: 'Invalid QR code'.tr(),
                  text: 'The QR code you scanned is invalid. Please try again.'.tr(),
                  dismissButtonText: 'Ok'.tr()
                ).then((_) => stopScanning = false);
              } else {
                if (MyCerts.getCurrentQrCodes().contains(code)) {
                  GPVibration.error();
                  PlatformAlertDialog.showAlertDialog(
                    context: context,
                    title: 'Already added'.tr(),
                    text: 'You have already added this QR code. Please scan another one.'.tr(),
                    dismissButtonText: 'Ok'.tr()
                  ).then((_) => stopScanning = false);
                } else {
                  await MyCerts.addQrCode(code);
                  GPVibration.success();
                  Navigator.of(context).pop();
                }
              }
            }
          }),
          Container(
            color: Colors.black45,
            alignment: Alignment.topCenter,
            height: MediaQuery.of(this.context).padding.top + kToolbarHeight,
          ),
        ],
      ),
    );
  }
}
