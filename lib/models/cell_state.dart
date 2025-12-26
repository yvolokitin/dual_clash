enum CellState { empty, red, blue, yellow, green, neutral }

extension CellStateX on CellState {
  bool get isEmpty => this == CellState.empty;
  bool get isRed => this == CellState.red;
  bool get isBlue => this == CellState.blue;
  bool get isYellow => this == CellState.yellow;
  bool get isGreen => this == CellState.green;
  bool get isNeutral => this == CellState.neutral;
}
