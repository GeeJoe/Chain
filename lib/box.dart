import 'package:chain/node.dart';
import 'package:chain/veiwmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class Box extends StatelessWidget {
  final Node node;

  const Box(
    this.node, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(microseconds: 500),
      left: node.position.dx,
      top: node.position.dy,
      child: SizedBox.fromSize(
        size: node.size,
        child: Selector<GameViewModel, List<Node>>(
          selector: (context, viewModel) => viewModel.chain,
          builder: (BuildContext context, chain, Widget? child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                border: chain.contains(node)
                    ? Border.all(color: Colors.yellow, width: 4)
                    : null,
                color: Colors.orange[200],
              ),
              child: child!,
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
      ),
    );
  }
}
