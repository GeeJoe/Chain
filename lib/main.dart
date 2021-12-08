import 'package:chain/box.dart';
import 'package:chain/model/game_info.dart';
import 'package:chain/model/node.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    GameInfo gameInfo =
        GameInfo(level: 1, containerSize: MediaQuery.of(context).size);
    Provider.of<GameViewModel>(context, listen: false).newGame(gameInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () =>
                Provider.of<GameViewModel>(context, listen: false).restart(),
            child: const Text(
              "重新开始",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Provider.of<GameViewModel>(context, listen: false)
                .testGameOver(),
            child: const Text(
              "测试",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Selector<GameViewModel, bool>(
          selector: (context, viewModel) => viewModel.gameOver,
          builder: (BuildContext context, gameOver, Widget? child) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: gameOver ? Colors.red[200] : Colors.blue[200],
              child: GestureDetector(
                onPanUpdate: (updateDetail) {
                  Provider.of<GameViewModel>(context, listen: false)
                      .updatePointer(updateDetail.localPosition);
                },
                onPanEnd: (_) {
                  Provider.of<GameViewModel>(context, listen: false)
                    ..updatePointer(null)
                    ..endPointer();
                },
                child: Selector<GameViewModel, List<Node>>(
                  selector: (context, viewModel) =>
                      viewModel.allNode.values.toList(),
                  builder: (BuildContext context, allNode, Widget? child) {
                    debugPrint("new pad");
                    return Stack(
                      children: [
                        ...allNode.map((e) => Box(
                              e,
                              key: ValueKey(e.id),
                            )),
                        gameOver
                            ? const Align(
                                alignment: AlignmentDirectional.center,
                                child: Text(
                                  "Game Over",
                                  style: TextStyle(fontSize: 30),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
