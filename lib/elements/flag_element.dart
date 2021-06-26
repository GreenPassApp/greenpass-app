import 'package:flag/flag.dart';
import 'package:flutter/material.dart';

class FlagElement {
  static const String default_flag = 'EU';

  static Widget buildFlag({required String flag}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(300),
      child: Flag(
        flag,
        fit: BoxFit.cover,
        width: 28.0,
        height: 28.0,
        replacement: Flag(
          default_flag,
          fit: BoxFit.cover,
          width: 28.0,
          height: 28.0,
        ),
      ),
    );
  }
}