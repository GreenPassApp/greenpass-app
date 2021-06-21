import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenpass_app/green_validator/green_validator.dart';
import 'package:greenpass_app/green_validator/model/validation_result.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ModalValidCert extends StatelessWidget {
  final ValidationResult cert;

  const ModalValidCert({Key? key, required this.cert}) : super(key: key);

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
                Card(
                  color: Color(0xFFB135ACF),
                  margin: EdgeInsets.all(25.0),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.white70, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.all(50.0),
                                child: Icon(Icons.add,
                                    color: Colors.white, size: 100.0))
                          ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.all(00.0),
                              child: Text(
                                cert.certificate!.certificateType.toString(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25.0),
                              ))
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.all(00.0),
                              child: Text(
                                  cert.certificate!.issuedAt.toString(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15.0),
                              ))
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Text(
                                DateTime.now().difference(cert.certificate!.issuedAt).inDays.toString() + " Days",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15.0),
                              ))
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  cert.certificate!.certificateType.toString(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
