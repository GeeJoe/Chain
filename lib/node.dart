import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

class Node {
  final String id;
  final Offset position;
  final Offset coordinate;
  final int value;
  final Size size;
  final EdgeInsets margin;
  final bool alive;

  Node({
    required this.position,
    required this.coordinate,
    required this.value,
    required this.size,
    required this.margin,
  })  : id = const Uuid().v1(),
        alive = true;

  Node.fall(Node origin, int step)
      : id = origin.id,
        alive = origin.alive,
        value = origin.value,
        size = origin.size,
        margin = origin.margin,
        position = Offset(
            origin.position.dx,
            origin.position.dy +
                (origin.size.height + origin.margin.top) * step),
        coordinate = Offset(origin.coordinate.dx, origin.coordinate.dy + step);

  Node.dead(Node origin)
      : id = origin.id,
        alive = false,
        value = origin.value,
        size = origin.size,
        margin = origin.margin,
        position = origin.position,
        coordinate = origin.coordinate;

  bool isPointerIn(Offset? pointer) {
    if (pointer == null) return false;
    if (pointer.dx >= position.dx &&
        pointer.dx <= position.dx + size.width &&
        pointer.dy >= position.dy &&
        pointer.dy <= position.dy + size.height) {
      return true;
    }
    return false;
  }

  bool isNeighbor(Node node) {
    var absX = (coordinate.dx - node.coordinate.dx).abs();
    var absY = (coordinate.dy - node.coordinate.dy).abs();
    return absX < 2 && absY < 2;
  }

  bool hasSameValue(Node node) {
    return value == node.value;
  }

  /// 如果结点值一样, 且是邻居，可以入链
  bool canChain(Node node) {
    return isNeighbor(node) && hasSameValue(node);
  }

  @override
  String toString() {
    return 'Node{id: $id, position: $position, coordinate: $coordinate, value: $value, size: $size}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          position == other.position &&
          coordinate == other.coordinate &&
          value == other.value &&
          size == other.size;

  @override
  int get hashCode =>
      id.hashCode ^
      position.hashCode ^
      coordinate.hashCode ^
      value.hashCode ^
      size.hashCode;
}
