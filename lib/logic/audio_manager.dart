import 'dart:async';
import 'dart:math' as math;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';

enum AudioScene {
  appStart,
  menu,
  gameplay,
  paused,
  gameOver,
}

enum AudioSfx {
  transition,
  redTurn,
  blueTurn,
  bombAdd,
  explosion,
  greyShake,
}

class AudioManager {
  AudioManager._() {
    _bgmStateSub = _bgmPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _queueSync(_handleBgmCompletion);
      }
    });
  }

  static final AudioManager instance = AudioManager._();

  static const Duration _fadeInDuration = Duration(milliseconds: 600);
  static const Duration _fadeOutDuration = Duration(milliseconds: 450);
  static const double _bgmTargetVolume = 1.0;

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final math.Random _rng = math.Random();
  final List<String> _gameplayTracks = const [
    'assets/m4a/game_challange_1.m4a',
    'assets/m4a/game_challange_2.m4a',
  ];

  StreamSubscription<PlayerState>? _bgmStateSub;
  Future<void> _syncQueue = Future.value();
  bool _sessionConfigured = false;
  AudioSession? _audioSession;
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  bool _isForeground = true;
  AudioScene _scene = AudioScene.appStart;
  String? _currentBgmAsset;
  String? _resumeAsset;
  Duration? _resumePosition;

  void setSettings({required bool musicEnabled, required bool sfxEnabled}) {
    _musicEnabled = musicEnabled;
    _sfxEnabled = sfxEnabled;
    _queueSync(_applyState);
  }

  void setScene(AudioScene scene) {
    if (_scene == scene) return;
    _scene = scene;
    _queueSync(_applyState);
  }

  void handleAppLifecycleState(AppLifecycleState state) {
    final bool isForeground = state == AppLifecycleState.resumed;
    if (_isForeground == isForeground) return;
    _isForeground = isForeground;
    _queueSync(_applyState);
  }

  Future<void> playSfx(AudioSfx type) async {
    if (!_sfxEnabled) return;
    await _ensureAudioSession();
    final asset = _sfxAsset(type);
    if (asset == null) return;
    try {
      if (_sfxPlayer.playing) {
        await _sfxPlayer.stop();
      }
      await _sfxPlayer.setAsset(asset);
      await _sfxPlayer.seek(Duration.zero);
      await _sfxPlayer.play();
    } catch (_) {
      // Fail silently for missing/unavailable assets.
    }
  }

  void _queueSync(Future<void> Function() task) {
    _syncQueue = _syncQueue.then((_) => task());
  }

  Future<void> _applyState() async {
    if (!_musicEnabled) {
      await _stopBgm();
      return;
    }
    if (!_isForeground) {
      await _pauseBgm(savePosition: true);
      return;
    }
    switch (_scene) {
      case AudioScene.appStart:
        await _stopBgm();
        break;
      case AudioScene.menu:
        await _playMenuBgm();
        break;
      case AudioScene.gameplay:
      case AudioScene.gameOver:
        await _playGameplayBgm();
        break;
      case AudioScene.paused:
        await _pauseBgm(savePosition: true);
        break;
    }
  }

  Future<void> _playMenuBgm() async {
    await _ensureAudioSession();
    const asset = 'assets/m4a/main_page.m4a';
    await _playBgm(asset, loop: true);
  }

  Future<void> _playGameplayBgm() async {
    await _ensureAudioSession();
    final asset = _currentGameplayAsset();
    await _playBgm(asset, loop: false);
  }

  String _currentGameplayAsset() {
    if (_currentBgmAsset != null && _gameplayTracks.contains(_currentBgmAsset)) {
      return _currentBgmAsset!;
    }
    return _pickNextGameplayTrack();
  }

  String _pickNextGameplayTrack() {
    if (_gameplayTracks.length <= 1) {
      return _gameplayTracks.first;
    }
    final candidates = List<String>.from(_gameplayTracks);
    if (_currentBgmAsset != null) {
      candidates.remove(_currentBgmAsset);
    }
    return candidates[_rng.nextInt(candidates.length)];
  }

  Future<void> _handleBgmCompletion() async {
    if (!_musicEnabled || !_isForeground) return;
    if (_scene != AudioScene.gameplay && _scene != AudioScene.gameOver) return;
    final next = _pickNextGameplayTrack();
    await _playBgm(next, loop: false);
  }

  Future<void> _playBgm(String asset, {required bool loop}) async {
    if (_currentBgmAsset == asset && _bgmPlayer.playing) {
      return;
    }

    final bool canResumeCurrent = _currentBgmAsset == asset &&
        _bgmPlayer.processingState == ProcessingState.ready;

    if (!canResumeCurrent) {
      await _fadeOutAndStop();
      try {
        await _bgmPlayer.setLoopMode(loop ? LoopMode.one : LoopMode.off);
        await _bgmPlayer.setAsset(asset);
        _currentBgmAsset = asset;
      } catch (_) {
        _currentBgmAsset = null;
        return;
      }
    } else {
      await _bgmPlayer.setLoopMode(loop ? LoopMode.one : LoopMode.off);
    }

    final resumePosition = _resumeAsset == asset ? _resumePosition : null;
    if (resumePosition != null) {
      try {
        await _bgmPlayer.seek(resumePosition);
      } catch (_) {
        // Ignore seek failures.
      }
    } else {
      try {
        await _bgmPlayer.seek(Duration.zero);
      } catch (_) {}
    }
    _resumeAsset = null;
    _resumePosition = null;

    await _bgmPlayer.setVolume(0);
    try {
      await _bgmPlayer.play();
    } catch (_) {
      return;
    }
    await _fadeTo(_bgmTargetVolume, _fadeInDuration);
  }

  Future<void> _pauseBgm({required bool savePosition}) async {
    if (!_bgmPlayer.playing && _bgmPlayer.processingState != ProcessingState.ready) {
      return;
    }
    if (savePosition && _currentBgmAsset != null) {
      _resumeAsset = _currentBgmAsset;
      _resumePosition = _bgmPlayer.position;
    }
    await _fadeTo(0, _fadeOutDuration);
    try {
      await _bgmPlayer.pause();
    } catch (_) {}
  }

  Future<void> _stopBgm() async {
    if (_bgmPlayer.processingState == ProcessingState.idle) return;
    await _fadeOutAndStop();
    _currentBgmAsset = null;
    _resumeAsset = null;
    _resumePosition = null;
  }

  Future<void> _fadeOutAndStop() async {
    await _fadeTo(0, _fadeOutDuration);
    try {
      await _bgmPlayer.stop();
    } catch (_) {}
  }

  Future<void> _fadeTo(double targetVolume, Duration duration) async {
    final start = _bgmPlayer.volume;
    if (duration == Duration.zero) {
      await _bgmPlayer.setVolume(targetVolume);
      return;
    }
    const int steps = 8;
    final stepDuration = Duration(
      milliseconds: (duration.inMilliseconds / steps).round(),
    );
    for (int i = 1; i <= steps; i++) {
      final value = start + (targetVolume - start) * (i / steps);
      try {
        await _bgmPlayer.setVolume(value);
      } catch (_) {
        break;
      }
      await Future.delayed(stepDuration);
    }
  }

  String? _sfxAsset(AudioSfx type) {
    switch (type) {
      case AudioSfx.transition:
        return 'assets/sfx/transition.mp3';
      case AudioSfx.redTurn:
        return 'assets/sfx/red_turn.mp3';
      case AudioSfx.blueTurn:
        return 'assets/sfx/blue_turn.mp3';
      case AudioSfx.bombAdd:
        return 'assets/sfx/bomb_add.mp3';
      case AudioSfx.explosion:
        return 'assets/sfx/explosion.mp3';
      case AudioSfx.greyShake:
        return 'assets/sfx/grey_shake.mp3';
    }
  }

  Future<void> _ensureAudioSession() async {
    try {
      _audioSession ??= await AudioSession.instance;
      if (!_sessionConfigured) {
        await _audioSession!.configure(AudioSessionConfiguration.music());
        _sessionConfigured = true;
      }
      await _audioSession!.setActive(true);
    } catch (_) {
      // Fail silently.
    }
  }

  Future<void> dispose() async {
    await _bgmStateSub?.cancel();
    await _bgmPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}
