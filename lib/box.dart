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
      child: Selector<GameViewModel, bool>(
        selector: (context, viewModel) => viewModel.chain.contains(node),
        builder: (BuildContext context, selected, Widget? child) {
          int level = Provider.of<GameViewModel>(context, listen: false)
              .gameLevel
              .level;
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
                border: selected
                    ? Border.all(color: Colors.yellow, width: 4)
                    : null,
                color: node.merge
                    ? Colors.orange[900]
                    : _colorByValue(level, node.value),
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

final List<Color?> _colors = [
  Colors.orange[50],
  Colors.orange[100],
  Colors.orange[200],
  Colors.orange[300],
  Colors.orange[400],
  Colors.orange[500],
  Colors.orange[600],
  Colors.orange[700],
  Colors.orange[800],
  Colors.orange[900],
  Colors.blue[50],
  Colors.blue[100],
  Colors.blue[200],
  Colors.blue[300],
  Colors.blue[400],
  Colors.blue[500],
  Colors.blue[600],
  Colors.blue[700],
  Colors.blue[800],
  Colors.blue[900],
  Colors.purple[600],
  Colors.purple[700],
  Colors.purple[800],
  Colors.purple[900],
];

Color? _colorByValue(int level, int value) {
  int index = value - (level - 1) * 2;
  return _colors[index];
}
