/// App-level audio wiring: bridges Flutter app events and legacy controllers
/// to the new AudioCoordinator/Executor without introducing new decision logic.
///
/// Scope (menu only):
/// - BGM channel controls only the MainMenuMusicController.
/// - SFX bus is a no-op in this step.
/// - A WidgetsBindingObserver forwards lifecycle events to the coordinator.
/// - Provides AppAudio.init(controller) for startup wiring and AppAudio.dispose().

import 'package:flutter/widgets.dart';

import 'audio_intent_resolver.dart';
import 'audio_executor.dart';
import 'audio_coordinator.dart';
import 'game_controller.dart';
import 'main_menu_music_controller.dart';

/// BGM channel implementation that only manages the main menu music
/// via the legacy MainMenuMusicController. No gameplay handling here.
class MenuOnlyBgmChannel implements BgmChannel {
  LoopKind _loop = LoopKind.one; // menu uses single-track loop

  @override
  Future<void> setLoop(LoopKind loop) async {
    // Main menu track is always looped one; store for completeness.
    _loop = loop;
  }

  @override
  Future<void> play(BgmKind kind) async {
    if (kind == BgmKind.menu) {
      // Let the legacy controller manage actual loading/looping.
      // We do not flip user settings here; visibility gate is sufficient.
      await MainMenuMusicController.instance.setMainMenuVisible(true);
      // LoopKind is implicit in the legacy controller (LoopMode.one).
    } else {
      // Non-menu kinds are out of scope for this step.
    }
  }

  @override
  Future<void> pause() async {
    await MainMenuMusicController.instance.setMainMenuVisible(false);
  }

  @override
  Future<void> stop() async {
    await pause();
  }

  @override
  Future<void> crossfadeTo(BgmKind kind, {LoopKind? loop}) async {
    // Minimal implementation: just ensure the target program is playing.
    if (loop != null) {
      await setLoop(loop);
    }
    await play(kind);
  }
}

/// SFX policy bus: no-op for this step (menu-only wiring).
class NoopSfxBus implements SfxBus {
  @override
  Future<void> setPolicy(SfxPolicy policy) async {
    // No-op in this step.
  }
}

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

    final executor = AudioExecutor(
      bgmChannel: MenuOnlyBgmChannel(),
      sfxBus: NoopSfxBus(),
    );
    final coord = AudioCoordinator(executor: executor);
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
