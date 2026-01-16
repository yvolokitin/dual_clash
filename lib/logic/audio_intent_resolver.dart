/// Pure, deterministic AudioState -> AudioIntent resolver.
///
/// NOTE: This file intentionally contains no references to Flutter, just_audio,
/// platform APIs, or any side effects. It defines immutable data classes and a
/// pure resolve() function suitable for unit testing in isolation.

// -----------------------------
// Input model (AudioState)
// -----------------------------

/// App lifecycle phases relevant for audio decisions.
enum AppLifecycle { foreground, background, inactive }

/// High-level UI route context.
enum RouteContext { menu, gameplay, other }

/// Navigation phase to suppress BGM during transitions.
enum NavigationPhase { idle, transitioning }

/// Single global snapshot of audio-relevant facts (no derived fields).
class AudioState {
  final AppLifecycle appLifecycle;
  final RouteContext routeContext;
  final NavigationPhase navigationPhase;
  final bool menuReady; // relevant only for routeContext=menu
  final bool challengeActive; // relevant only for routeContext=gameplay
  final bool musicEnabled; // user setting
  final bool sfxEnabled; // user setting

  const AudioState({
    required this.appLifecycle,
    required this.routeContext,
    required this.navigationPhase,
    required this.menuReady,
    required this.challengeActive,
    required this.musicEnabled,
    required this.sfxEnabled,
  });
}

// -----------------------------
// Output model (AudioIntent)
// -----------------------------

/// Background music kind.
enum BgmKind { menu, gameplay, none }

/// What to do with BGM right now.
enum BgmAction { play, pause }

/// Looping policy for BGM.
enum LoopKind { one, sequence, na }

/// Sound effects policy for the current state.
enum SfxPolicy { allowed, blocked }

/// Pure output describing what should happen with audio for a given state.
class AudioIntent {
  final BgmKind bgm;
  final BgmAction bgmAction;
  final LoopKind loop;
  final SfxPolicy sfx;

  const AudioIntent({
    required this.bgm,
    required this.bgmAction,
    required this.loop,
    required this.sfx,
  });
}

// -----------------------------
// Resolver
// -----------------------------

/// Pure, deterministic mapping from AudioState to AudioIntent.
///
/// The ordered rules exactly follow the previously defined specification.
AudioIntent resolve(AudioState s) {
  // Helper: Global SFX rule — allowed iff sfxEnabled AND foreground
  final SfxPolicy sfxPolicy =
      (s.sfxEnabled && s.appLifecycle == AppLifecycle.foreground)
          ? SfxPolicy.allowed
          : SfxPolicy.blocked;

  // Rule 1. If appLifecycle ∈ {background, inactive} → pause BGM, block SFX
  if (s.appLifecycle == AppLifecycle.background ||
      s.appLifecycle == AppLifecycle.inactive) {
    return const AudioIntent(
      bgm: BgmKind.none,
      bgmAction: BgmAction.pause,
      loop: LoopKind.na,
      sfx: SfxPolicy.blocked,
    );
  }

  // Rule 2. If navigationPhase = transitioning → pause BGM, SFX per global rule
  if (s.navigationPhase == NavigationPhase.transitioning) {
    return AudioIntent(
      bgm: BgmKind.none,
      bgmAction: BgmAction.pause,
      loop: LoopKind.na,
      sfx: sfxPolicy,
    );
  }

  // Rule 3. If musicEnabled = false → pause BGM, SFX per global rule
  if (!s.musicEnabled) {
    return AudioIntent(
      bgm: BgmKind.none,
      bgmAction: BgmAction.pause,
      loop: LoopKind.na,
      sfx: sfxPolicy,
    );
  }

  // Rule 4. Route-specific BGM selection (foreground, idle, musicEnabled=true)
  // 4.a routeContext = menu
  if (s.routeContext == RouteContext.menu) {
    if (s.menuReady) {
      return AudioIntent(
        bgm: BgmKind.menu,
        bgmAction: BgmAction.play,
        loop: LoopKind.one,
        sfx: sfxPolicy,
      );
    } else {
      return AudioIntent(
        bgm: BgmKind.none,
        bgmAction: BgmAction.pause,
        loop: LoopKind.na,
        sfx: sfxPolicy,
      );
    }
  }

  // 4.b routeContext = gameplay
  if (s.routeContext == RouteContext.gameplay) {
    if (s.challengeActive) {
      return AudioIntent(
        bgm: BgmKind.gameplay,
        bgmAction: BgmAction.play,
        loop: LoopKind.sequence,
        sfx: sfxPolicy,
      );
    } else {
      return AudioIntent(
        bgm: BgmKind.none,
        bgmAction: BgmAction.pause,
        loop: LoopKind.na,
        sfx: sfxPolicy,
      );
    }
  }

  // 4.c routeContext = other → no BGM
  return AudioIntent(
    bgm: BgmKind.none,
    bgmAction: BgmAction.pause,
    loop: LoopKind.na,
    sfx: sfxPolicy,
  );
}
