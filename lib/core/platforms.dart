import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

bool get isWeb => kIsWeb;
bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
bool get isMobile => isAndroid || isIOS;
bool get isWindows => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
bool get isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
bool get isLinux => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
bool get isDesktop => isWindows || isMacOS || isLinux;
// Alias to avoid name shadowing in some files
bool get isMobilePlatform => isMobile;