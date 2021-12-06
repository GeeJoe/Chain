import 'dart:ui';

class Node {
  final Offset position;
  final int indexX;
  final int indexY;
  final int value;
  final Size size;
  final bool alive;

  Node({
    this.alive = true,
    required this.position,
    required this.value,
    required this.indexX,
    required this.indexY,
    required this.size,
  });

  Node newPosition(Offset position) {
    return Node(
      position: position,
      value: value,
      indexX: indexX,
      indexY: indexY,
      size: size,
    );
  }

  Node kill() {
    return Node(
      alive: false,
      position: position,
      value: value,
      indexX: indexX,
      indexY: indexY,
      size: size,
    );
  }

  Node fall(int step, List<Node> allNode) {
    int newIndexY = indexY + step;
    Node targetNode = allNode.firstWhere(
        (element) => element.indexX == indexX && element.indexY == newIndexY);
    return Node(
      position: targetNode.position,
      value: value,
      indexX: indexX,
      indexY: newIndexY,
      size: size,
    );
  }

  String key() {
    return "$indexX-$indexY-$value";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          indexX == other.indexX &&
          indexY == other.indexY &&
          value == other.value &&
          size == other.size &&
          alive == other.alive;

  @override
  int get hashCode =>
      position.hashCode ^
      indexX.hashCode ^
      indexY.hashCode ^
      value.hashCode ^
      size.hashCode ^
      alive.hashCode;

  @override
  String toString() {
    return 'Node{indexX: $indexX, indexY: $indexY, value: $value, alive: $alive}';
  }
}
