import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformAlertDialog {
  static Future showAlertDialog({
    required BuildContext context,
    required String title,
    required String text,
    required String dismissButtonText,
    String? actionButtonText,
    VoidCallback action = _defaultFunc,
  }) {
    Widget dialog;
    if (Platform.isIOS) {
      dialog = CupertinoAlertDialog(
        title: Text(title),
        content: Text(text),
        actions: [
          CupertinoDialogAction(
            child: Text(dismissButtonText),
            onPressed: () => Navigator.of(context).pop(),
          ),
          if (actionButtonText != null) ...[
            CupertinoDialogAction(
              child: Text(actionButtonText),
              onPressed: () {
                Navigator.of(context).pop();
                action();
              },
            )
          ],
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
          ),
          if (actionButtonText != null) ...[
            TextButton(
              child: Text(actionButtonText),
              onPressed: () {
                Navigator.of(context).pop();
                action();
              },
            )
          ],
        ],
      );
    }

    return showDialog(
      context: context,
      builder: (_) => dialog,
    );
  }

  static void _defaultFunc() {}
}