import 'dart:async';
import 'dart:math' as math;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';

enum AudioContext {
  menu,
  gameplay,
  paused,
  gameOver,
  background,
}

enum AudioSfx {
  transition,
  redTurn,
  blueTurn,
  bombAdd,
  explosion,
  greyShake,
}

class AudioManager with WidgetsBindingObserver {
  AudioManager._() {
    _attachBgmListener();
  }

  static final AudioManager instance = AudioManager._();

  static const Duration _fadeInDuration = Duration(milliseconds: 600);
  static const Duration _fadeOutDuration = Duration(milliseconds: 450);
  static const double _bgmTargetVolume = 1.0;

  AudioPlayer _bgmPlayer = AudioPlayer();
  final Map<AudioSfx, AudioPlayer> _sfxPlayers =
      <AudioSfx, AudioPlayer>{};
  final Map<AudioSfx, bool> _sfxLoaded = <AudioSfx, bool>{};
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
  bool _isBackground = false;
  bool _resumeAfterBackground = false;
  bool _suppressAutoResumeOnce = false;
  bool _initialized = false;
  bool _userGestureUnlocked = !kIsWeb;
  AudioContext _context = AudioContext.background;
  AudioContext _lastAppliedContext = AudioContext.background;
  AudioContext? _contextBeforeBackground;
  String? _currentBgmAsset;
  String? _resumeAsset;
  Duration? _resumePosition;

  void initialize() {
    if (_initialized) return;
    WidgetsBinding.instance.addObserver(this);
    _initialized = true;
  }

  void _attachBgmListener() {
    _bgmStateSub?.cancel();
    _bgmStateSub = _bgmPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _queueSync(_handleBgmCompletion);
      }
    });
  }

  void setSettings({required bool musicEnabled, required bool sfxEnabled}) {
    _musicEnabled = musicEnabled;
    _sfxEnabled = sfxEnabled;
    _queueSync(_applyState);
  }

  void setContext(AudioContext context) {
    if (_context == context) return;
    _context = context;
    _queueSync(_applyState);
  }

  void registerUserGesture() {
    if (_userGestureUnlocked) return;
    _userGestureUnlocked = true;
    _queueSync(_applyState);
  }

  void bootstrapInitialBgm() {
    _queueSync(() async {
      if (!_musicEnabled) return;
      if (_bgmPlayer.playing) return;
      if (_isBackground ||
          _context == AudioContext.background ||
          _context == AudioContext.paused) {
        return;
      }
      await _ensureAudioSession();
      switch (_context) {
        case AudioContext.menu:
          await _playMenuBgm();
          break;
        case AudioContext.gameplay:
        case AudioContext.gameOver:
          await _playGameplayBgm();
          break;
        case AudioContext.paused:
        case AudioContext.background:
          break;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bool isBackground = state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden;
    if (_isBackground == isBackground) return;
    _isBackground = isBackground;
    if (_isBackground) {
      _contextBeforeBackground = _context;
      _resumeAfterBackground = _bgmPlayer.playing ||
          _bgmPlayer.processingState == ProcessingState.ready;
      _suppressAutoResumeOnce = false;
    } else if (!_resumeAfterBackground) {
      _suppressAutoResumeOnce = _currentBgmAsset != null &&
          _bgmPlayer.processingState != ProcessingState.idle;
      _lastAppliedContext = _context;
    }
    _queueSync(_applyState);
  }

  Future<void> playSfx(AudioSfx type) async {
    if (!_sfxEnabled) return;
    await _ensureAudioSession();
    final asset = _sfxAsset(type);
    if (asset == null) return;
    try {
      final player = _sfxPlayers.putIfAbsent(type, () => AudioPlayer());
      if (!(_sfxLoaded[type] ?? false)) {
        await player.setAsset(asset);
        _sfxLoaded[type] = true;
      }
      await player.seek(Duration.zero);
      await player.play();
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
    if (_isBackground || _context == AudioContext.background) {
      await _pauseBgm(savePosition: true);
      return;
    }
    if (!_userGestureUnlocked && kIsWeb) {
      return;
    }
    if (_suppressAutoResumeOnce &&
        _contextBeforeBackground == _context &&
        !_bgmPlayer.playing) {
      _suppressAutoResumeOnce = false;
      return;
    }
    _resumeAfterBackground = true;
    if (_context == _lastAppliedContext && _bgmPlayer.playing) {
      return;
    }
    _lastAppliedContext = _context;
    switch (_context) {
      case AudioContext.menu:
        await _playMenuBgm();
        break;
      case AudioContext.gameplay:
      case AudioContext.gameOver:
        await _playGameplayBgm();
        break;
      case AudioContext.paused:
      case AudioContext.background:
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
    if (!_musicEnabled || _isBackground) return;
    if (_context != AudioContext.gameplay &&
        _context != AudioContext.gameOver) {
      return;
    }
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
        if (_bgmPlayer.processingState == ProcessingState.idle ||
            _bgmPlayer.processingState == ProcessingState.completed) {
          await _bgmPlayer.dispose();
          _bgmPlayer = AudioPlayer();
          _attachBgmListener();
        }
        await _bgmPlayer.setLoopMode(loop ? LoopMode.one : LoopMode.off);
        if (kDebugMode) {
          debugPrint('[BGM] load asset: $asset');
          debugPrint('[BGM] before load: ${_bgmPlayer.processingState}');
        }
        await _bgmPlayer.setAudioSource(AudioSource.asset(asset));
        await _bgmPlayer.load();
        try {
          await _bgmPlayer.processingStateStream
              .firstWhere((state) =>
                  state == ProcessingState.ready ||
                  state == ProcessingState.playing)
              .timeout(const Duration(seconds: 2));
        } catch (_) {
          if (kDebugMode) {
            debugPrint('[BGM] ready timeout, forcing play');
          }
        }
        if (kDebugMode) {
          debugPrint('[BGM] after load: ${_bgmPlayer.processingState}');
        }
        _currentBgmAsset = asset;
      } catch (error) {
        if (kDebugMode) {
          debugPrint('[BGM] load error: $error');
        }
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
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await session.setActive(true);
      if (kDebugMode) {
        debugPrint('[BGM] play() called for $asset');
      }
      await _bgmPlayer.play();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[BGM] play error: $error');
      }
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
    if (_initialized) {
      WidgetsBinding.instance.removeObserver(this);
      _initialized = false;
    }
    await _bgmStateSub?.cancel();
    await _bgmPlayer.dispose();
    for (final player in _sfxPlayers.values) {
      await player.dispose();
    }
  }
}
