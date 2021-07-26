import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenpass_app/consts/colors.dart';

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28.0, 20.0, 28.0, 16.0),
              child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Divider(
              height: 0.0,
              color: GPColors.dark_grey,
            ),
          ],
        ),
        titlePadding: const EdgeInsets.all(0.0),
        contentPadding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 18.0),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        content: Text(text),
        actions: [
          TextButton(
            child: Text(
              dismissButtonText,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: actionButtonText == null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          if (actionButtonText != null) ...[
            TextButton(
              child: Text(
                actionButtonText,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
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