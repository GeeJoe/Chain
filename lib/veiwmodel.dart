import 'dart:math';

import 'package:chain/box.dart';
import 'package:chain/model/game_level.dart';
import 'package:chain/model/game_status.dart';
import 'package:chain/model/node.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GameViewModel extends ChangeNotifier {
  /// 表示手指触摸屏幕的位置
  Offset? pointer;

  /// 表示被链接起来的结点
  List<Node> chain = [];

  /// 表示当前游戏所有结点
  Map<Offset, Node> allNode = {};

  /// 游戏等级信息
  GameLevel gameLevel = GameLevel(
      level: 1,
      containerSize: const Size(double.infinity, double.infinity),
      boxSpace: 5);

  /// 游戏状态
  GameStatus gameStatus = GameStatus();

  /// 重新开始游戏
  restart() {
    startLevel(gameLevel);
  }

  /// 开始新游戏
  startLevel(GameLevel gameLevel) {
    debugPrint("newLevel gameLevel=$gameLevel");
    this.gameLevel = gameLevel;
    for (int y = 0; y < gameLevel.row; y++) {
      for (int x = 0; x < gameLevel.column; x++) {
        Offset coordinate = Offset(x.toDouble(), y.toDouble());
        allNode[coordinate] = Node.random(gameLevel, coordinate);
      }
    }

    gameStatus = GameStatus(
      gameOver: false,
      level: gameLevel,
      curMaxValue: _calculateCurrentMaxValue(),
    );

    notifyListeners();
  }

  /// 当手指滑动的时候触发更新
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
      chain.add(node);
      debugPrint("tryPutInChain node=$node");
      notifyListeners();
      return;
    }
    if (chain.last.canChain(node)) {
      chain.add(node);
      debugPrint("tryPutInChain node=$node");
      notifyListeners();
      return;
    }
  }

  /// 手指离开屏幕的时候更新
  endPointer() async {
    // 没有链什么都不用处理
    if (chain.isEmpty) {
      return;
    }
    // 链长小于 3，不得分，但是要清空链
    if (chain.length < 3) {
      chain.clear();
      notifyListeners();
      return;
    }
    // 走到这里说明可以得分

    // 除链尾之外，将所有链中其余结点标记为 dead
    for (var chainedNode in chain.take(chain.length - 1)) {
      Node deadNode = Node.dead(chainedNode);
      allNode[deadNode.coordinate] = deadNode;
    }

    notifyListeners();

    await Future.delayed(AnimationConfig.intervalDuration);

    // 将链尾结点 value 更新为链中结点的 merge 值
    // 每三个就合成下一个数，不足三个不忽略
    Node lastChainedNode = chain.last;
    Node mergeNode =
        Node.merge(lastChainedNode, chain.length ~/ 3 + lastChainedNode.value);
    allNode[mergeNode.coordinate] = mergeNode;

    chain.clear();
    notifyListeners();

    await Future.delayed(AnimationConfig.popDuration);

    // 所有空位上面的结点下降
    Map<Offset, Node> newAllNode = {};
    for (var node in allNode.values) {
      var nodesBelow = allNode.values.findAllNodeBelow(node);
      // 计算出当前结点要下降几格
      var chainedNodeCountBelow = nodesBelow.countWhere((n) => n.isDead());
      Node newNode = Node.fall(node, chainedNodeCountBelow);
      if (newNode.alive) {
        newAllNode[newNode.coordinate] = newNode;
      }
    }
    allNode = newAllNode;
    _createNewNodeOnEmptySpace();
    notifyListeners();

    await Future.delayed(AnimationConfig.intervalDuration);

    _rebirthAllDeadNode();
    notifyListeners();

    await Future.delayed(AnimationConfig.intervalDuration);

    var maxValue = _calculateCurrentMaxValue();

    if (maxValue >= gameLevel.nextLevelValue) {
      gameLevel = GameLevel.levelUp(gameLevel);
      // 超过最大等级
      if (gameLevel.level > GameLevel.maxLevel) {
        debugPrint("reach max level !!!!!!!1");
      }
      debugPrint("level up -> $gameLevel");
      startLevel(gameLevel);
      return;
    }

    gameStatus = GameStatus(
      gameOver: _getGameOver(),
      curMaxValue: maxValue,
      level: gameStatus.level,
    );
    notifyListeners();
  }

  _createNewNodeOnEmptySpace() {
    debugPrint("createNewNodeOnEmptySpace");
    for (int indexX = 0; indexX < gameLevel.column; indexX++) {
      for (int indexY = 0; indexY < gameLevel.row; indexY++) {
        Offset coordinate = Offset(indexX.toDouble(), indexY.toDouble());
        if (allNode[coordinate] == null) {
          allNode[coordinate] =
              Node.random(gameLevel, coordinate, alive: false);
          debugPrint("new Node at $coordinate");
        }
      }
    }
  }

  _rebirthAllDeadNode() {
    debugPrint("rebirthAllDeadNode");
    allNode.forEach((coordinate, node) {
      if (node.isDead()) {
        allNode[coordinate] = Node.rebirth(node);
      }
    });
  }

  bool _getGameOver() {
    for (var node in allNode.values) {
      debugPrint("--------------- check current Node -> $node ---------------");
      if (_neighborCanChain(node, [])) {
        return false;
      }
    }
    return true;
  }

  _calculateCurrentMaxValue() {
    int maxValue = 0;
    for (var node in allNode.values) {
      maxValue = max(maxValue, node.value);
    }
    debugPrint("calculateCurrentMaxValue -> $maxValue");
    return maxValue;
  }

  /// 判断结点 [node] 和周围的结点能否链
  bool _neighborCanChain(Node node, List<Node> chain) {
    debugPrint("add to chain -> $node");
    chain.add(node);
    if (chain.length > 2) return true;
    for (int x = -1; x < 2; x++) {
      for (int y = -1; y < 2; y++) {
        if (!(x == 0 && y == 0)) {
          double dx = node.coordinate.dx + x;
          double dy = node.coordinate.dy + y;
          Node? neighbor = allNode[Offset(dx, dy)];
          if (neighbor != null &&
              neighbor.hasSameValue(node) &&
              !chain.contains(neighbor)) {
            return _neighborCanChain(neighbor, chain);
          }
        }
      }
    }
    return false;
  }

  testGameOver() {
    bool over = _getGameOver();
    debugPrint("testGameOver -> $over");
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
