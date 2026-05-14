import 'package:flutter/foundation.dart';

abstract final class PlatformCapabilities {
  static bool get isWeb => kIsWeb;

  static bool get isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isMacOS =>
      defaultTargetPlatform == TargetPlatform.macOS;

  static bool get isDesktop =>
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  static bool get supportsQrScanning =>
      !kIsWeb && isMobile;
}