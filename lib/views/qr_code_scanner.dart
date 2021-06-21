import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenpass_app/green_validator/green_validator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:qr_mobile_vision/qr_mobile_vision.dart';
import 'package:vibration/vibration.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

class QRCodeScanner extends StatefulWidget {
  final void Function(String code) callback;

  const QRCodeScanner({Key? key, required this.callback}) : super(key: key);

  @override
  _QRCodeScannerState createState() => _QRCodeScannerState(callback: this.callback);
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  final void Function(String code) callback;

  _QRCodeScannerState({required this.callback});

  @override
  Widget build(BuildContext context) {
    return QrCamera(
      formats: [
        BarcodeFormats.QR_CODE
      ],
      onError: (context, err) {
        if (_isNoPermissionError(err as PlatformException)) {
          return SafeArea(
            minimum: const EdgeInsets.all(25.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam_off,
                    color: Theme.of(context).disabledColor,
                    size: 60.0
                  ),
                  const Padding(padding: const EdgeInsets.symmetric(vertical: 6.0)),
                  Text(
                    'No Permission',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Padding(padding: const EdgeInsets.symmetric(vertical: 2.0)),
                  Text(
                    'Please allow GreenPass to access your camera in order to scan QR codes.',
                    textAlign: TextAlign.center,
                  ),
                  const Padding(padding: const EdgeInsets.symmetric(vertical: 6.0)),
                  OutlinedButton(
                    child: Text('Go to app settings'),
                    onPressed: () => AppSettings.openAppSettings(),
                  ),
                ],
              ),
            ),
          );
        } else {
          return SafeArea(
            minimum: const EdgeInsets.all(25.0),
            child: Center(
              child: Text(
                "We're sorry, but there seems to be a problem to access your camera.",
                textAlign: TextAlign.center,
              ),
            )
          );
        }
      },
      notStartedBuilder: (context) => Container(color: Theme.of(context).scaffoldBackgroundColor),
      qrCodeCallback: (code) {
        this.callback(code!);
      },
    );
  }

  // helper method since the package only returns platform-specific exceptions
  bool _isNoPermissionError(PlatformException ex) {
    if (ex.code == 'PERMISSION_DENIED') return true; // iOS
    else if (ex.code == 'QRREADER_ERROR') {
      if (ex.message == 'noPermission' || ex.message == 'noPermissions') return true; // Android
    }
    return false; // unknown error
  }
}
