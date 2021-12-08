import 'dart:math';

import 'package:chain/model/game_info.dart';
import 'package:chain/model/node.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GameViewModel extends ChangeNotifier {
  Offset? pointer;

  List<Node> chain = [];
  Map<Offset, Node> allNode = {};
  final Map<int, int> _columnEmptyCount = {}; // 记录每列头部有多少空位
  GameInfo gameInfo = GameInfo.empty();

  /// 开始新游戏
  newGame(GameInfo gameInfo) {
    this.gameInfo = gameInfo;
    Map<Offset, Node> nodes = {};
    for (int y = 0; y < gameInfo.row; y++) {
      for (int x = 0; x < gameInfo.column; x++) {
        Offset coordinate = Offset(x.toDouble(), y.toDouble());
        nodes[coordinate] = Node.random(gameInfo, coordinate);
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

    // 将链尾结点 value 更新为链中结点的 merge 值
    // 每三个就合成下一个数，不足三个不忽略
    Node lastChainedNode = chain.last;
    Node mergeNode =
        Node.value(lastChainedNode, chain.length ~/ 3 + lastChainedNode.value);
    allNode[mergeNode.coordinate] = mergeNode;

    // 除链尾之后，将所有链中其余结点标记为 dead
    for (var chainedNode in chain.take(chain.length - 1)) {
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
      int indexX = node.coordinate.dx.toInt();
      _columnEmptyCount[indexX] =
          max(_columnEmptyCount[indexX] ?? 0, chainedNodeCountBelow);
      Node newNode = Node.fall(node, chainedNodeCountBelow);
      if (newNode.alive) {
        newAllNode[newNode.coordinate] = newNode;
      }
    }
    allNode = newAllNode;

    chain = [];
    notifyListeners();
  }

  _createNewNodeOnEmptySpace() {
    // _columnEmptyCount.forEach((indexX, emptyCount) {
    //   for (int indexY = 0; indexY < emptyCount; indexY++) {
    //     allNode[Offset(indexX.toDouble(), indexY.toDouble())] = Node(
    //         position: position,
    //         coordinate: coordinate,
    //         value: value,
    //         size: size,
    //         margin: margin);
    //   }
    // });
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
