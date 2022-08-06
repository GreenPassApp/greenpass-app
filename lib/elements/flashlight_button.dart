import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:qr_mobile_vision/qr_mobile_vision.dart';

class FlashlightButton extends StatefulWidget {
  const FlashlightButton({Key? key}) : super(key: key);

  @override
  State<FlashlightButton> createState() => _FlashlightButtonState();
}

class _FlashlightButtonState extends State<FlashlightButton> {
  bool _flashlight = false;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Icon(_flashlight ? MaterialCommunityIcons.flashlight_off : MaterialCommunityIcons.flashlight),
      onPressed: () {
        QrMobileVision.toggleFlash();
        _toggleLocalVariable();
      },
    );
  }

  void _toggleLocalVariable () {
    setState(() {
      _flashlight = !_flashlight;
    });
  }
}
