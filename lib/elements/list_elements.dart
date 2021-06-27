import 'package:flutter/material.dart';
import 'package:greenpass_app/consts/colors.dart';

class ListElements {
  static Widget horizontalLine({double? height = 25}) {
    return Divider(
      height: height,
      thickness: 1,
    );
  }

  static Widget groupText(String txt) {
    return Text(
      txt,
      style: TextStyle(
        color: GPColors.dark_grey,
      ),
    );
  }

  static Widget entryText(String name, String val) {
    return listPadding(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                color: GPColors.almost_black,
                fontSize: 12.0,
              ),
            ),
            Padding(padding: const EdgeInsets.symmetric(vertical: 1.0)),
            Text(
              val,
              style: TextStyle(
                color: GPColors.almost_black,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
    );
  }

  static Widget listPadding(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4.0),
      child: child,
    );
  }

  static Widget listElement({Widget? icon, required String mainText, String? secondaryText, GestureTapCallback? action, Widget? trailing}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
      leading: icon,
      title: Row(
        children: [
          Flexible(
            child: Text(
              mainText,
              style: TextStyle(
                color: GPColors.almost_black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (secondaryText != null) ...[
            Padding(padding: const EdgeInsets.symmetric(horizontal: 3.0)),
            Text(
              secondaryText,
              style: TextStyle(
                color: GPColors.almost_black,
              ),
            )
          ],
        ],
      ),
      trailing: trailing,
      onTap: action,
    );
  }
}