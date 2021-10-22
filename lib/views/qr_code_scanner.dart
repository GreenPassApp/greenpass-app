import 'package:app_settings/app_settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/services/country_regulations/regulations_provider.dart';
import 'package:greenpass_app/views/rule_selection_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:qr_mobile_vision/qr_mobile_vision.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

class QRCodeScanner extends StatefulWidget {
  final void Function(String code) callback;
  final bool showRuleSelection;

  const QRCodeScanner({Key? key, required this.callback, this.showRuleSelection = false}) : super(key: key);

  @override
  _QRCodeScannerState createState() => _QRCodeScannerState(callback: this.callback, showRuleSelection: this.showRuleSelection);
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  final void Function(String code) callback;
  final bool showRuleSelection;

  bool currentlySelectingRule = false;

  _QRCodeScannerState({required this.callback, required this.showRuleSelection});

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
                  Text(
                    'No Permission'.tr(),
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Padding(padding: const EdgeInsets.symmetric(vertical: 6.0)),
                  Text(
                    'Please allow GreenPass to access your camera in order to scan QR codes.'.tr(),
                    textAlign: TextAlign.center,
                  ),
                  const Padding(padding: const EdgeInsets.symmetric(vertical: 12.0)),
                  OutlinedButton(
                    child: Text('Go to app settings'.tr()),
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
                "We're sorry, but there seems to be a problem to access your camera.".tr(),
                textAlign: TextAlign.center,
              ),
            )
          );
        }
      },
      notStartedBuilder: (context) => Container(color: Theme.of(context).scaffoldBackgroundColor),
      qrCodeCallback: (code) {
        if (!currentlySelectingRule)
          this.callback(code!);
      },
      child: SafeArea(
        child: Column(
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                    child: Text(
                      'Hold your camera in front of the QR code.'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              color: Colors.black45,
              width: double.infinity,
            ),
            Expanded(child: Container()),
            if (showRuleSelection && RegulationsProvider.useColorValidation()) ...[
              Container(
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () {
                    currentlySelectingRule = true;
                    showCupertinoModalBottomSheet(
                      context: context,
                      builder: (context) => RuleSelectionModal(),
                    ).then((value) => setState(() { currentlySelectingRule = false; }));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 22.0, horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Purpose of use'.tr(),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12.0,
                              ),
                            ),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 1.0)),
                            Text(
                              RegulationsProvider.getRuleTranslation(RegulationsProvider.getUserSelection().rule, context.locale).toUpperCase(),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Expanded(child: Container()),
                        Icon(
                          FontAwesome5Solid.angle_up,
                          color: Colors.black,
                          size: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ],
          ],
        ),
      ),
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
