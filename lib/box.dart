import 'package:chain/model/node.dart';
import 'package:chain/veiwmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class AnimationConfig {
  static Duration fallDuration = const Duration(milliseconds: 300);
  static Duration popDuration = const Duration(milliseconds: 300);
  static Duration intervalDuration = const Duration(milliseconds: 100);
}

class Box extends StatelessWidget {
  final Node node;

  const Box(
    this.node, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: AnimationConfig.fallDuration,
      curve: Curves.easeInOutBack,
      left: node.position.dx,
      top: node.position.dy,
      child: Selector<GameViewModel, List<Node>>(
        selector: (context, viewModel) => viewModel.chain,
        builder: (BuildContext context, chain, Widget? child) {
          return AnimatedScale(
            duration: AnimationConfig.popDuration,
            curve: Curves.easeInOutBack,
            scale: node.merge
                ? 1.05
                : node.alive
                    ? 1
                    : 0,
            child: AnimatedContainer(
              duration: AnimationConfig.intervalDuration,
              curve: Curves.easeInOutBack,
              width: node.size.width,
              height: node.size.height,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                border: chain.contains(node)
                    ? Border.all(color: Colors.yellow, width: 4)
                    : null,
                color: node.merge ? Colors.orange[300] : Colors.orange[200],
              ),
              child: child!,
            ),
          );
        },
        child: Center(
          child: Text(
            "${node.value}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
