import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class MainMenuMusicController {
  MainMenuMusicController._();

  static final MainMenuMusicController instance = MainMenuMusicController._();

  final AudioPlayer _player = AudioPlayer();
  bool _isLoaded = false;
  bool _enabled = true;
  bool _mainMenuVisible = false;
  bool _menuReady = false;
  bool _sessionConfigured = false;

  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    await _syncPlayback();
  }

  Future<void> setMainMenuVisible(bool visible) async {
    _mainMenuVisible = visible;
    await _syncPlayback();
  }

  Future<void> setMenuReady(bool ready) async {
    _menuReady = ready;
    await _syncPlayback();
  }

  Future<void> _syncPlayback() async {
    if (!_enabled || !_mainMenuVisible || !_menuReady) {
      await _stop();
      return;
    }
    await _play();
  }

  Future<void> _play() async {
    try {
      await _ensureAudioSession();
      if (!_isLoaded) {
        await _player.setAsset('assets/m4a/main_page.m4a');
        await _player.setLoopMode(LoopMode.one);
        _isLoaded = true;
        await _player.seek(Duration.zero);
      }
      if (!_player.playing) {
        await _player.play();
      }
    } catch (error) {
      debugPrint('MainMenuMusicController: failed to play music: $error');
    }
  }

  Future<void> _ensureAudioSession() async {
    if (_sessionConfigured) return;
    try {
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration.music());
      _sessionConfigured = true;
    } catch (error) {
      debugPrint('MainMenuMusicController: audio session error: $error');
    }
  }

  Future<void> _stop() async {
    try {
      if (_player.playing) {
        await _player.pause();
      }
    } catch (error) {
      debugPrint('MainMenuMusicController: failed to stop music: $error');
    }
  }

  Future<void> stop() async {
    await _stop();
  }

  Future<void> resume() async {
    await _syncPlayback();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
