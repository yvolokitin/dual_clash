/// App-level audio wiring: bridges Flutter app events to the new
/// AudioCoordinator/Executor without introducing any decision logic.
///
/// Scope: entire app (menu + gameplay), all audio flows only via AudioCoordinator.
/// - BGM channel implemented with just_audio.
/// - SFX player implemented with just_audio.
/// - A WidgetsBindingObserver forwards lifecycle events to the coordinator.
/// - Provides AppAudio.init(controller) for startup wiring and AppAudio.dispose().

import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

import 'audio_intent_resolver.dart';
import 'audio_executor.dart';
import 'audio_coordinator.dart';
import 'game_controller.dart';

class JustAudioBgmChannel implements BgmChannel {
  final AudioPlayer _player = AudioPlayer();
  bool _sessionConfigured = false;
  BgmKind? _currentKind;
  LoopKind _currentLoop = LoopKind.na;

  Future<void> _ensureSession() async {
    if (_sessionConfigured) return;
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    _sessionConfigured = true;
  }

  @override
  Future<void> setLoop(LoopKind loop) async {
    await _ensureSession();
    _currentLoop = loop;
    switch (loop) {
      case LoopKind.one:
        await _player.setLoopMode(LoopMode.one);
        break;
      case LoopKind.sequence:
        await _player.setLoopMode(LoopMode.all); // loop entire playlist
        break;
      case LoopKind.na:
        await _player.setLoopMode(LoopMode.off);
        break;
    }
  }

  AudioSource _menuSource() => AudioSource.asset('assets/m4a/main_page.m4a');

  AudioSource _gameplaySource() => ConcatenatingAudioSource(children: const [
        AudioSource.asset('assets/m4a/game_challange_1.m4a'),
        AudioSource.asset('assets/m4a/game_challange_2.m4a'),
      ]);

  Future<void> _loadFor(BgmKind kind) async {
    await _ensureSession();
    if (kind == BgmKind.menu) {
      await _player.setAudioSource(_menuSource());
      await setLoop(LoopKind.one);
    } else {
      await _player.setAudioSource(_gameplaySource());
      await setLoop(LoopKind.sequence);
    }
    _currentKind = kind;
  }

  @override
  Future<void> play(BgmKind kind) async {
    if (_currentKind != kind || _player.audioSource == null) {
      await _loadFor(kind);
    }
    await _player.seek(Duration.zero);
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
  }

  @override
  Future<void> crossfadeTo(BgmKind kind, {LoopKind? loop}) async {
    if (loop != null) {
      await setLoop(loop);
    }
    await _loadFor(kind);
    await _player.seek(Duration.zero);
    await _player.play();
  }
}

class InMemorySfxBus implements SfxBus {
  SfxPolicy current = SfxPolicy.blocked;
  @override
  Future<void> setPolicy(SfxPolicy policy) async {
    current = policy;
  }
}

class JustAudioSfxPlayer implements SfxPlayer {
  final InMemorySfxBus _policyBus;
  final Map<SfxType, AudioPlayer> _players = <SfxType, AudioPlayer>{};
  final Map<SfxType, bool> _loaded = <SfxType, bool>{};
  bool _sessionConfigured = false;

  JustAudioSfxPlayer(this._policyBus);

  Future<void> _ensureSession() async {
    if (_sessionConfigured) return;
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    _sessionConfigured = true;
  }

  String _assetFor(SfxType type) {
    switch (type) {
      case SfxType.redTurn:
        return 'assets/sfx/red_turn.mp3';
      case SfxType.blueTurn:
        return 'assets/sfx/blue_turn.mp3';
      case SfxType.bombAdd:
        return 'assets/sfx/bomb_add.mp3';
      case SfxType.explosion:
        return 'assets/sfx/explosion.mp3';
      case SfxType.greyShake:
        return 'assets/sfx/grey_shake.mp3';
      case SfxType.transition:
        return 'assets/sfx/transition.mp3';
    }
  }

  @override
  Future<void> play(SfxType type) async {
    if (_policyBus.current == SfxPolicy.blocked) return;
    await _ensureSession();
    final player = _players.putIfAbsent(type, () => AudioPlayer());
    if (!(_loaded[type] ?? false)) {
      await player.setAsset(_assetFor(type));
      _loaded[type] = true;
    }
    await player.seek(Duration.zero);
    await player.play();
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

    final sfxBus = InMemorySfxBus();
    final executor = AudioExecutor(
      bgmChannel: JustAudioBgmChannel(),
      sfxBus: sfxBus,
    );
    final coord = AudioCoordinator(
      executor: executor,
      sfxPlayer: JustAudioSfxPlayer(sfxBus),
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
