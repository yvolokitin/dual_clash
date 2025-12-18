import 'dart:convert';
import '../models/cell_state.dart';

class GameResult {
  final int timestampMs; // epoch ms
  final int redBase;
  final int blueBase;
  final int bonusRed;
  final int bonusBlue;
  final int redTotal;
  final int blueTotal;
  final String winner; // 'red' | 'blue' | 'draw'
  final int aiLevel;
  final int turnsRed;
  final int turnsBlue;
  // Total active play time for this game, in milliseconds
  final int playMs;

  const GameResult({
    required this.timestampMs,
    required this.redBase,
    required this.blueBase,
    required this.bonusRed,
    required this.bonusBlue,
    required this.redTotal,
    required this.blueTotal,
    required this.winner,
    required this.aiLevel,
    required this.turnsRed,
    required this.turnsBlue,
    required this.playMs,
  });

  factory GameResult.fromMap(Map<String, dynamic> map) {
    return GameResult(
      timestampMs: map['ts'] as int,
      redBase: map['rb'] as int,
      blueBase: map['bb'] as int,
      bonusRed: map['br'] as int,
      bonusBlue: map['bbn'] as int,
      redTotal: map['rt'] as int,
      blueTotal: map['bt'] as int,
      winner: map['w'] as String,
      aiLevel: map['ai'] as int,
      turnsRed: map['tr'] as int,
      turnsBlue: map['tb'] as int,
      playMs: (map['pm'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'ts': timestampMs,
        'rb': redBase,
        'bb': blueBase,
        'br': bonusRed,
        'bbn': bonusBlue,
        'rt': redTotal,
        'bt': blueTotal,
        'w': winner,
        'ai': aiLevel,
        'tr': turnsRed,
        'tb': turnsBlue,
        'pm': playMs,
      };

  static String encodeList(List<GameResult> list) => jsonEncode(list.map((e) => e.toMap()).toList());
  static List<GameResult> decodeList(String jsonStr) {
    final raw = jsonDecode(jsonStr) as List<dynamic>;
    return raw.map((e) => GameResult.fromMap(e as Map<String, dynamic>)).toList();
  }

  static String winnerFromTotals(int redTotal, int blueTotal) {
    if (redTotal == blueTotal) return 'draw';
    return redTotal > blueTotal ? 'red' : 'blue';
  }
}
