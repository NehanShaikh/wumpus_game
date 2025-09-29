import 'package:flutter/material.dart';
import '../services/game_logic.dart';
import 'game_screen.dart';

class SaveLoadScreen extends StatelessWidget {
  // Example: data fetched from backend or local storage
  final List<Map<String, dynamic>> savedGames;

  SaveLoadScreen({
    this.savedGames = const [
      {
        "name": "Save 1",
        "boardSize": "4x4",
        "difficulty": "Easy",
        "wins": 3,
        "losses": 1,
        "matches": 4
      },
      {
        "name": "Save 2",
        "boardSize": "5x5",
        "difficulty": "Medium",
        "wins": 2,
        "losses": 3,
        "matches": 5
      }
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Saved Games")),
      body: ListView.builder(
        itemCount: savedGames.length,
        itemBuilder: (context, index) {
          final save = savedGames[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(save["name"]),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Board Size: ${save["boardSize"]}"),
                  Text("Difficulty: ${save["difficulty"]}"),
                  Text(
                      "Wins: ${save["wins"]} | Losses: ${save["losses"]} | Matches: ${save["matches"]}"),
                ],
              ),
              onTap: () async {
                GameLogic? game = await GameLogic.loadGame(save["name"]);
                if (game != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GameScreen(game: game)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to load game")),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
