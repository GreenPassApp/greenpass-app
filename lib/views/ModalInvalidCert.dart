import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenpass_app/green_validator/green_validator.dart';
import 'package:greenpass_app/green_validator/model/validation_error_code.dart';
import 'package:greenpass_app/green_validator/model/validation_result.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ModalInvalidCert extends StatelessWidget {
  final ValidationErrorCode errorCode;

  const ModalInvalidCert({Key? key, required this.errorCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            leading: Container(), middle: Text('Modal Page')),
        child: SafeArea(
          bottom: false,
          child: Text(errorCode.toString()),
        ),
      ),
    );
  }
}