import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../logic/game_controller.dart';
import '../../models/campaign_level.dart';
import '../../models/game_outcome.dart';
import '../pages/game_page.dart';

enum CampaignLevelStatus { locked, available, passed, failed }

class CampaignController extends ChangeNotifier {
  static const String _kCampaignProgress = 'campaign_progress';
  final List<CampaignLevel> _levels;
  final Map<int, CampaignLevelStatus> _statusByLevel =
      <int, CampaignLevelStatus>{};

  CampaignController({List<CampaignLevel>? levels})
      : _levels = List<CampaignLevel>.from(levels ?? campaignLevels) {
    for (final level in _levels) {
      _statusByLevel[level.index] = CampaignLevelStatus.locked;
    }
    if (_levels.isNotEmpty) {
      _statusByLevel[_levels.first.index] = CampaignLevelStatus.available;
    }
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCampaignProgress);
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
    notifyListeners();
  }

  List<CampaignLevel> get levels => List<CampaignLevel>.unmodifiable(_levels);

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
    if (statusForLevel(level.index) == CampaignLevelStatus.locked) return;
    final page = GamePage(
      controller: gameController,
      challengeConfig: level,
      onGameCompleted: (outcome) => _handleLevelOutcome(
        context: context,
        gameController: gameController,
        level: level,
        outcome: outcome,
      ),
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
  }) {
    if (!context.mounted) return;
    if (outcome == GameOutcome.win) {
      _statusByLevel[level.index] = CampaignLevelStatus.passed;
      final nextLevel = _nextLevel(level);
      if (nextLevel != null &&
          statusForLevel(nextLevel.index) == CampaignLevelStatus.locked) {
        _statusByLevel[nextLevel.index] = CampaignLevelStatus.available;
      }
      _persistProgress();
      notifyListeners();
      if (nextLevel != null) {
        launchLevel(
          context: context,
          gameController: gameController,
          level: nextLevel,
          replace: true,
        );
      } else {
        Navigator.of(context).pop();
      }
    } else {
      _statusByLevel[level.index] = CampaignLevelStatus.failed;
      _persistProgress();
      notifyListeners();
      launchLevel(
        context: context,
        gameController: gameController,
        level: level,
        replace: true,
      );
    }
  }

  CampaignLevel? _nextLevel(CampaignLevel current) {
    final idx = _levels.indexWhere((level) => level.index == current.index);
    if (idx == -1 || idx + 1 >= _levels.length) return null;
    return _levels[idx + 1];
  }

  Future<void> _persistProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, String>{};
    _statusByLevel.forEach((index, status) {
      payload[index.toString()] = status.name;
    });
    await prefs.setString(_kCampaignProgress, jsonEncode(payload));
  }
}
