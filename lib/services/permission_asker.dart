import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/widgets.dart';
import 'package:greenpass_app/elements/platform_alert_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionAsker {
  static const String _permissionGrantedCameraKey = 'permission_granted_for_camera';
  static const String _permissionGrantedReadStorageKey = 'permission_granted_for_read_storage';

  static Future<bool> needToAskForCameraPermission() async {
    if (!Platform.isAndroid) return false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await Permission.camera.status != PermissionStatus.granted && !prefs.containsKey(_permissionGrantedCameraKey);
  }

  static Future<bool> needToAskForReadStoragePermission() async {
    if (!Platform.isAndroid) return false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await Permission.storage.status != PermissionStatus.granted && !prefs.containsKey(_permissionGrantedReadStorageKey);
  }

  static Future<bool> grantCameraPermission() async => (await SharedPreferences.getInstance()).setBool(_permissionGrantedCameraKey, true);
  static Future<bool> grantReadStoragePermission() async => (await SharedPreferences.getInstance()).setBool(_permissionGrantedReadStorageKey, true);

  static Future<void> tryUntilCameraPermissionGranted(BuildContext context, VoidCallback callback) async {
    if (await PermissionAsker.needToAskForCameraPermission()) {
      PlatformAlertDialog.showAlertDialog(
        context: context,
        title: 'Permission required'.tr(),
        text: 'Please grant the app permission to access the camera. This is required to add or verify certificates.'.tr() + '\n\n' +
          'All added certificates are stored and processed locally and offline only.'.tr() + ' ' +
          'No data is stored when checking other certificates.'.tr(),
        dismissButtonText: 'Deny'.tr(),
        actionButtonText: 'Allow'.tr(),
        action: () {
          callback();
          grantCameraPermission();
        }
      );
    } else {
      callback();
    }
  }

  static Future<void> tryUntilReadStoragePermissionGranted(BuildContext context, VoidCallback callback) async {
    if (await PermissionAsker.needToAskForReadStoragePermission()) {
      PlatformAlertDialog.showAlertDialog(
          context: context,
          title: 'Permission required'.tr(),
          text: 'Please grant the app permission to read from storage. This is required to add certificates.'.tr() + '\n\n' +
              'All added certificates are stored and processed locally and offline only.'.tr(),
          dismissButtonText: 'Deny'.tr(),
          actionButtonText: 'Allow'.tr(),
          action: () {
            callback();
            grantReadStoragePermission();
          }
      );
    } else {
      callback();
    }
  }
}