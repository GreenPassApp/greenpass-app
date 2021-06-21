import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
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
            constraints: BoxConstraints.expand(),
            child: Column(
              children: [
                Container(
                  decoration: new BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.30),
                        blurRadius: 20.0, // soften the shadow
                        spreadRadius: -25.0, //extend the shadow
                        offset: Offset(
                          4.0,
                          4.0,
                        ),
                      )
                    ],
                  ),
                  child: Card(
                    color: Color(0xFFBFF5048),
                    margin: EdgeInsets.all(25.0),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Color(0xFFBFF5048), width: 1),
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
                                    padding: EdgeInsets.all(20.0),
                                    child: Container(
                                      margin: EdgeInsets.all(20),
                                      padding: EdgeInsets.all(30),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(150),
                                          border: Border.all(
                                              width: 4, color: Colors.white)),
                                      child: Icon(
                                        FontAwesome5Solid.times,
                                        color: Colors.white,
                                        size: 60.0,
                                      ),
                                    )),
                              ]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.all(00.0),
                                  child: Text(
                                    "Not valid",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold),
                                  ))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text("This QR-Code is not valid.", style: TextStyle(color: Colors.white, fontSize: 15.0),
                                  ))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}