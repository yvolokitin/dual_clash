/// AudioExecutor — applies AudioIntent imperatively without making decisions.
///
/// Responsibilities (what it DOES):
/// - Receive AudioIntent snapshots produced by the pure resolver.
/// - Compare the new intent with the previous one and apply only the necessary
///   changes to the audio system via provided channels (BGM channel and SFX bus).
/// - Enforce "single BGM" invariant (one channel) and keep BGM and SFX separate.
/// - Handle BGM transitions (play, pause, switch, optional fade/crossfade) and
///   loop mode updates (one vs sequence) based solely on the AudioIntent.
///
/// Non‑Responsibilities (what it MUST NOT do):
/// - MUST NOT inspect AudioState (it never sees it).
/// - MUST NOT duplicate decision logic from the resolver; no alternate rules.
/// - MUST NOT reference UI, routes, settings, or platform specifics.
/// - MUST NOT choose assets or playlists here; the BGM channel implementation
///   encapsulates that. Executor only issues high‑level commands.
/// - MUST NOT start timers or rely on prior app state (other than the previous
///   AudioIntent for diffing/idempotency).
///
/// Design notes:
/// - The executor is intentionally thin and deterministic given a sequence of
///   AudioIntent inputs. It maintains minimal internal state (lastIntent) to
///   compute diffs and avoid redundant commands.
/// - Platform integration (e.g., just_audio, audio_session) belongs in the
///   channel implementations, not in this class.

import 'audio_intent_resolver.dart';

/// Abstract single BGM channel (exactly one exists). Platform implementers
/// should translate these high‑level commands into concrete player actions.
abstract class BgmChannel {
  /// Ensure loop mode; implementations decide how to map LoopKind onto players.
  Future<void> setLoop(LoopKind loop);

  /// Begin or resume playback for the specified BGM kind (menu/gameplay).
  /// If assets must be (re)loaded, do so internally.
  Future<void> play(BgmKind kind);

  /// Pause playback (retain current position/track as appropriate).
  Future<void> pause();

  /// Stop playback and release any transient resources if desired.
  Future<void> stop();

  /// Smoothly switch to another BGM kind (e.g., crossfade). If loop is provided,
  /// apply it as part of the transition. Implementations may no‑op when the
  /// target equals current.
  Future<void> crossfadeTo(BgmKind kind, {LoopKind? loop});
}

/// SFX bus — controls global SFX policy. Concrete implementations should
/// gate/allow SFX playback based on this policy.
abstract class SfxBus {
  Future<void> setPolicy(SfxPolicy policy);
}

/// AudioExecutor consumes AudioIntent outputs and applies them via channels.
class AudioExecutor {
  final BgmChannel _bgm;
  final SfxBus _sfx;

  AudioIntent? _last;

  // Cached view of applied BGM "program" and loop policy for quick diffs
  BgmKind? _currentBgmKind; // null means unknown; use _last as source of truth
  LoopKind? _currentLoop;

  AudioExecutor({required BgmChannel bgmChannel, required SfxBus sfxBus})
      : _bgm = bgmChannel,
        _sfx = sfxBus;

  /// Apply a new AudioIntent. This method performs only imperative enactment of
  /// the given intent; it does not perform any decision‑making beyond minimal
  /// diffing to avoid redundant work.
  ///
  /// Pseudocode overview (no decision duplication):
  /// 1) Update SFX policy unconditionally if changed.
  /// 2) Handle BGM according to intent:
  ///    - If intent.bgmAction == pause OR intent.bgm == none:
  ///        pause BGM (idempotent).
  ///    - Else (play requested for menu/gameplay):
  ///        a) If program changed: crossfadeTo(newKind, loop=intent.loop).
  ///        b) Else program same:
  ///             - If loop changed: setLoop(intent.loop).
  ///             - Ensure playing: play(kind).
  /// 3) Cache last applied intent to compute future diffs.
  Future<void> applyIntent(AudioIntent intent) async {
    // 1) SFX policy (global)
    if (_last == null || _last!.sfx != intent.sfx) {
      await _sfx.setPolicy(intent.sfx);
    }

    // 2) BGM handling — strictly based on intent fields
    final bool shouldPause =
        intent.bgm == BgmKind.none || intent.bgmAction == BgmAction.pause;

    if (shouldPause) {
      // Pause regardless of what was playing.
      await _bgm.pause();
      _currentBgmKind = BgmKind.none;
      _currentLoop = LoopKind.na;
    } else {
      // Play path: bgm is menu/gameplay and action is play.
      final BgmKind newKind = intent.bgm;
      final LoopKind newLoop = intent.loop;

      final bool programChanged = _currentBgmKind == null
          ? (_last?.bgm != null && _last!.bgm != newKind)
          : _currentBgmKind != newKind;

      if (programChanged) {
        // Switch with a smooth transition if possible.
        await _bgm.crossfadeTo(newKind, loop: newLoop);
        _currentBgmKind = newKind;
        _currentLoop = newLoop;
      } else {
        // Same program; update loop if needed, then ensure playing.
        if (_currentLoop == null || _currentLoop != newLoop) {
          await _bgm.setLoop(newLoop);
          _currentLoop = newLoop;
        }
        await _bgm.play(newKind);
      }
    }

    // 3) Update cache
    _last = intent;
  }
}
