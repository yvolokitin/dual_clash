import 'dart:async';
import 'dart:math' as math;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class GameChallengeMusicController {
  GameChallengeMusicController._() {
    _playerStateSub = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _handleTrackCompletion();
      }
    });
  }

  static final GameChallengeMusicController instance =
      GameChallengeMusicController._();

  final AudioPlayer _player = AudioPlayer();
  final math.Random _rng = math.Random();
  final List<String> _tracks = const [
    'assets/m4a/game_challange_1.m4a',
    'assets/m4a/game_challange_2.m4a',
  ];
  StreamSubscription<PlayerState>? _playerStateSub;
  bool _enabled = true;
  bool _challengeActive = false;
  bool _sessionConfigured = false;
  bool _isHandlingCompletion = false;
  String? _currentTrack;

  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    await _syncPlayback();
  }

  Future<void> setChallengeActive(bool active) async {
    _challengeActive = active;
    await _syncPlayback();
  }

  Future<void> _syncPlayback() async {
    if (!_enabled || !_challengeActive) {
      await _stop();
      return;
    }
    await _playRandomTrack();
  }

  Future<void> _playRandomTrack() async {
    try {
      await _ensureAudioSession();
      final nextTrack = _pickNextTrack();
      _currentTrack = nextTrack;
      await _player.setAsset(nextTrack);
      await _player.play();
    } catch (error) {
      debugPrint('GameChallengeMusicController: failed to play music: $error');
    }
  }

  String _pickNextTrack() {
    if (_tracks.length <= 1) {
      return _tracks.first;
    }
    final candidates = List<String>.from(_tracks);
    if (_currentTrack != null && candidates.length > 1) {
      candidates.remove(_currentTrack);
    }
    return candidates[_rng.nextInt(candidates.length)];
  }

  Future<void> _handleTrackCompletion() async {
    if (_isHandlingCompletion) return;
    if (!_enabled || !_challengeActive) return;
    _isHandlingCompletion = true;
    try {
      await _playRandomTrack();
    } finally {
      _isHandlingCompletion = false;
    }
  }

  Future<void> _ensureAudioSession() async {
    if (_sessionConfigured) return;
    try {
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration.music());
      _sessionConfigured = true;
    } catch (error) {
      debugPrint('GameChallengeMusicController: audio session error: $error');
    }
  }

  Future<void> _stop() async {
    try {
      if (_player.playing) {
        await _player.pause();
      }
    } catch (error) {
      debugPrint('GameChallengeMusicController: failed to stop music: $error');
    }
  }

  Future<void> dispose() async {
    await _playerStateSub?.cancel();
    await _player.dispose();
  }
}
