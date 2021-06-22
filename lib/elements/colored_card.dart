import 'package:flutter/material.dart';

class ColoredCard {
  static Widget build({
    required Color backgroundColor,
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Padding(
      padding: padding == null ? const EdgeInsets.all(0) : padding,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15.0,
              spreadRadius: -10.0,
              offset: Offset(0.0, 3.0),
            ),
          ],
        ),
        child: Card(
          color: backgroundColor,
          margin: const EdgeInsets.all(5.0),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: backgroundColor, width: 1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: child
        ),
      ),
    );
  }
}