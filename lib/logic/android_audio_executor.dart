/// Android-specific audio execution primitives (BGM channel + SFX player)
/// built on just_audio and audio_session.
///
/// Goals (Android only behavior):
/// - BGM and SFX share the same AudioSession.
/// - SFX playback must not steal or abandon audio focus from BGM.
/// - Background/inactive lifecycle (propagated via AudioCoordinator -> Intent)
///   results in immediate BGM pause; focus loss events from the OS also pause.
/// - On focus regain, resume only if the last commanded state was "should play".
///
/// These classes do not inspect AudioState; they only react to intents
/// (via executor calls) and Android focus/interrupt events. On non-Android
/// platforms, Android-specific calls are no-ops.

import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
// Android audio attribute types are exported by just_audio.
import 'package:just_audio/just_audio.dart' show AndroidAudioAttributes, AndroidAudioContentType, AndroidAudioUsage;

import 'audio_intent_resolver.dart';
import 'audio_executor.dart';
import 'audio_coordinator.dart';

/// Internal singleton: configures and exposes the shared Android audio session.
class _AndroidAudioSession {
  _AndroidAudioSession._();
  static final _AndroidAudioSession instance = _AndroidAudioSession._();

  AudioSession? _session;
  StreamSubscription<AudioInterruptionEvent>? _interruptions;

  /// Whether BGM is intended to be playing per last applied intent.
  /// This is set by the BGM channel when executor requests play/pause.
  bool shouldBePlaying = false;

  Future<AudioSession> ensureConfigured() async {
    if (_session != null) return _session!;
    final s = await AudioSession.instance;
    // Base music configuration: this sets up focus handling for the app.
    // We avoid pausing when ducked explicitly and prefer continuous playback.
    final cfg = AudioSessionConfiguration.music();
    await s.configure(cfg);
    _session = s;
    return s;
  }

  void listenInterruptions({required Future<void> Function() onPauseRequested, required Future<void> Function() onResumeRequested}) async {
    final s = await ensureConfigured();
    await _interruptions?.cancel();
    _interruptions = s.interruptionEventStream.listen((event) async {
      // Handle focus interruptions from the OS.
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.pause:
            // True focus loss -> pause.
            await onPauseRequested();
            break;
          case AudioInterruptionType.duck:
            // Do not pause on duck; keep playing quietly if system requests.
            break;
          case AudioInterruptionType.unknown:
            // Be conservative: do nothing here; coordinator lifecycle will drive state.
            break;
          // Unsupported or not used types in this audio_session version are ignored.
        }
      } else {
        // Interruption ended; only resume if the executor previously commanded play.
        if (shouldBePlaying) {
          await onResumeRequested();
        }
      }
    });
  }

  Future<void> dispose() async {
    await _interruptions?.cancel();
    _interruptions = null;
  }
}

/// Android BGM channel using a single AudioPlayer and shared AudioSession.
class AndroidBgmChannel implements BgmChannel {
  final AudioPlayer _player = AudioPlayer();
  BgmKind? _currentKind;
  LoopKind _currentLoop = LoopKind.na;
  bool _configured = false;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _AndroidAudioSession.instance.ensureConfigured();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      // Ensure MUSIC/media attributes for background music.
      await _player.setAndroidAudioAttributes(AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media, // or game
        // No explicit focus gain here; session handles focus. Keep non-exclusive.
      ));
    }
    // Listen to interruptions to pause/resume safely.
    _AndroidAudioSession.instance.listenInterruptions(
      onPauseRequested: () async {
        await _player.pause();
      },
      onResumeRequested: () async {
        // Resume only if a play intent is active.
        await _player.play();
      },
    );
    _configured = true;
  }

  AudioSource _menuSource() => AudioSource.asset('assets/m4a/main_page.m4a');

  AudioSource _gameplaySource() => ConcatenatingAudioSource(children: [
        AudioSource.asset('assets/m4a/game_challange_1.m4a'),
        AudioSource.asset('assets/m4a/game_challange_2.m4a'),
      ]);

  Future<void> _loadFor(BgmKind kind) async {
    await _ensureConfigured();
    if (kind == BgmKind.menu) {
      // Load only if different to avoid reloading on SFX.
      await _player.setAudioSource(_menuSource());
      await setLoop(LoopKind.one);
    } else {
      await _player.setAudioSource(_gameplaySource());
      await setLoop(LoopKind.sequence);
    }
    _currentKind = kind;
  }

  @override
  Future<void> setLoop(LoopKind loop) async {
    await _ensureConfigured();
    _currentLoop = loop;
    switch (loop) {
      case LoopKind.one:
        await _player.setLoopMode(LoopMode.one);
        break;
      case LoopKind.sequence:
        await _player.setLoopMode(LoopMode.all);
        break;
      case LoopKind.na:
        await _player.setLoopMode(LoopMode.off);
        break;
    }
  }

  @override
  Future<void> play(BgmKind kind) async {
    await _ensureConfigured();
    if (_currentKind != kind || _player.audioSource == null) {
      await _loadFor(kind);
    }
    await _player.play();
    _AndroidAudioSession.instance.shouldBePlaying = true;
  }

  @override
  Future<void> pause() async {
    await _ensureConfigured();
    await _player.pause();
    _AndroidAudioSession.instance.shouldBePlaying = false;
  }

  @override
  Future<void> stop() async {
    await _ensureConfigured();
    await _player.stop();
    _AndroidAudioSession.instance.shouldBePlaying = false;
  }

  @override
  Future<void> crossfadeTo(BgmKind kind, {LoopKind? loop}) async {
    await _ensureConfigured();
    if (loop != null) {
      await setLoop(loop);
    }
    if (_currentKind != kind) {
      await _loadFor(kind);
    }
    await _player.play();
    _AndroidAudioSession.instance.shouldBePlaying = true;
  }
}

/// Simple policy bus; intentional no-ops beyond storing current value.
class AndroidSfxBus implements SfxBus {
  SfxPolicy current = SfxPolicy.blocked;
  @override
  Future<void> setPolicy(SfxPolicy policy) async {
    current = policy;
  }
}

/// SFX player that shares the same AudioSession and uses attributes that avoid
/// stealing audio focus from BGM. No session (re)configuration here.
class AndroidSfxPlayer implements SfxPlayer {
  final AndroidSfxBus _policyBus;
  final Map<SfxType, AudioPlayer> _players = <SfxType, AudioPlayer>{};
  final Map<SfxType, bool> _loaded = <SfxType, bool>{};

  AndroidSfxPlayer(this._policyBus);

  Future<AudioPlayer> _ensurePlayer(SfxType type) async {
    final p = _players.putIfAbsent(type, () => AudioPlayer());
    // Configure Android attributes for SFX to minimize focus impact.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await p.setAndroidAudioAttributes(AndroidAudioAttributes(
        contentType: AndroidAudioContentType.sonification,
        usage: AndroidAudioUsage.assistanceSonification,
        // Do not request exclusive focus; transient sounds overlay BGM.
      ));
    }
    return p;
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
      case SfxType.startup:
        return 'assets/sfx/dual_clash.mp3';
    }
  }

  @override
  Future<void> play(SfxType type) async {
    if (_policyBus.current == SfxPolicy.blocked) return;
    await _AndroidAudioSession.instance.ensureConfigured();
    final player = await _ensurePlayer(type);
    if (!(_loaded[type] ?? false)) {
      await player.setAsset(_assetFor(type));
      _loaded[type] = true;
    }
    await player.seek(Duration.zero);
    // Important: do not pause/stop BGM here; rely on shared session and android attributes.
    // Start playback but do not await completion to avoid blocking UI/logic.
    unawaited(player.play());
  }
}
