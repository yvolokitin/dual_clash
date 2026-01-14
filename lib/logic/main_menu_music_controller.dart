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
      if (!_isLoaded) {
        await _player.setAsset('assets/m4a/main_page.m4a');
        await _player.setLoopMode(LoopMode.one);
        _isLoaded = true;
      }
      if (!_player.playing) {
        await _player.play();
      }
    } catch (error) {
      debugPrint('MainMenuMusicController: failed to play music: $error');
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

  Future<void> dispose() async {
    await _player.dispose();
  }
}
