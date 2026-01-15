import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

enum GameSfxType {
  redTurn,
  blueTurn,
  bombAdd,
  explosion,
  greyShake,
}

class GameSfxController {
  GameSfxController._();

  static final GameSfxController instance = GameSfxController._();

  final Map<GameSfxType, AudioPlayer> _players =
      <GameSfxType, AudioPlayer>{};
  final Map<GameSfxType, bool> _loaded = <GameSfxType, bool>{};
  bool _sessionConfigured = false;
  bool _enabled = true;

  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  Future<void> play(GameSfxType type) async {
    if (!_enabled) return;
    try {
      await _ensureAudioSession();
      final player = _players.putIfAbsent(type, () => AudioPlayer());
      if (!(_loaded[type] ?? false)) {
        await player.setAsset(_assetFor(type));
        _loaded[type] = true;
      }
      await player.seek(Duration.zero);
      await player.play();
    } catch (error) {
      debugPrint('GameSfxController: failed to play $type: $error');
    }
  }

  String _assetFor(GameSfxType type) {
    switch (type) {
      case GameSfxType.redTurn:
        return 'assets/sfx/red_turn.mp3';
      case GameSfxType.blueTurn:
        return 'assets/sfx/blue_turn.mp3';
      case GameSfxType.bombAdd:
        return 'assets/sfx/bomb_add.mp3';
      case GameSfxType.explosion:
        return 'assets/sfx/explosion.mp3';
      case GameSfxType.greyShake:
        return 'assets/sfx/grey_shake.mp3';
    }
  }

  Future<void> _ensureAudioSession() async {
    if (_sessionConfigured) return;
    try {
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration.music());
      _sessionConfigured = true;
    } catch (error) {
      debugPrint('GameSfxController: audio session error: $error');
    }
  }

  Future<void> stopAll() async {
    for (final player in _players.values) {
      try {
        if (player.playing) {
          await player.pause();
        }
      } catch (error) {
        debugPrint('GameSfxController: failed to stop sfx: $error');
      }
    }
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
  }
}
