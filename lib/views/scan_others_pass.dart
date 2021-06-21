import 'package:flutter/material.dart';
import 'package:greenpass_app/green_validator/green_validator.dart';
import 'package:greenpass_app/green_validator/model/validation_error_code.dart';
import 'package:greenpass_app/views/modal-invalid-cert.dart';
import 'package:greenpass_app/views/qr_code_scanner.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:vibration/vibration.dart';

import 'modal-valid-cert.dart';

class ScanOthersPassView extends StatefulWidget {
  final BuildContext context;

  const ScanOthersPassView({Key? key, required this.context}) : super(key: key);

  @override
  _ScanOthersPassViewState createState() =>
      _ScanOthersPassViewState(context: this.context);
}

class _ScanOthersPassViewState extends State<ScanOthersPassView> {
  final BuildContext context;
  DateTime lastScan = DateTime.now().subtract(Duration(seconds: 10));
  String lastCode = "";

  _ScanOthersPassViewState({required this.context});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        QRCodeScanner(callback: (code) {
          //if (lastScan.isBefore(DateTime.now().subtract(Duration(seconds: 4)))) {
          if (lastCode != code) {
            //lastScan = DateTime.now();
            lastCode = code;
            Vibration.vibrate(pattern: [0, 50]);
            showCupertinoModalBottomSheet(
              context: this.context,
              expand: true,
              builder: (context) => Stack(
                children: <Widget>[
                  validateCert(code),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: MaterialButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Icon(Icons.cancel),
                    ),
                  )
                ],
              ),
            ).then((value) {
              this.lastCode = "";
            });
          }
        }),
        Container(
          color: Colors.black45,
          alignment: Alignment.topCenter,
          height: MediaQuery.of(this.context).padding.top + kToolbarHeight,
        ),
      ],
    );
  }

  validateCert(String code) {
      try {
        var cert = GreenValidator.validate(code);
        if(cert.errorCode != ValidationErrorCode.none){
          return ModalInvalidCert(errorCode: cert.errorCode);
        }
        return ModalValidCert(cert: cert);
      } on Exception catch (e) {
        return ModalInvalidCert(errorCode: ValidationErrorCode.unable_to_parse);
      }
  }
}
