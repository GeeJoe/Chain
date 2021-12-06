import 'dart:math';

import 'package:chain/node.dart';
import 'package:flutter/cupertino.dart';

class GameViewModel extends ChangeNotifier {
  Offset? pointer;

  List<Node> chain = [];
  List<Node> allNode = [];

  newGame(double parentMaxWidth, double parentMaxHeight, int column, int row) {
    double space = 5;
    double maxContainerWidth = parentMaxWidth * 0.8;
    double maxContainerHeight = parentMaxHeight * 0.8;

    double horizontalSpace = (column - 1) * space;
    double verticalSpace = (row - 1) * space;

    double boxSize = (maxContainerWidth - horizontalSpace) / column;
    double startX = (parentMaxWidth - maxContainerWidth) / 2;
    double startY = ((parentMaxHeight - maxContainerHeight) / 2) +
        ((maxContainerHeight - (row * boxSize) - verticalSpace) / 2);

    List<Node> nodes = [];
    for (int y = 0; y < row; y++) {
      for (int x = 0; x < column; x++) {
        double boxX = startX + (x * boxSize) + (x * space);
        double boxY = startY + (y * boxSize) + (y * space);
        int value = Random().nextInt(3);
        nodes.add(Node(
          position: Offset(boxX, boxY),
          indexX: x,
          indexY: y,
          value: value,
          size: Size.square(boxSize),
        ));
      }
    }

    allNode = nodes.reversed.toList();
    notifyListeners();
  }

  updatePointer(Offset? pointer) {
    this.pointer = pointer;
    for (var node in allNode) {
      if (node.isPointerIn(pointer)) {
        _tryPutInChain(node);
      }
    }
    // 如果手指回到链中某个结点，则将该结点之后的结点回收
    if (chain.length > 1) {
      for (var i = 0; i < chain.length - 1; i++) {
        if (chain[i].isPointerIn(pointer)) {
          _removeChainAfterIndex(i);
        }
      }
    }
  }

  _removeChainAfterIndex(int index) {
    chain = chain.sublist(0, index + 1);
    debugPrint("removeChainAfterIndex, index=$index, chain=$chain");
    notifyListeners();
  }

  _tryPutInChain(Node node) {
    if (chain.contains(node)) {
      return;
    }
    // 如果链为空，则添加当前结点为链头
    if (chain.isEmpty) {
      chain = [node];
      debugPrint("tryPutInChain node=$node");
      notifyListeners();
      return;
    }
    if (chain.last.canChain(node)) {
      chain = [...chain, node];
      debugPrint("tryPutInChain node=$node");
      notifyListeners();
      return;
    }
  }

  endPointer() {
    // 没有链什么都不用处理
    if (chain.isEmpty) {
      return;
    }
    // 链长小于 3，不得分，但是要清空链
    if (chain.length < 3) {
      chain = [];
      notifyListeners();
      return;
    }
    // 走到这里说明可以得分

    // kill all chained box
    for (Node node in chain) {
      allNode.replace(node, node.kill());
    }
    for (Node node in allNode) {
      var fallStep =
          chain.countWhere((element) => element.indexX == node.indexX);
      allNode.replace(node, node.fall(fallStep, allNode));
    }
    // fall all upper box
    chain = [];
    notifyListeners();
  }
}

extension NodesUtil on List<Node> {
  replace(Node oldNode, Node newNode) {
    int oldIndex = indexWhere((element) =>
        element.indexX == oldNode.indexX && element.indexY == oldNode.indexY);
    this[oldIndex] = newNode;
  }

  int countWhere(bool Function(Node node) where) {
    int count = 0;
    forEach((element) {
      if (where(element)) {
        count++;
      }
    });
    return count;
  }
}

extension Util on Node {
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
    var absX = (indexX - node.indexX).abs();
    var absY = (indexY - node.indexY).abs();
    return absX < 2 && absY < 2;
  }

  bool hasSameValue(Node node) {
    return value == node.value;
  }

  /// 如果结点值一样, 且是邻居，可以入链
  bool canChain(Node node) {
    return isNeighbor(node) && hasSameValue(node);
  }
}
