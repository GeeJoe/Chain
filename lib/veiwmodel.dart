import 'dart:math';

import 'package:chain/node.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GameInfo {
  int column;
  int row;

  GameInfo({
    required this.column,
    required this.row,
  });
}

class GameViewModel extends ChangeNotifier {
  Offset? pointer;

  List<Node> chain = [];
  Map<Offset, Node> allNode = {};
  GameInfo gameInfo = GameInfo(column: 0, row: 0);

  /// 开始新游戏
  newGame(double parentMaxWidth, double parentMaxHeight, GameInfo gameInfo) {
    this.gameInfo = gameInfo;
    int column = gameInfo.column;
    int row = gameInfo.row;
    debugPrint("newGame, column=$column, row=$row");
    double space = 5;
    double maxContainerWidth = parentMaxWidth * 0.8;
    double maxContainerHeight = parentMaxHeight * 0.8;

    double horizontalSpace = (column - 1) * space;
    double verticalSpace = (row - 1) * space;

    double boxSize = (maxContainerWidth - horizontalSpace) / column;
    double startX = (parentMaxWidth - maxContainerWidth) / 2;
    double startY = ((parentMaxHeight - maxContainerHeight) / 2) +
        ((maxContainerHeight - (row * boxSize) - verticalSpace) / 2);

    Map<Offset, Node> nodes = {};
    for (int y = 0; y < row; y++) {
      for (int x = 0; x < column; x++) {
        double boxX = startX + x * (boxSize + space);
        double boxY = startY + y * (boxSize + space);
        int value = Random().nextInt(3);
        Offset coordinate = Offset(x.toDouble(), y.toDouble());
        nodes[coordinate] = Node(
          position: Offset(boxX, boxY),
          coordinate: coordinate,
          value: value,
          size: Size.square(boxSize),
          margin: EdgeInsets.symmetric(vertical: space, horizontal: space),
        );
      }
    }

    allNode = nodes;
    notifyListeners();
  }

  /// 当手机滑动的时候触发更新
  updatePointer(Offset? pointer) {
    this.pointer = pointer;
    for (var node in allNode.values) {
      // 如果手指触摸到格子里，尝试将格子链起来
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

  /// 将 index 之后的结点从链中移除
  _removeChainAfterIndex(int index) {
    chain = chain.sublist(0, index + 1);
    debugPrint("removeChainAfterIndex, index=$index, chain=$chain");
    notifyListeners();
  }

  /// 尝试将结点链接起来
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

  /// 手指离开屏幕的时候更新
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

    // 将所有链中的结点标记为 dead
    for (var chainedNode in chain) {
      Node deadNode = Node.dead(chainedNode);
      allNode[deadNode.coordinate] = deadNode;
    }

    // 所有空位上面的结点下降
    Map<Offset, Node> newAllNode = {};
    for (var node in allNode.values) {
      var nodesBelow = allNode.values.findAllNodeBelow(node);
      // 计算出当前结点要下降几格
      var chainedNodeCountBelow =
          nodesBelow.countWhere((n) => n.alive == false);
      Node newNode = Node.fall(node, chainedNodeCountBelow);
      if (newNode.alive) {
        newAllNode[newNode.coordinate] = newNode;
      }
    }
    allNode = newAllNode;

    chain = [];
    notifyListeners();
  }

  testFall() {
    Node first = allNode.values.first;
    debugPrint("first Node=$first");
    Node newNode = Node.fall(first, 1);
    allNode.remove(first.coordinate);
    allNode[newNode.coordinate] = newNode;

    notifyListeners();
  }
}

extension NodesUtil on Iterable<Node> {
  /// 计算有多少个符合 [where] 的 item
  int countWhere(bool Function(Node node) where) {
    int count = 0;
    forEach((element) {
      if (where(element)) {
        count++;
      }
    });
    return count;
  }

  /// 返回所有 node 下面的结点
  List<Node> findAllNodeBelow(Node node) {
    List<Node> result = [];
    forEach((element) {
      if (element.coordinate.dx == node.coordinate.dx &&
          element.coordinate.dy > node.coordinate.dy) {
        result.add(element);
      }
    });
    return result;
  }
}
