/// App-level audio wiring: bridges Flutter app events to the new
/// AudioCoordinator/Executor without introducing any decision logic.
///
/// Scope: entire app (menu + gameplay), all audio flows only via AudioCoordinator.
/// - BGM channel implemented with just_audio.
/// - SFX player implemented with just_audio.
/// - A WidgetsBindingObserver forwards lifecycle events to the coordinator.
/// - Provides AppAudio.init(controller) for startup wiring and AppAudio.dispose().

import 'package:flutter/widgets.dart';
import 'android_audio_executor.dart';

import 'audio_intent_resolver.dart';
import 'audio_executor.dart';
import 'audio_coordinator.dart';
import 'game_controller.dart';


/// Bridges Flutter app lifecycle to AudioCoordinator as per required mapping.
class _AudioLifecycleBridge with WidgetsBindingObserver {
  final AudioCoordinator _coordinator;
  _AudioLifecycleBridge(this._coordinator);

  void register() {
    WidgetsBinding.instance.addObserver(this);
  }

  void unregister() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _coordinator.onAppLifecycleChanged(AppLifecycle.foreground);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _coordinator.onAppLifecycleChanged(AppLifecycle.background);
        break;
      case AppLifecycleState.hidden:
        // Web/desktop may report hidden; treat as background.
        _coordinator.onAppLifecycleChanged(AppLifecycle.background);
        break;
    }
  }
}

/// Singleton-like access to the app's audio coordinator and wiring.
class AppAudio {
  static AudioCoordinator? _coordinator;
  static _AudioLifecycleBridge? _lifecycle;
  static VoidCallback? _settingsListener;
  static GameController? _controller;

  static AudioCoordinator? get coordinator => _coordinator;

  /// Initialize audio wiring. Safe to call once at app startup.
  static void init(GameController controller) {
    if (_coordinator != null) return; // already initialized

    final sfxBus = AndroidSfxBus();
    final bgm = AndroidBgmChannel();
    final executor = AudioExecutor(
      bgmChannel: bgm,
      sfxBus: sfxBus,
    );
    final coord = AudioCoordinator(
      executor: executor,
      sfxPlayer: AndroidSfxPlayer(sfxBus, bgm),
    );
    _coordinator = coord;

    // Lifecycle observer
    final lf = _AudioLifecycleBridge(coord)..register();
    _lifecycle = lf;

    // Forward current settings immediately and on change
    _controller = controller;
    bool lastMusic = controller.musicEnabled;
    bool lastSfx = controller.soundsEnabled;

    // Apply initial snapshot
    coord.onUserSettingsChanged(musicEnabled: lastMusic, sfxEnabled: lastSfx);

    _settingsListener = () {
      if (_controller == null) return;
      final gc = _controller!;
      if (gc.musicEnabled != lastMusic || gc.soundsEnabled != lastSfx) {
        lastMusic = gc.musicEnabled;
        lastSfx = gc.soundsEnabled;
        coord.onUserSettingsChanged(
          musicEnabled: lastMusic,
          sfxEnabled: lastSfx,
        );
      }
    };
    controller.addListener(_settingsListener!);

    // Ensure executor applies the initial state
    coord.sync();
  }

  static void dispose() {
    _lifecycle?.unregister();
    _lifecycle = null;
    if (_controller != null && _settingsListener != null) {
      _controller!.removeListener(_settingsListener!);
    }
    _settingsListener = null;
    _controller = null;
    _coordinator = null;
  }
}
