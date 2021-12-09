import 'dart:ui';

/// 游戏等级 1
/// 方块: 3 × 3
/// 随机数值: 0, 1, 2
/// 通关最大数: 4
///
/// 游戏等级 2
/// 方块: 4 × 4
/// 随机数值: 2, 3, 4
/// 通关最大数: 8
///
/// 游戏等级 3
/// 方块: 4 × 6
/// 随机数值: 4, 5, 6
/// 通关最大数: 12
///
/// 游戏等级 4
/// 方块: 6 × 6
/// 随机数值: 6, 7, 8
/// 通关最大数: 16
///
/// 游戏等级 5
/// 方块: 6 × 8
/// 随机数值: 8, 9, 10
/// 通关最大数: 20
///
class GameLevel {
  static const int maxLevel = 5;

  final int level;
  final Size containerSize;
  final double boxSpace;

  late final int column;
  late final int row;
  late final double boxSize;
  late final Offset startCoordinate;
  late final double nextLevelValue;

  GameLevel({
    required this.level,
    required this.containerSize,
    this.boxSpace = 5,
  }) {
    _init();
  }

  GameLevel.levelUp(GameLevel origin)
      : this(
          level: origin.level + 1,
          containerSize: origin.containerSize,
          boxSpace: origin.boxSpace,
        );

  _init() {
    switch (level) {
      case 1:
        column = 3;
        row = 3;
        nextLevelValue = 4;
        break;
      case 2:
        column = 4;
        row = 4;
        nextLevelValue = 8;
        break;
      case 3:
        column = 4;
        row = 6;
        nextLevelValue = 12;
        break;
      case 4:
        column = 6;
        row = 6;
        nextLevelValue = 16;
        break;
      case 5:
        column = 6;
        row = 8;
        nextLevelValue = double.infinity;
        break;
      default:
        column = 0;
        row = 0;
        nextLevelValue = 0;
        break;
    }

    double horizontalSpace = (column - 1) * boxSpace;
    double verticalSpace = (row - 1) * boxSpace;
    double maxContainerWidth = containerSize.width * 0.8;
    double maxContainerHeight = containerSize.height * 0.8;

    boxSize = (maxContainerWidth - horizontalSpace) / column;
    double startX = (containerSize.width - maxContainerWidth) / 2;
    double startY = ((containerSize.height - maxContainerHeight) / 2) +
        ((maxContainerHeight - (row * boxSize) - verticalSpace) / 2);
    startCoordinate = Offset(startX, startY);
  }

  @override
  String toString() {
    return 'GameLevel{level: $level, containerSize: $containerSize, boxSpace: $boxSpace, column: $column, row: $row, boxSize: $boxSize, startCoordinate: $startCoordinate, nextLevelValue: $nextLevelValue}';
  }
}
