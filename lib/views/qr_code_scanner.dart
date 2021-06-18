import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenpass_app/green_validator/green_validator.dart';
import 'package:vibration/vibration.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

class QRCodeScanner extends StatefulWidget {
  const QRCodeScanner({Key? key}) : super(key: key);

  @override
  _QRCodeScannerState createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  @override
  Widget build(BuildContext context) {
    return QrCamera(
      qrCodeCallback: (code) {
        Vibration.vibrate(pattern: [0, 50]);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(GreenValidator.validate(code!).certificate!.certificateType.toString()),
            );
          },
        );
      },
    );
  }
}
