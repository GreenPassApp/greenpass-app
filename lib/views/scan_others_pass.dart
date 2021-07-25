import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:greenpass_app/green_validator/green_validator.dart';
import 'package:greenpass_app/services/outdated_check.dart';
import 'package:greenpass_app/views/qr_code_scanner.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'modal_cert.dart';

class ScanOthersPassView extends StatefulWidget {
  final BuildContext context;

  const ScanOthersPassView({Key? key, required this.context}) : super(key: key);

  @override
  _ScanOthersPassViewState createState() =>
      _ScanOthersPassViewState(context: this.context);
}

class _ScanOthersPassViewState extends State<ScanOthersPassView> {
  final BuildContext context;
  List<String> lastCodes = [];

  _ScanOthersPassViewState({required this.context});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (OutdatedCheck.isOutdated) ...[
          SafeArea(
            minimum: const EdgeInsets.all(25.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Outdated app version'.tr(),
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Padding(padding: const EdgeInsets.symmetric(vertical: 6.0)),
                  Text(
                    "Your app version is outdated, so certificate checking and color validation have been disabled. To re-enable these features, you need to update the app.".tr(),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          QRCodeScanner(callback: (code) {
            if (!lastCodes.contains(code)) {
              lastCodes.add(code);
              showCupertinoModalBottomSheet(
                context: this.context,
                expand: true,
                builder: (context) => ModalCert(cert: GreenValidator.validate(code)),
              ).then((value) {
                lastCodes.remove(code);
              });
            }
          }),
        ],
        Container(
          color: Colors.black45,
          alignment: Alignment.topCenter,
          height: MediaQuery.of(this.context).padding.top + kToolbarHeight,
        ),
      ],
    );
  }
}
