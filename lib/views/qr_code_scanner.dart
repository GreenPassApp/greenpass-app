import 'package:flutter/material.dart';
import 'package:greenpass_app/green_validator/green_validator.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vibration/vibration.dart';

class QRCodeScanner extends StatefulWidget {
  const QRCodeScanner({Key? key}) : super(key: key);

  @override
  _QRCodeScannerState createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  final GlobalKey qrKey = GlobalKey();
  QRViewController? controller;
  Barcode? result;

  @override
  Widget build(BuildContext context) {
    return QRView(
      key: qrKey,
      formatsAllowed: [
        BarcodeFormat.qrcode
      ],
      overlay: QrScannerOverlayShape(
        borderLength: 0,
        borderWidth: 0,
        cutOutSize: MediaQuery.of(context).size.shortestSide - 40
      ),
      onQRViewCreated: (QRViewController c) {
        controller = c;
        c.scannedDataStream.listen((sd) {
          result = sd;
          Vibration.vibrate(pattern: [0, 50]);
          showDialog(
            context: context,
            builder: (context) {
              String code = result!.code;
              return AlertDialog(
                content: Text(GreenValidator.validate(code).certificate!.certificateType.toString()),
              );
            },
          );
        });
      },
    );
  }
}
