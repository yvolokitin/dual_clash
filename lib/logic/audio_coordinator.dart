/// AudioCoordinator — bridges external app events to the audio system.
///
/// Responsibilities (what it DOES):
/// - Own the current immutable AudioState snapshot.
/// - Update AudioState in response to external events (app lifecycle, route,
///   navigation, menu readiness, challenge activity, user settings).
/// - Recompute AudioIntent using the pure resolver after every change.
/// - Forward AudioIntent changes to AudioExecutor, but only when the intent
///   actually changes (no redundant apply calls).
///
/// Non‑Responsibilities (what it MUST NOT do):
/// - MUST NOT contain audio playback code or reference just_audio/platform APIs.
/// - MUST NOT inspect UI widgets, routes, or controllers directly.
/// - MUST NOT duplicate or reinterpret decision logic (resolver is the source of truth).
/// - MUST NOT mutate AudioState in place; always create a new instance.
///
/// Notes:
/// - This module is platform‑agnostic and free of side effects except for
///   delegating intents to the provided AudioExecutor.
/// - It can be unit‑tested in isolation by mocking AudioExecutor.

import 'audio_intent_resolver.dart';
import 'audio_executor.dart';

/// Discrete sound effects available via the coordinator.
enum SfxType { redTurn, blueTurn, bombAdd, explosion, greyShake, transition, startup }

/// Abstract SFX player used by the coordinator (imperative executor for one-shots).
abstract class SfxPlayer {
  Future<void> play(SfxType type);
}

/// Coordinates AudioState updates and applies AudioIntent via AudioExecutor.
class AudioCoordinator {
  final AudioExecutor _executor;
  final SfxPlayer? _sfx; // optional SFX player for one-shot effects

  AudioState _state;
  AudioIntent? _lastIntent;

  /// Create a coordinator with an initial state. If not provided, a safe
  /// default is used (foreground, other route, idle navigation; no menu/gameplay
  /// activity; music and sfx enabled).
  AudioCoordinator({
    required AudioExecutor executor,
    SfxPlayer? sfxPlayer,
    AudioState? initialState,
  })  : _executor = executor,
        _sfx = sfxPlayer,
        _state = initialState ??
            const AudioState(
              appLifecycle: AppLifecycle.foreground,
              routeContext: RouteContext.other,
              navigationPhase: NavigationPhase.idle,
              menuReady: false,
              challengeActive: false,
              musicEnabled: true,
              sfxEnabled: true,
            );

  /// Current immutable snapshot. Never modify fields on this object; instead
  /// call one of the event handlers below to create and apply a new state.
  AudioState get currentState => _state;

  /// Force recomputation/apply for the current state (e.g., call once after
  /// wiring the coordinator to initialize audio to the initial state).
  Future<void> sync() => _recomputeAndApply();

  // ---- Event handlers (inputs) ----

  Future<void> onAppLifecycleChanged(AppLifecycle lifecycle) async {
    _state = _copy(appLifecycle: lifecycle);
    await _recomputeAndApply();
  }

  Future<void> onRouteContextChanged(RouteContext context) async {
    // When route context changes, keep orthogonal flags as‑is.
    _state = _copy(routeContext: context);
    await _recomputeAndApply();
  }

  Future<void> onNavigationPhaseChanged(NavigationPhase phase) async {
    _state = _copy(navigationPhase: phase);
    await _recomputeAndApply();
  }

  Future<void> onMenuReadyChanged(bool ready) async {
    _state = _copy(menuReady: ready);
    await _recomputeAndApply();
  }

  Future<void> onChallengeActiveChanged(bool active) async {
    _state = _copy(challengeActive: active);
    await _recomputeAndApply();
  }

  Future<void> onUserSettingsChanged({
    required bool musicEnabled,
    required bool sfxEnabled,
  }) async {
    _state = _copy(musicEnabled: musicEnabled, sfxEnabled: sfxEnabled);
    await _recomputeAndApply();
  }

  Future<void> onMusicEnabledChanged(bool enabled) =>
      onUserSettingsChanged(musicEnabled: enabled, sfxEnabled: _state.sfxEnabled);

  Future<void> onSfxEnabledChanged(bool enabled) =>
      onUserSettingsChanged(musicEnabled: _state.musicEnabled, sfxEnabled: enabled);

  // ---- Gameplay-specific convenience events ----

  /// Entering gameplay context. This enforces invariants:
  /// - routeContext becomes gameplay
  /// - menuReady is forced false
  /// - challengeActive is set to [active]
  Future<void> onGameplayEntered({bool active = true}) async {
    _state = _copy(
      routeContext: RouteContext.gameplay,
      menuReady: false,
      challengeActive: active,
    );
    await _recomputeAndApply();
  }

  /// Exiting gameplay context. This enforces invariants:
  /// - challengeActive becomes false
  /// - routeContext switches to [next] (defaults to other)
  /// - menuReady is reset to false unless next == menu (menu page will set it)
  Future<void> onGameplayExited({RouteContext next = RouteContext.other}) async {
    final bool keepMenuReady = next == RouteContext.menu;
    _state = _copy(
      challengeActive: false,
      routeContext: next,
      menuReady: keepMenuReady ? _state.menuReady : false,
    );
    await _recomputeAndApply();
  }

  /// Start gameplay challenge. Guarantees gameplay context and menuReady=false.
  Future<void> onChallengeStarted() async {
    _state = _copy(
      routeContext: RouteContext.gameplay,
      menuReady: false,
      challengeActive: true,
    );
    await _recomputeAndApply();
  }

  /// End gameplay challenge (does not change route context).
  Future<void> onChallengeEnded() async {
    _state = _copy(challengeActive: false);
    await _recomputeAndApply();
  }

  // ---- Internal helpers ----

  AudioState _copy({
    AppLifecycle? appLifecycle,
    RouteContext? routeContext,
    NavigationPhase? navigationPhase,
    bool? menuReady,
    bool? challengeActive,
    bool? musicEnabled,
    bool? sfxEnabled,
  }) {
    return AudioState(
      appLifecycle: appLifecycle ?? _state.appLifecycle,
      routeContext: routeContext ?? _state.routeContext,
      navigationPhase: navigationPhase ?? _state.navigationPhase,
      menuReady: menuReady ?? _state.menuReady,
      challengeActive: challengeActive ?? _state.challengeActive,
      musicEnabled: musicEnabled ?? _state.musicEnabled,
      sfxEnabled: sfxEnabled ?? _state.sfxEnabled,
    );
  }

  Future<void> _recomputeAndApply() async {
    final AudioIntent next = resolve(_state);
    if (_lastIntent == null || !_intentEquals(_lastIntent!, next)) {
      await _executor.applyIntent(next);
      _lastIntent = next;
    }
  }

  bool _intentEquals(AudioIntent a, AudioIntent b) {
    return a.bgm == b.bgm &&
        a.bgmAction == b.bgmAction &&
        a.loop == b.loop &&
        a.sfx == b.sfx;
  }

  /// Play a one-shot SFX if allowed by current policy. Does not change state.
  Future<void> playSfx(SfxType type) async {
    // Determine current SFX policy based on the latest intent; if none, compute now.
    AudioIntent intent;
    if (_lastIntent == null) {
      intent = resolve(_state);
      _lastIntent = intent; // cache for next time (no apply)
    } else {
      intent = _lastIntent!;
    }
    if (intent.sfx == SfxPolicy.allowed) {
      await _sfx?.play(type);
    }
  }
}

/// Example flow (menu → transition → gameplay):
///
/// 1) App starts at menu, intro finished:
///    onRouteContextChanged(menu); onMenuReadyChanged(true);
///    -> resolve(state) => { bgm=menu, action=play, loop=one, sfx=allowed }
///
/// 2) Begin navigation to gameplay:
///    onNavigationPhaseChanged(transitioning);
///    -> resolve(state) => { bgm=none, action=pause, loop=na, sfx=allowed }
///
/// 3) Switch route to gameplay while still transitioning:
///    onRouteContextChanged(gameplay); onChallengeActiveChanged(true);
///    -> resolve(state) => { bgm=none, action=pause, loop=na, sfx=allowed }
///
/// 4) Transition ends (now on gameplay):
///    onNavigationPhaseChanged(idle);
///    -> resolve(state) => { bgm=gameplay, action=play, loop=sequence, sfx=allowed }
