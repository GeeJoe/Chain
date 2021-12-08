import 'package:chain/box.dart';
import 'package:chain/node.dart';
import 'package:chain/veiwmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => GameViewModel(),
    child: const MaterialApp(home: MyGame()),
  ));
}

class MyGame extends StatefulWidget {
  const MyGame({Key? key}) : super(key: key);

  @override
  State<MyGame> createState() => _MyGameState();
}

class _MyGameState extends State<MyGame> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<GameViewModel>(context, listen: false).newGame(
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height,
                GameInfo(column: 6, row: 8),
              );
            },
            child: const Text(
              "重新开始",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Provider.of<GameViewModel>(context, listen: false).testFall();
            },
            child: const Text(
              "调试下降",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onPanUpdate: (updateDetail) {
          Provider.of<GameViewModel>(context, listen: false)
              .updatePointer(updateDetail.localPosition);
        },
        onPanEnd: (_) {
          Provider.of<GameViewModel>(context, listen: false)
            ..updatePointer(null)
            ..endPointer();
        },
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Center(
              child: Selector<GameViewModel, List<Node>>(
                selector: (context, viewModel) =>
                    viewModel.allNode.values.toList(),
                builder: (BuildContext context, allNode, Widget? child) {
                  debugPrint("new pad");
                  var pad = allNode
                      .map((e) => Box(
                            e,
                            key: ValueKey(e.id),
                          ))
                      .toList();
                  return Stack(
                    children: [
                      Container(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        color: Colors.blue[200],
                      ),
                      ...pad,
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
