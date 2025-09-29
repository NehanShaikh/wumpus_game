import 'package:flutter/material.dart';
import '../services/game_logic.dart';

class BoardWidget extends StatelessWidget {
  final GameLogic game;

  BoardWidget({required this.game});

  @override
  Widget build(BuildContext context) {
    int size = game.state.boardSize;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: size,
      ),
      itemCount: size * size,
      itemBuilder: (context, index) {
        int r = index ~/ size;
        int c = index % size;

        bool playerHere =
            game.state.player['r'] == r && game.state.player['c'] == c;
        bool wumpusHere =
            game.state.wumpus['r'] == r && game.state.wumpus['c'] == c;
        bool goldHere = game.state.gold['r'] == r && game.state.gold['c'] == c;
        bool pitHere = game.state.pits.any((p) => p['r'] == r && p['c'] == c);

        // Check adjacency for clues
        bool nearWumpus = _isAdjacent(r, c, game.state.wumpus);
        bool nearPit = game.state.pits.any((p) => _isAdjacent(r, c, p));
        bool nearGold = _isAdjacent(r, c, game.state.gold);

        String content = '';

        if (playerHere)
          content = '😀';
        else if (wumpusHere && (playerHere || nearWumpus))
          content = '👹';
        else if (pitHere && (playerHere || nearPit))
          content = '🕳️';
        else if (goldHere && (playerHere || nearGold || game.state.hasGold))
          content = '💰';
        else if (nearWumpus)
          content = '👃'; // Stench hint
        else if (nearPit)
          content = '💨'; // Breeze hint
        else if (nearGold) content = '✨'; // Glitter hint

        return Container(
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: playerHere ? Colors.green[200] : Colors.grey[200],
          ),
          child: Center(
            child: Text(
              content,
              style: TextStyle(fontSize: 24),
            ),
          ),
        );
      },
    );
  }

  bool _isAdjacent(int r, int c, Map<String, int> cell) {
    int dr = (r - cell['r']!).abs();
    int dc = (c - cell['c']!).abs();
    return (dr == 1 && dc == 0) || (dr == 0 && dc == 1);
  }
}
