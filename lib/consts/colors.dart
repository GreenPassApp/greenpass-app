import 'dart:ui';

import 'package:flutter/material.dart';

class GPColors {
  static const Color blue = Color(0xFF135ACF);
  static const Color red = Color(0xFFFF5048);
  static const Color yellow = Color(0xFFFFCF26);
  static const Color green = Color(0xFF50AF64);

  static const Color light_grey = Color(0xFFEDEDED);
  static const Color dark_grey = Color(0xFF8A8A8A);
  static const Color almost_black = Color(0xFF333333);

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }
}