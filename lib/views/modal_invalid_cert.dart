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
          child: Container(
            child: Card(
              color: Color(0xFFB135ACF),
              margin: EdgeInsets.all(25.0),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white70, width: 1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.all(50.0),
                              child: Icon(Icons.not_interested,
                                  color: Colors.white, size: 100.0))
                        ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.all(00.0),
                            child: Text(
                              ("Not Valid"),
                              style: TextStyle(
                                  color: Colors.white, fontSize: 22.0),
                            ))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.all(00.0),
                            child: Text(
                              ("Lorem Ipsum"),
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15.0),
                            ))
                      ],
                    )
                  ],
                ),
              ),
            ),
            constraints: BoxConstraints.expand(),
          ),
        ),
      ),
    );
  }
}