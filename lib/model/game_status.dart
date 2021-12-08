class GameStatus {
  final bool gameOver;
  final int curMaxValue;
  final int level;

  GameStatus({
    this.gameOver = false,
    this.curMaxValue = 0,
    this.level = 1,
  });

  @override
  String toString() {
    return 'GameStatus{gameOver: $gameOver, curMaxValue: $curMaxValue, level: $level}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStatus &&
          runtimeType == other.runtimeType &&
          gameOver == other.gameOver &&
          curMaxValue == other.curMaxValue &&
          level == other.level;

  @override
  int get hashCode => gameOver.hashCode ^ curMaxValue.hashCode ^ level.hashCode;
}
