import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:greenpass_app/consts/colors.dart';
import 'package:greenpass_app/elements/platform_alert_dialog.dart';
import 'package:greenpass_app/green_validator/green_validator.dart';
import 'package:greenpass_app/green_validator/model/validation_result.dart';
import 'package:greenpass_app/local_storage/my_certs/my_cert.dart';
import 'package:greenpass_app/local_storage/my_certs/my_certs.dart';
import 'package:greenpass_app/views/add_my_pass_page.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:path/path.dart';

class AddQrCode {
  static const String _tmpPdfImgFilename = '/tmpPdfImg.png';

  static Future<void> openDialog(BuildContext context) {
    Completer completer = Completer();
    showDialog(
      context: context,
      builder: (BuildContext c) {
        return AlertDialog(
          title: Text('Add QR code'.tr()),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(FontAwesome5Solid.camera, color: GPColors.almost_black),
                      title: Text('Scan with camera'.tr()),
                      onTap: () {
                        Navigator.of(context).pop();
                        completer.complete(Navigator.push(context, MaterialPageRoute(
                          builder: (context) => AddMyPassPage()
                        )));
                      },
                    ),
                    ListTile(
                      leading: Icon(FontAwesome5Solid.image, color: GPColors.almost_black),
                      title: Text('Select image'.tr()),
                      onTap: () {
                        Navigator.of(context).pop();
                        _selectImage(context, completer);
                      },
                    ),
                    ListTile(
                      leading: Icon(FontAwesome5Solid.file_pdf, color: GPColors.almost_black),
                      title: Text('Select PDF document'.tr()),
                      onTap: () {
                        Navigator.of(context).pop();
                        _selectPDF(context, completer);
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
      if (result != null) {
        InputImage image = InputImage.fromFilePath(result.files.first.path!);
        BarcodeScanner scanner = GoogleMlKit.vision.barcodeScanner();
        List<Barcode> barcodes = await scanner.processImage(image);

        if (barcodes.isEmpty) {
          PlatformAlertDialog.showAlertDialog(
            context: context,
            title: 'Nothing found'.tr(),
            text: 'No QR code was found in the selected file. Please try another one.'.tr(),
            dismissButtonText: 'Ok'.tr()
          );
        } else {
          String code = barcodes.first.value.rawValue!;
          ValidationResult res = GreenValidator.validate(code);

          if (!res.success) {
            PlatformAlertDialog.showAlertDialog(
              context: context,
              title: 'Invalid QR code'.tr(),
              text: 'The QR code in the selected file is invalid. Please try again.'.tr(),
              dismissButtonText: 'Ok'.tr()
            );
          } else {
            if (MyCerts.getCurrentCerts().any((c) => c.qrCode == code)) {
              PlatformAlertDialog.showAlertDialog(
                context: context,
                title: 'Already added'.tr(),
                text: 'You have already added this QR code. Please select another file.'.tr(),
                dismissButtonText: 'Ok'.tr()
              );
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

        for (int pageNum = 1; pageNum <= doc.pagesCount; pageNum++) {
          PdfPage page = await doc.getPage(pageNum);
          PdfPageImage? pageImage = await page.render(width: page.width, height: page.height, format: PdfPageFormat.PNG);
          page.close();

          Directory tmpDir = Directory.systemTemp.createTempSync();
          File tmpPdfImg = new File(join(tmpDir.path + _tmpPdfImgFilename));
          await tmpPdfImg.writeAsBytes(pageImage!.bytes);

          BarcodeScanner scanner = GoogleMlKit.vision.barcodeScanner();
          List<Barcode> barcodes = await scanner.processImage(InputImage.fromFile(tmpPdfImg));
          tmpDir.deleteSync(recursive: true);

          if (barcodes.isNotEmpty) {
            found = true;
            String code = barcodes.first.value.rawValue!;
            ValidationResult res = GreenValidator.validate(code);

            if (!res.success) {
              PlatformAlertDialog.showAlertDialog(
                context: context,
                title: 'Invalid QR code'.tr(),
                text: 'The QR code in the selected file is invalid. Please try again.'.tr(),
                dismissButtonText: 'Ok'.tr()
              );
            } else {
              if (MyCerts.getCurrentCerts().any((c) => c.qrCode == code)) {
                PlatformAlertDialog.showAlertDialog(
                  context: context,
                  title: 'Already added'.tr(),
                  text: 'You have already added this QR code. Please select another file.'.tr(),
                  dismissButtonText: 'Ok'.tr()
                );
              } else {
                completer.complete(MyCerts.addCert(
                  MyCert(qrCode: code),
                ));
              }
            }
            break;
          }
        }

        if (!found) {
          PlatformAlertDialog.showAlertDialog(
            context: context,
            title: 'Nothing found'.tr(),
            text: 'No QR code was found in the selected file. Please try another one.'.tr(),
            dismissButtonText: 'Ok'.tr()
          );
        }
        doc.close();
      }
    } on PlatformException catch (e) {
      if (e.code == 'read_external_storage_denied')
        _permissionError(context);
    }
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
}