import 'dart:ui';

class GameInfo {
  final int level;
  final Size containerSize;
  final double boxSpace;

  late final int column;
  late final int row;
  late final double boxSize;
  late final Offset startCoordinate;

  GameInfo({
    required this.level,
    required this.containerSize,
    this.boxSpace = 5,
  }) {
    _init();
  }

  GameInfo.empty()
      : level = 0,
        containerSize = Size.zero,
        boxSpace = 0,
        boxSize = 0,
        startCoordinate = Offset.zero;

  _init() {
    switch (level) {
      case 1:
        column = 4;
        row = 4;
        break;
      case 2:
        column = 4;
        row = 6;
        break;
      case 3:
        column = 6;
        row = 6;
        break;
      case 4:
        column = 6;
        row = 8;
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
    return 'GameInfo{level: $level, containerSize: $containerSize, boxSpace: $boxSpace, column: $column, row: $row, boxSize: $boxSize, startCoordinate: $startCoordinate}';
  }
}
