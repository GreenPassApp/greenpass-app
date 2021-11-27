import 'package:vibration/vibration.dart';

class GPVibration {
  static void success() {
    Vibration.vibrate(pattern: [0, 50]);
  }

  static void error() {
    Vibration.vibrate(pattern: [0, 40, 80, 40]);
  }

  static void normalAction() {
    Vibration.vibrate(pattern: [0, 20]);
  }
}