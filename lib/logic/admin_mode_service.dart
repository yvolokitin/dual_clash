import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminModeService {
  AdminModeService._() {
    _load();
  }

  static final AdminModeService instance = AdminModeService._();
  static const String _prefsKey = 'admin_mode_enabled';
  final ValueNotifier<bool> _enabled = ValueNotifier<bool>(false);

  static ValueListenable<bool> get adminEnabledListenable =>
      instance._enabled;

  static bool get isAdminEnabled => instance._isEnabled;

  bool get _isEnabled => !kIsWeb && _enabled.value;

  bool get canEnableOnThisDevice => !kIsWeb;

  bool canShowMenuItem({required bool requiresAdmin}) {
    if (!requiresAdmin) return true;
    return _isEnabled;
  }

  static Future<void> enableAdminOnThisDevice() async {
    await instance._enableAdminOnThisDevice();
  }

  Future<void> _enableAdminOnThisDevice() async {
    if (kIsWeb) return;
    _enabled.value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
  }

  Future<void> _load() async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_prefsKey) ?? false;
    _enabled.value = enabled;
  }
}
