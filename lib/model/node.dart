import 'dart:math';
import 'dart:ui';

import 'package:chain/model/game_level.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

class Node {
  final String id;
  final Offset position;
  final Offset coordinate;
  final int value;
  final Size size;
  final double space;
  final bool alive;
  final bool merge;

  Node({
    required this.position,
    required this.coordinate,
    required this.value,
    required this.size,
    required this.space,
  })  : id = const Uuid().v1(),
        alive = true,
        merge = false;

  Node.random(GameLevel gameLevel, this.coordinate, {this.alive = true})
      : id = const Uuid().v1(),
        value = 2 * (gameLevel.level - 1) + Random().nextInt(3),
        size = Size.square(gameLevel.boxSize),
        space = gameLevel.boxSpace,
        position = Offset(
            gameLevel.startCoordinate.dx +
                coordinate.dx * (gameLevel.boxSpace + gameLevel.boxSize),
            gameLevel.startCoordinate.dy +
                coordinate.dy * (gameLevel.boxSpace + gameLevel.boxSize)),
        merge = false;

  Node.merge(Node origin, int newValue)
      : id = origin.id,
        alive = origin.alive,
        value = newValue,
        size = origin.size,
        space = origin.space,
        position = origin.position,
        coordinate = origin.coordinate,
        merge = true;

  Node.fall(Node origin, int step)
      : id = origin.id,
        alive = origin.alive,
        value = origin.value,
        size = origin.size,
        space = origin.space,
        position = Offset(origin.position.dx,
            origin.position.dy + (origin.size.height + origin.space) * step),
        coordinate = Offset(origin.coordinate.dx, origin.coordinate.dy + step),
        merge = false;

  Node.dead(Node origin)
      : id = origin.id,
        alive = false,
        value = origin.value,
        size = origin.size,
        space = origin.space,
        position = origin.position,
        coordinate = origin.coordinate,
        merge = false;

  Node.rebirth(Node origin)
      : id = origin.id,
        alive = true,
        value = origin.value,
        size = origin.size,
        space = origin.space,
        position = origin.position,
        coordinate = origin.coordinate,
        merge = false;

  bool isDead() {
    return alive == false;
  }

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
    return 'Node{$coordinate,$value}';
  }
}
