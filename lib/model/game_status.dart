import 'package:chain/model/game_level.dart';

class GameStatus {
  final bool gameOver;
  final int curMaxValue;
  GameLevel? level;

  GameStatus({
    this.gameOver = false,
    this.curMaxValue = 0,
    this.level,
  });

  @override
  String toString() {
    return 'GameStatus{gameOver: $gameOver, curMaxValue: $curMaxValue, level: ${level?.level}}';
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
