import 'adjacency.dart';
import 'infection_resolution.dart';

/// Central gameplay rules configuration shared across logic, UI, and AI.
/// Defaults preserve legacy gameplay: neutralIntermediary × orthogonal4.
class GameRulesConfig {
  InfectionResolutionMode resolutionMode;
  InfectionAdjacencyMode adjacencyMode;

  GameRulesConfig({
    this.resolutionMode = InfectionResolutionMode.neutralIntermediary,
    this.adjacencyMode = InfectionAdjacencyMode.orthogonal4,
  });

  static GameRulesConfig current = GameRulesConfig();

  // Persistence helpers (store as short strings for stability)
  static const String _resNeutral = 'neutral';
  static const String _resDirect = 'direct';
  static const String _adjOrtho4 = 'orthogonal4';
  static const String _adjOrthoDiag8 = 'orthogonalPlusDiagonal8';

  static InfectionResolutionMode parseResolution(String? s) {
    switch (s) {
      case _resDirect:
        return InfectionResolutionMode.directTransfer;
      case _resNeutral:
      default:
        return InfectionResolutionMode.neutralIntermediary;
    }
  }

  static String encodeResolution(InfectionResolutionMode mode) {
    switch (mode) {
      case InfectionResolutionMode.directTransfer:
        return _resDirect;
      case InfectionResolutionMode.neutralIntermediary:
      default:
        return _resNeutral;
    }
  }

  static InfectionAdjacencyMode parseAdjacency(String? s) {
    switch (s) {
      case _adjOrthoDiag8:
        return InfectionAdjacencyMode.orthogonalPlusDiagonal8;
      case _adjOrtho4:
      default:
        return InfectionAdjacencyMode.orthogonal4;
    }
  }

  static String encodeAdjacency(InfectionAdjacencyMode mode) {
    switch (mode) {
      case InfectionAdjacencyMode.orthogonalPlusDiagonal8:
        return _adjOrthoDiag8;
      case InfectionAdjacencyMode.orthogonal4:
      default:
        return _adjOrtho4;
    }
  }
}
