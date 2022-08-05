import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/elements/platform_alert_dialog.dart';
import 'package:greenpass_app/green_validator/green_validator.dart';
import 'package:greenpass_app/green_validator/model/validation_result.dart';
import 'package:greenpass_app/services/my_certs/my_cert.dart';
import 'package:greenpass_app/services/my_certs/my_certs.dart';
import 'package:greenpass_app/services/permission_asker.dart';
import 'package:greenpass_app/views/add_my_pass_page.dart';
import 'package:path/path.dart';
import 'package:pdfx/pdfx.dart';

class AddQrCode {
  static const String _tmpPdfImgFilename = '/tmpPdfImg.png';

  static const platform = const MethodChannel('eu.greenpassapp.greenpass/mlkit_vision');

  static Future<void> openDialog(BuildContext context) async {
    Completer completer = Completer();
    showDialog(
      context: context,
      builder: (BuildContext c) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28.0, 20.0, 28.0, 16.0),
                child: Text('Add QR code'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Divider(
                height: 0.0,
                color: GPColors.dark_grey,
              ),
            ],
          ),
          titlePadding: const EdgeInsets.all(0.0),
          contentPadding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 34.0),
                      leading: Icon(FontAwesome5Solid.camera, color: GPColors.almost_black),
                      title: Text('Scan with camera'.tr()),
                      onTap: () {
                        Navigator.of(context).pop();
                        PermissionAsker.tryUntilCameraPermissionGranted(context, () {
                          completer.complete(Navigator.push(context, MaterialPageRoute(
                            builder: (context) => AddMyPassPage()
                          )));
                        });
                      },
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 34.0),
                      leading: Icon(FontAwesome5Solid.image, color: GPColors.almost_black),
                      title: Text('Select image'.tr()),
                      onTap: () {
                        Navigator.of(context).pop();
                        PermissionAsker.tryUntilReadImagesPermissionGranted(context, () => _selectImage(context, completer));
                      },
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 34.0),
                      leading: Icon(FontAwesome5Solid.file_pdf, color: GPColors.almost_black),
                      title: Text('Select PDF document'.tr()),
                      onTap: () {
                        Navigator.of(context).pop();
                        PermissionAsker.tryUntilReadStoragePermissionGranted(context, () => _selectPDF(context, completer));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return completer.future;
  }

  static Future<void> _selectImage(BuildContext context, Completer completer) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.isNotEmpty) {
        List<String> barcodes = await _readQrCodes(File(result.files.first.path!));

        if (barcodes.isEmpty) {
          _nothingFoundError(context);
        } else {
          String code = barcodes.first;
          ValidationResult res = GreenValidator.validate(code);

          if (!res.success) {
            _invalidCodeError(context);
          } else {
            if (MyCerts.getCurrentCerts().any((c) => c.qrCode == code)) {
              _alreadyAddedError(context);
            } else {
              completer.complete(MyCerts.addCert(
                MyCert(qrCode: code),
              ));
            }
          }
        }
      }
    } on PlatformException catch (e) {
      if (e.code == 'read_external_storage_denied')
        _permissionError(context);
    }
  }

  static Future<void> _selectPDF(BuildContext context, Completer completer) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null) {
        bool found = false;
        PdfDocument doc = await PdfDocument.openFile(result.files.first.path!);

        doFacts: for (int fact in const [1, 2, 4, 8]) {
          for (int pageNum = 1; pageNum <= doc.pagesCount; pageNum++) {
            PdfPage page = await doc.getPage(pageNum);
            PdfPageImage? pageImage = await page.render(width: page.width * fact, height: page.height * fact, format: PdfPageImageFormat.png, backgroundColor: '#FFFFFF');
            page.close();

            Directory tmpDir = Directory.systemTemp.createTempSync();
            File tmpPdfImg = new File(join(tmpDir.path + _tmpPdfImgFilename));
            await tmpPdfImg.writeAsBytes(pageImage!.bytes);

            List<String> barcodes = await _readQrCodes(tmpPdfImg);
            tmpDir.deleteSync(recursive: true);

            if (barcodes.isNotEmpty) {
              found = true;
              String code = barcodes.first;
              ValidationResult res = GreenValidator.validate(code);

              if (!res.success) {
                _invalidCodeError(context);
              } else {
                if (MyCerts.getCurrentCerts().any((c) => c.qrCode == code)) {
                  _alreadyAddedError(context);
                } else {
                  completer.complete(MyCerts.addCert(
                    MyCert(qrCode: code),
                  ));
                }
              }
              break doFacts;
            }
          }
        }

        if (!found) {
          _nothingFoundError(context);
        }
        doc.close();
      }
    } on PlatformException catch (e) {
      if (e.code == 'read_external_storage_denied')
        _permissionError(context);
    }
  }

  static void _alreadyAddedError(BuildContext context) {
    PlatformAlertDialog.showAlertDialog(
      context: context,
      title: 'Already added'.tr(),
      text: 'You have already added this QR code. Please select another file.'.tr(),
      dismissButtonText: 'Ok'.tr()
    );
  }

  static void _invalidCodeError(BuildContext context) {
    PlatformAlertDialog.showAlertDialog(
      context: context,
      title: 'Invalid QR code'.tr(),
      text: 'The QR code in the selected file is invalid. Please try again.'.tr(),
      dismissButtonText: 'Ok'.tr()
    );
  }

  static void _nothingFoundError(BuildContext context) {
    PlatformAlertDialog.showAlertDialog(
      context: context,
      title: 'Nothing found'.tr(),
      text: 'No QR code was found in the selected file. Please try another one.'.tr(),
      dismissButtonText: 'Ok'.tr()
    );
  }

  static void _permissionError(BuildContext context) {
    PlatformAlertDialog.showAlertDialog(
      context: context,
      title: 'No Permission'.tr(),
      text: 'Please give the app permission to access your files to be able to select one.'.tr(),
      dismissButtonText: 'Cancel'.tr(),
      actionButtonText: 'Go to app settings'.tr(),
      action: () => AppSettings.openAppSettings(),
    );
  }

  static Future<List<String>> _readQrCodes(File file) async {
    List<dynamic> res = await platform.invokeMethod('scanQrCodeInImage', {
      'filename': file.path
    });
    return res.map((e) => e as String).toList();
  }
}