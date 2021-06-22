import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformAlertDialog {
  static Future showAlertDialog({required BuildContext context, required String title, required String text, required String dismissButtonText}) {
    Widget dialog;
    if (Platform.isIOS) {
      dialog = CupertinoAlertDialog(
        title: Text(title),
        content: Text(text),
        actions: [
          CupertinoDialogAction(
            child: Text(dismissButtonText),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      );
    } else {
      dialog = AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: [
          TextButton(
            child: Text(dismissButtonText),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      );
    }

    return showDialog(
      context: context,
      builder: (_) => dialog,
    );
  }
}