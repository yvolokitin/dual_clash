import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class TransitionSfxController {
  TransitionSfxController._();

  static final TransitionSfxController instance = TransitionSfxController._();

  final AudioPlayer _player = AudioPlayer();
  bool _isLoaded = false;
  bool _sessionConfigured = false;

  Future<void> play() async {
    try {
      await _ensureAudioSession();
      if (!_isLoaded) {
        await _player.setAsset('assets/sfx/transition.mp3');
        _isLoaded = true;
      }
      await _player.seek(Duration.zero);
      if (!_player.playing) {
        await _player.play();
      }
    } catch (error) {
      debugPrint('TransitionSfxController: failed to play sfx: $error');
    }
  }

  Future<void> _ensureAudioSession() async {
    if (_sessionConfigured) return;
    try {
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration.music());
      _sessionConfigured = true;
    } catch (error) {
      debugPrint('TransitionSfxController: audio session error: $error');
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
