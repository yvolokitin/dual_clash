import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../logic/game_controller.dart';
import '../../models/campaign_level.dart';
import '../../models/campaign_result_action.dart';
import '../../models/game_outcome.dart';
import '../../models/game_result.dart';
import '../pages/game_page.dart';
import '../dialogs/campaign_complete_dialog.dart';

enum CampaignLevelStatus { locked, available, passed, failed }

class CampaignController extends ChangeNotifier {
  static const String _kCampaignBestResults = 'campaign_best_results';
  static const String _kCampaignResults = 'campaign_results';
  static const String _kCampaignProgress = 'campaign_progress';
  static const String _kCampaignAchievements = 'campaign_achievements';
  static const String _kHighestCompletedPrefix = 'campaign_highest_completed_';
  static const String _kActiveCampaignId = 'activeCampaignId';
  final String campaignId;
  final bool isUnlocked;
  final int totalLevels;
  final List<CampaignLevel> _levels;
  final Map<int, CampaignLevelStatus> _statusByLevel =
      <int, CampaignLevelStatus>{};

  CampaignController({
    required this.campaignId,
    required this.isUnlocked,
    required this.totalLevels,
    List<CampaignLevel>? levels,
  }) : _levels = List<CampaignLevel>.from(levels ?? campaignLevels)
            .take(totalLevels)
            .toList() {
    for (final level in _levels) {
      _statusByLevel[level.index] = CampaignLevelStatus.locked;
    }
    if (_levels.isNotEmpty && isUnlocked) {
      _statusByLevel[_levels.first.index] = CampaignLevelStatus.available;
    }
  }

  Future<void> loadProgress() async {
    if (!isUnlocked) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressKey());
    if (raw == null || raw.isEmpty) return;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return;
    for (final entry in decoded.entries) {
      final levelIndex = int.tryParse(entry.key.toString());
      if (levelIndex == null || !_statusByLevel.containsKey(levelIndex)) {
        continue;
      }
      final statusName = entry.value?.toString();
      final status = CampaignLevelStatus.values
          .firstWhere((value) => value.name == statusName, orElse: () {
        return CampaignLevelStatus.locked;
      });
      _statusByLevel[levelIndex] = status;
    }
    if (_levels.isNotEmpty &&
        !_statusByLevel.values.any((status) =>
            status == CampaignLevelStatus.available ||
            status == CampaignLevelStatus.passed ||
            status == CampaignLevelStatus.failed)) {
      _statusByLevel[_levels.first.index] = CampaignLevelStatus.available;
    }
    await _persistHighestCompletedFromStatus();
    notifyListeners();
  }

  List<CampaignLevel> get levels => List<CampaignLevel>.unmodifiable(_levels);

  String _progressKey() => '${_kCampaignProgress}_$campaignId';

  String _resultsKey() => '${_kCampaignResults}_$campaignId';
  String _bestResultsKey() => '${_kCampaignBestResults}_$campaignId';

  CampaignLevelStatus statusForLevel(int levelIndex) {
    return _statusByLevel[levelIndex] ?? CampaignLevelStatus.locked;
  }

  CampaignLevel? levelForIndex(int levelIndex) {
    for (final level in _levels) {
      if (level.index == levelIndex) return level;
    }
    return null;
  }

  Future<void> launchLevel({
    required BuildContext context,
    required GameController gameController,
    required CampaignLevel level,
    bool replace = false,
  }) async {
    if (!isUnlocked) return;
    if (statusForLevel(level.index) == CampaignLevelStatus.locked) return;
    final page = GamePage(
      controller: gameController,
      challengeConfig: level,
      onCampaignAction: (outcome, action) => _handleLevelOutcome(
        context: context,
        gameController: gameController,
        level: level,
        outcome: outcome,
        action: action,
      ),
      campaignId: campaignId,
      campaignTotalLevels: totalLevels,
    );
    final route = MaterialPageRoute(builder: (_) => page);
    if (replace) {
      await Navigator.of(context).pushReplacement(route);
    } else {
      await Navigator.of(context).push(route);
    }
  }

  void _handleLevelOutcome({
    required BuildContext context,
    required GameController gameController,
    required CampaignLevel level,
    required GameOutcome outcome,
    required CampaignResultAction action,
  }) {
    if (!context.mounted) return;
    final nextLevel = _nextLevel(level);
    if (outcome == GameOutcome.win) {
      _statusByLevel[level.index] = CampaignLevelStatus.passed;
      if (nextLevel != null &&
          statusForLevel(nextLevel.index) == CampaignLevelStatus.locked) {
        _statusByLevel[nextLevel.index] = CampaignLevelStatus.available;
      }
      _persistProgress();
      _recordCampaignWinStats(level.index, gameController);
      // Persist highest completed level (monotonic)
      _persistHighestCompletedIfGreater(level.index);
      // Unlock campaign achievement if this was the final level
      if (nextLevel == null) {
        _unlockCampaignAchievementIfNeeded();
      }
      notifyListeners();
    } else {
      _statusByLevel[level.index] = CampaignLevelStatus.failed;
      _persistProgress();
      notifyListeners();
    }

    if (action == CampaignResultAction.backToCampaign) {
      return;
    }

    if (action == CampaignResultAction.retry) {
      launchLevel(
        context: context,
        gameController: gameController,
        level: level,
        replace: true,
      );
      return;
    }

    if (action == CampaignResultAction.continueNext &&
        outcome == GameOutcome.win) {
      if (nextLevel != null) {
        launchLevel(
          context: context,
          gameController: gameController,
          level: nextLevel,
          replace: true,
        );
      } else {
        // Final level completed: ensure achievement unlock happens before completion screen
        final cosmeticId = _cosmeticIdForCampaign(campaignId);
        _unlockCampaignAchievementIfNeeded().then((_) async {
          // Grant cosmetic reward (idempotent)
          await gameController.grantCosmetic(cosmeticId);
          if (!context.mounted) return;
          // Show completion dialog
          showCampaignCompleteDialog(context: context, campaignId: campaignId).then((result) async {
            if (result == 'equip') {
              await gameController.setActiveCosmetic(cosmeticId);
            }
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          });
        });
      }
    }
  }

  CampaignLevel? _nextLevel(CampaignLevel current) {
    final idx = _levels.indexWhere((level) => level.index == current.index);
    if (idx == -1 || idx + 1 >= _levels.length) return null;
    return _levels[idx + 1];
  }

  Future<GameResult?> latestResultForLevel(int levelIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final decodedRaw = await _loadResultsHistory(prefs);
    if (decodedRaw.isEmpty) return null;
    final entries = decodedRaw[levelIndex.toString()];
    if (entries is! List) return null;
    final results = entries
        .whereType<Map>()
        .map((entry) => GameResult.fromMap(Map<String, dynamic>.from(entry)))
        .toList();
    if (results.isEmpty) return null;
    results.sort((a, b) => b.timestampMs.compareTo(a.timestampMs));
    return results.first;
  }

  Future<GameResult?> bestResultForLevel(int levelIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_bestResultsKey());
    if (raw != null && raw.isNotEmpty) {
      final decodedRaw = jsonDecode(raw);
      if (decodedRaw is Map) {
        final entry = decodedRaw[levelIndex.toString()];
        if (entry is Map) {
          return GameResult.fromMap(Map<String, dynamic>.from(entry));
        }
      }
    }
    final decodedRaw = await _loadResultsHistory(prefs);
    if (decodedRaw.isEmpty) return null;
    final entries = decodedRaw[levelIndex.toString()];
    if (entries is! List) return null;
    final bestFromHistory = _bestResultFromEntries(entries);
    if (bestFromHistory == null) return null;
    await _persistBestResult(levelIndex, bestFromHistory);
    return bestFromHistory;
  }

  Future<void> _persistProgress() async {
    if (!isUnlocked) return;
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, String>{};
    _statusByLevel.forEach((index, status) {
      payload[index.toString()] = status.name;
    });
    await prefs.setString(_progressKey(), jsonEncode(payload));
  }

  Future<void> _recordCampaignWinStats(
    int levelIndex,
    GameController controller,
  ) async {
    if (!isUnlocked) return;
    final prefs = await SharedPreferences.getInstance();
    final decoded = await _loadResultsHistory(prefs);
    final levelKey = levelIndex.toString();
    final List<dynamic> entries =
        (decoded[levelKey] as List<dynamic>?) ?? <dynamic>[];
    final redTotal = controller.scoreRedTotal();
    final blueTotal = controller.scoreBlueTotal();
    final result = GameResult(
      timestampMs: DateTime.now().millisecondsSinceEpoch,
      redBase: controller.scoreRedBase(),
      blueBase: controller.scoreBlueBase(),
      bonusRed: controller.bonusRed,
      bonusBlue: controller.bonusBlue,
      redTotal: redTotal,
      blueTotal: blueTotal,
      winner: GameResult.winnerFromTotals(redTotal, blueTotal),
      aiLevel: controller.aiLevel,
      turnsRed: controller.turnsRed,
      turnsBlue: controller.turnsBlue,
      playMs: controller.lastGamePlayMs,
    );
    entries.add(result.toMap());
    decoded[levelKey] = entries;
    await prefs.setString(_resultsKey(), jsonEncode(decoded));
    await _persistBestResult(levelIndex, result);
  }

  Future<Map<String, dynamic>> _loadResultsHistory(
    SharedPreferences prefs,
  ) async {
    final current = _decodeResults(prefs.getString(_resultsKey()));
    if (current.isNotEmpty) {
      return current;
    }
    final legacy = _decodeResults(prefs.getString(_kCampaignResults));
    if (legacy.isNotEmpty) {
      await prefs.setString(_resultsKey(), jsonEncode(legacy));
    }
    return legacy;
  }

  Map<String, dynamic> _decodeResults(String? raw) {
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return <String, dynamic>{};
    return Map<String, dynamic>.from(decoded);
  }

  Future<void> _persistBestResult(int levelIndex, GameResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_bestResultsKey());
    Map<String, dynamic> decoded = <String, dynamic>{};
    if (raw != null && raw.isNotEmpty) {
      final decodedRaw = jsonDecode(raw);
      if (decodedRaw is Map) {
        decoded = Map<String, dynamic>.from(decodedRaw);
      }
    }
    final levelKey = levelIndex.toString();
    final existing = decoded[levelKey];
    GameResult? currentBest;
    if (existing is Map) {
      currentBest = GameResult.fromMap(Map<String, dynamic>.from(existing));
    }
    final bestResult = _pickBestResult(currentBest, result);
    decoded[levelKey] = bestResult.toMap();
    await prefs.setString(_bestResultsKey(), jsonEncode(decoded));
  }

  GameResult _pickBestResult(GameResult? current, GameResult candidate) {
    if (current == null) return candidate;
    final totalCompare = candidate.redTotal.compareTo(current.redTotal);
    if (totalCompare != 0) {
      return totalCompare > 0 ? candidate : current;
    }
    if (candidate.playMs != current.playMs) {
      return candidate.playMs < current.playMs ? candidate : current;
    }
    return candidate.timestampMs >= current.timestampMs ? candidate : current;
  }

  GameResult? _bestResultFromEntries(List<dynamic> entries) {
    GameResult? best;
    for (final entry in entries.whereType<Map>()) {
      final result = GameResult.fromMap(Map<String, dynamic>.from(entry));
      best = _pickBestResult(best, result);
    }
    return best;
  }

  Future<void> _unlockCampaignAchievementIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCampaignAchievements);
    Map<String, dynamic> decoded = <String, dynamic>{};
    if (raw != null && raw.isNotEmpty) {
      final j = jsonDecode(raw);
      if (j is Map) decoded = Map<String, dynamic>.from(j);
    }
    // Determine achievement id by campaign
    String? achId;
    switch (campaignId) {
      case 'buddha':
        achId = 'ACH_BUDDHA';
        break;
      case 'ganesha':
        achId = 'ACH_GANESHA';
        break;
      case 'shiva':
        achId = 'ACH_SHIVA';
        break;
    }
    if (achId == null) return;
    if (decoded[achId] == true) return; // already unlocked
    decoded[achId] = true;
    await prefs.setString(_kCampaignAchievements, jsonEncode(decoded));
  }

  String _cosmeticIdForCampaign(String id) {
    switch (id) {
      case 'buddha':
        return 'frame_buddha';
      case 'ganesha':
        return 'frame_ganesha';
      case 'shiva':
      default:
        return 'frame_shiva';
    }
  }

  Future<void> _persistHighestCompletedIfGreater(int levelIndex) async {
    if (!isUnlocked) return;
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kHighestCompletedPrefix$campaignId';
    final current = prefs.getInt(key) ?? 0;
    if (levelIndex > current) {
      await prefs.setInt(key, levelIndex);
    }
  }

  Future<void> _persistHighestCompletedFromStatus() async {
    if (!isUnlocked) return;
    int highest = 0;
    for (final level in _levels) {
      if (_statusByLevel[level.index] == CampaignLevelStatus.passed && level.index > highest) {
        highest = level.index;
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kHighestCompletedPrefix$campaignId';
    final current = prefs.getInt(key) ?? 0;
    if (highest > current) {
      await prefs.setInt(key, highest);
    }
  }
}
