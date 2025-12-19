enum CellState { empty, red, blue, neutral }

extension CellStateX on CellState {
  bool get isEmpty => this == CellState.empty;
  bool get isRed => this == CellState.red;
  bool get isBlue => this == CellState.blue;
  bool get isNeutral => this == CellState.neutral;
}
