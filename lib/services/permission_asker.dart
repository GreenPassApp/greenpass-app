import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/widgets.dart';
import 'package:greenpass_app/elements/platform_alert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionAsker {
  static const String _permissionGrantedCameraKey = 'permission_granted_for_camera';
  static const String _permissionGrantedReadStorageKey = 'permission_granted_for_read_storage';
  static const String _permissionGrantedReadImagesKey = 'permission_granted_for_read_images';

  static Future<bool> needToAskForCameraPermission() => _checkIfPermissionNeeded(_permissionGrantedCameraKey);
  static Future<bool> needToAskForReadStoragePermission() => _checkIfPermissionNeeded(_permissionGrantedReadStorageKey);
  static Future<bool> needToAskForReadImagesPermission() => _checkIfPermissionNeeded(_permissionGrantedReadImagesKey);

  static Future<bool> grantCameraPermission() async => (await SharedPreferences.getInstance()).setBool(_permissionGrantedCameraKey, true);
  static Future<bool> grantReadStoragePermission() async => (await SharedPreferences.getInstance()).setBool(_permissionGrantedReadStorageKey, true);
  static Future<bool> grantReadImagesPermission() async => (await SharedPreferences.getInstance()).setBool(_permissionGrantedReadImagesKey, true);

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

  static Future<void> tryUntilReadImagesPermissionGranted(BuildContext context, VoidCallback callback) async {
    if (await PermissionAsker.needToAskForReadImagesPermission()) {
      PlatformAlertDialog.showAlertDialog(
          context: context,
          title: 'Permission required'.tr(),
          text: 'Please grant the app permission to access your images. This is required to add certificates.'.tr() + '\n\n' +
              'All added certificates are stored and processed locally and offline only.'.tr(),
          dismissButtonText: 'Deny'.tr(),
          actionButtonText: 'Allow'.tr(),
          action: () {
            callback();
            grantReadImagesPermission();
          }
      );
    } else {
      callback();
    }
  }

  static Future<bool> _checkIfPermissionNeeded(String key) async {
    if (!Platform.isAndroid) return false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey(key) || prefs.get(key) != true;
  }
}