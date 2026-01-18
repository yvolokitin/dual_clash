# Campaign UX Flow

This document describes the player-facing UX for Campaign progression: the one-time Intro per campaign, the Completion experience after level 29, and the related soft (cosmetic) rewards. It complements the gameplay/difficulty specs without changing rules or balance.

## Goals
- Make campaign progress and completion emotionally clear and rewarding.
- Do not change gameplay rules, difficulty balance, or add new achievements beyond the 3 campaign achievements.

## Overview
Each campaign (Buddha, Ganesha, Shiva) has:
- A one-time Intro dialog shown when the player opens the campaign for the first time.
- A Completion dialog shown after winning level 29.
- A soft cosmetic reward (non-gameplay) that can be equipped by the player.

## One‑Time Campaign Intro
- Trigger: When the user navigates to a campaign for the first time (initial open, restore of last visited campaign, or on page switch to that campaign).
- Storage: A per-campaign SharedPreferences boolean flag `campaign_intro_shown_<campaignId>` prevents showing more than once.
- Presentation: A themed dialog with 2–3 lines describing the campaign’s philosophy.

Descriptions:
- Buddha — Calm Control
  - Calm, balance, precision. Gray cells buffer infections; no diagonals.
  - Be patient, read the board, and steer the flow.
- Ganesha — Clever Paths
  - Obstacles and asymmetric layouts demand foresight.
  - Bombs are tools to unlock paths — plan 2–3 moves ahead.
- Shiva — Destruction & Pressure
  - Direct capture, no gray cells. Bombs are core and the AI is ruthless.
  - Strike decisively and manage the chaos.

Implementation:
- File: `lib/ui/dialogs/campaign_intro_dialog.dart` (function `showCampaignIntroDialog`).
- Wired from `CampaignPage`:
  - Shows on first entry for the currently selected unlocked campaign.
  - Shows on page change when switching to another unlocked campaign (first time only).
  - Uses `SharedPreferences` to persist the flag.

## Campaign Completion (Level 29)
- Trigger: After winning the final level (29) of a campaign.
- Achievement unlock: The campaign achievement is unlocked immediately upon detecting the final level win, before any UI is shown.
  - ACH_BUDDHA when completing Buddha 29
  - ACH_GANESHA when completing Ganesha 29
  - ACH_SHIVA when completing Shiva 29
  - Stored in `SharedPreferences` under the `campaign_achievements` map (idempotent).
- Presentation: A dedicated “Campaign Complete” dialog including:
  - Campaign name
  - Achievement id display
  - Themed icon
  - Short closing message
  - Primary action: “Equip Reward” (to equip the cosmetic)
  - Secondary action: Close

Implementation:
- Unlocking logic placed in `CampaignController` immediately after recording a win on the last level.
- After unlock, the soft reward is granted (idempotent), then the completion dialog is shown.
- File: `lib/ui/dialogs/campaign_complete_dialog.dart` (function `showCampaignCompleteDialog`).

## Soft Rewards (Non‑Gameplay Cosmetics)
- Rewards are visual cosmetics only — no gameplay effects:
  - Buddha → `frame_buddha`
  - Ganesha → `frame_ganesha`
  - Shiva → `frame_shiva`
- Granting/equipping:
  - Granted upon campaign completion (idempotent).
  - If the player taps “Equip Reward” on the completion dialog, the cosmetic is equipped.
  - Persistence handled by `GameController` (owned list + active selection kept in `SharedPreferences`).

## Validation Checklist
- Intro shows exactly once per campaign per profile/device.
- Completion dialog appears only after final level victory and only after the achievement has been unlocked.
- Soft rewards are granted once and can be equipped; they persist across sessions.
- No gameplay rules, balance, or achievements were modified beyond the display/UX.

## Files & Touchpoints
- Intro Dialog: `lib/ui/dialogs/campaign_intro_dialog.dart`
- Completion Dialog: `lib/ui/dialogs/campaign_complete_dialog.dart`
- Campaign Page (wiring): `lib/ui/pages/campaign_page.dart`
- Campaign Controller (completion flow): `lib/ui/controllers/campaign_controller.dart`
- Cosmetics persistence: `lib/logic/game_controller.dart`
