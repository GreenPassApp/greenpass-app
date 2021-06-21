import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenpass_app/green_validator/green_validator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ModalValidCert extends StatelessWidget {
  final String cert;

  const ModalValidCert({Key? key, required this.cert}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            leading: Container(), middle: Text('Modal Page')),
        child: SafeArea(
          bottom: false,
          child: Text(GreenValidator.validate(cert)
              .certificate!
              .certificateType
              .toString()
            , ),
        ),
      ),
    );
  }
}