import 'package:flutter/material.dart';
import 'package:greenpass_app/views/qr_code_scanner.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:vibration/vibration.dart';

class ScanOthersPassView extends StatefulWidget {
  final BuildContext context;

  const ScanOthersPassView({Key? key, required this.context}) : super(key: key);

  @override
  _ScanOthersPassViewState createState() => _ScanOthersPassViewState(context: this.context);
}

class _ScanOthersPassViewState extends State<ScanOthersPassView> {
  final BuildContext context;

  _ScanOthersPassViewState({required this.context});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        QRCodeScanner(callback: (code) {
          Vibration.vibrate(pattern: [0, 50]);
          showCupertinoModalBottomSheet(
            context: this.context,
            expand: true,
            builder: (context) => Container(child: Text(code.toString())),
          );
        }),
        Container(
          color: Colors.black45,
          alignment: Alignment.topCenter,
          height: MediaQuery.of(this.context).padding.top + kToolbarHeight,
        ),
      ],
    );
  }
}