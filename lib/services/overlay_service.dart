import 'package:flutter/services.dart';

class OverlayService {
  static const MethodChannel _channel = MethodChannel('com.example.floatingimage/overlay');

  static Future<bool> checkOverlayPermission() async {
    try {
      final bool hasPermission = await _channel.invokeMethod('checkOverlayPermission');
      return hasPermission;
    } on PlatformException catch (_) {
      return false;
    }
  }

  static Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } on PlatformException catch (_) {
      // Handle error if needed
    }
  }

  static Future<void> startOverlay(String imagePath, String size, bool lockScreen) async {
    try {
      await _channel.invokeMethod('startOverlay', {
        'imagePath': imagePath,
        'size': size,
        'lockScreen': lockScreen,
      });
    } on PlatformException catch (_) {
      // Handle error if needed
    }
  }

  static Future<void> stopOverlay() async {
    try {
      await _channel.invokeMethod('stopOverlay');
    } on PlatformException catch (_) {
      // Handle error if needed
    }
  }

  static Future<void> updateImage(String imagePath) async {
    try {
      await _channel.invokeMethod('updateImage', {
        'imagePath': imagePath,
      });
    } on PlatformException catch (_) {
      // Handle error if needed
    }
  }

  static Future<void> updateSize(String size) async {
    try {
      await _channel.invokeMethod('updateSize', {
        'size': size,
      });
    } on PlatformException catch (_) {
      // Handle error if needed
    }
  }

  static Future<void> updateLockScreen(bool lockScreen) async {
    try {
      await _channel.invokeMethod('updateLockScreen', {
        'lockScreen': lockScreen,
      });
    } on PlatformException catch (_) {
      // Handle error if needed
    }
  }

  static Future<void> resetPosition() async {
    try {
      await _channel.invokeMethod('resetPosition');
    } on PlatformException catch (_) {
      // Handle error if needed
    }
  }
}
