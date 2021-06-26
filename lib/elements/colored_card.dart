import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:greenpass_app/green_validator/model/validation_result.dart';
import 'package:greenpass_app/green_validator/payload/certificate_type.dart';

class ColoredCard {
  static Widget buildCard({
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

  static Widget buildIcon({
    required IconData icon,
    double size = 40.0,
    double circlePadding = 20.0,
    double circleBorder = 4.0,
    Color color = Colors.white,
  }) {
    return Container(
      margin: const EdgeInsets.all(20.0),
      padding: EdgeInsets.all(circlePadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(150),
        border: Border.all(width: circleBorder, color: color),
      ),
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }

  static IconData getValidationIcon(dynamic res) {
    if (res is ValidationResult && !res.success)
      return FontAwesome5Solid.times;

    if (res is ValidationResult)
      res = res.certificate;

    switch (res.certificateType) {
      case CertificateType.vaccination:
        return FontAwesome5Solid.syringe;
      case CertificateType.recovery:
        return FontAwesome5Solid.child;
      case CertificateType.test:
        return FontAwesome5Solid.vial;
      case CertificateType.unknown:
        return FontAwesome5Solid.times;
    }

    return FontAwesome5Solid.question;
  }
}