import 'package:flutter/services.dart';

class AppHaptics {
  static Future<void> success() => HapticFeedback.mediumImpact();
  static Future<void> error()   => HapticFeedback.heavyImpact();
  static Future<void> light()   => HapticFeedback.lightImpact();
  static Future<void> select()  => HapticFeedback.selectionClick();
}
