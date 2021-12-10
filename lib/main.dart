import 'package:chain/box.dart';
import 'package:chain/model/game_level.dart';
import 'package:chain/model/game_status.dart';
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
  GameViewModel? gameViewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gameViewModel = Provider.of<GameViewModel>(context, listen: false);
    if (this.gameViewModel != gameViewModel) {
      this.gameViewModel = gameViewModel;

      GameLevel gameLevel =
          GameLevel(level: 1, containerSize: MediaQuery.of(context).size);
      gameViewModel.startLevel(gameLevel);
    }
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
          selector: (context, viewModel) => viewModel.gameStatus.gameOver,
          builder: (BuildContext context, gameOver, Widget? child) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: gameOver ? Colors.red[200] : Colors.blue[200],
              child: child!,
            );
          },
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
                      Selector<GameViewModel, bool>(
                        selector: (context, viewModel) =>
                            viewModel.gameStatus.gameOver,
                        builder:
                            (BuildContext context, gameOver, Widget? child) {
                          return gameOver
                              ? const Align(
                                  alignment: AlignmentDirectional.center,
                                  child: Text(
                                    "Game Over",
                                    style: TextStyle(fontSize: 30),
                                  ),
                                )
                              : const SizedBox();
                        },
                      ),
                      child!,
                    ],
                  );
                },
                child: Align(
                  alignment: AlignmentDirectional.topCenter,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.red[200],
                    child: Selector<GameViewModel, GameStatus>(
                      selector: (context, viewModel) => viewModel.gameStatus,
                      builder:
                          (BuildContext context, gameStatus, Widget? child) {
                        return Row(
                          children: [
                            Text(
                              "Level: ${gameStatus.level?.level}",
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey[200]),
                            ),
                            const SizedBox.square(dimension: 10),
                            Text(
                              "Max Value: ${gameStatus.curMaxValue}",
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey[200]),
                            ),
                            const SizedBox.square(dimension: 10),
                            Text(
                              "Goal Value: ${gameStatus.level?.nextLevelValue}",
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey[200]),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
