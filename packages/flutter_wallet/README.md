# flutter_wallet

[![Donate](https://img.shields.io/badge/Donate-PayPal-blue.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=ALF7J4QEVFBNL)
[![pub package](https://img.shields.io/pub/v/flutter_wallet.svg)](https://pub.dartlang.org/packages/flutter_wallet)

Flutter plugin to add pkpass to iOS wallet (Passbook)

## Usage

To use, you must at least specify one arguments **pkpass**.
* The argument **pkpass** is List<int> type.
  
### Example
  
```dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_wallet/flutter_wallet.dart';
import 'package:dio/dio.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> getPass() async {
    String jsonParameters = '{';
    jsonParameters += '"serialNumber" : "123456789",';
    jsonParameters += '"relevantDate" : "2019-07-20T15:30:00-06:00",';
    jsonParameters += '"latitude" : 19.687,';
    jsonParameters += '"longitude" : -101.151,';
    jsonParameters += '"relevantText" : "Wellcome';
    jsonParameters += '"message" : "QQ2475P",';
    jsonParameters += '"date" : "20 Jul.",';
    jsonParameters += '"time" : "03:30 PM",';
    jsonParameters += '"movie" : "Movie Name",';
    jsonParameters += '"cinema" : "Cinema Name",';
    jsonParameters += '"seats" : "A1",';
    jsonParameters += '"room" : "10",';
    jsonParameters += '"poster" : "https://domain.com/images/image.jpg"';
    jsonParameters += '}';

    Response response;
    Dio dio = new Dio();

    response = await dio.post("http://domain.com/getPKPass.php", 
                          data: jsonParameters, 
                          options: Options(responseType: ResponseType.bytes));

    if (response.data != null) {
      try {
        var result = await FlutterWallet.addPass(pkpass: response.data);
        print(result);
      } catch (e) {
        print(e.message);
      }
    } else {
       print("Data error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Passbook example app'),
        ),
        body: Center(
          child: RaisedButton(child: Text("Get Passbook"), onPressed: () {
            getPass();
          },),
        ),
      ),
    );
  }
}
```

## Notes

Don't forget enable Wallet capability in your Xcode project:

![](https://github.com/vico-aguado/flutter_wallet/blob/master/capability.png)

And Wallet service in your application service 
(Certificates, Identifiers & Profiles / Identifiers / App IDs / 'Your app id'):

![](https://github.com/vico-aguado/flutter_wallet/blob/master/appService.png)

## TODO:
* Add Android compatibility.
* Add more documentation.

------------------------------------------------------------------------------

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.io/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.io/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
