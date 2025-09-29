import 'package:flutter/material.dart';
import '../services/game_logic.dart';
import '../widgets/board_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';

class GameScreen extends StatefulWidget {
  final GameLogic game;
  final VoidCallback? onGameSaved;

  GameScreen({required this.game, this.onGameSaved});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameLogic game;

  @override
  void initState() {
    super.initState();
    game = widget.game;
  }

  void _move(String direction) {
    setState(() => game.move(direction));
    _checkGameEnd();
  }

  void _shoot(String direction) {
    setState(() {
      bool hit = game.shoot(direction);
      if (hit) {
        _showDialog("You killed the Wumpus! You win! 🏆");
      } else if (game.state.arrows == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No arrows left!")),
        );
      }
    });
    _checkGameEnd();
  }

  void _checkGameEnd() {
    if (game.state.status == "dead") {
      Future.microtask(() => _showDialog("You died! ☠️"));
    } else if (game.state.status == "won") {
      Future.microtask(() => _showDialog("You won! 🎉"));
    }
  }

  Future<void> _saveGame() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    final won = game.state.status == "won";

    try {
      final res = await http.post(
        Uri.parse("http://192.168.70:5000/api/games/save"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "name": "Game ${DateTime.now()}",
          "boardSize": game.state.boardSize,
          "gameState": game.toJson(),
          "difficulty": game.level.toString().split('.').last,
          "wins": won ? 1 : 0,
          "losses": won ? 0 : 1,
          "matches": 1
        }),
      );

      if (res.statusCode == 200) {
        print("Game saved successfully");
      } else {
        print("Failed to save game: ${res.body}");
      }

      // Refresh HomeScreen stats
      if (widget.onGameSaved != null) widget.onGameSaved!();
    } catch (e) {
      print("Error saving game: $e");
    }
  }

  void _showDialog(String msg) {
    _saveGame(); // Save the game when it ends
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Game Over"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, ModalRoute.withName('/home')),
            child: const Text("Back to Home"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> clues = game.getClues();

    return Scaffold(
      appBar: AppBar(title: const Text("Wumpus Game")),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text("Turn: ${game.state.turn}",
                style: const TextStyle(color: Colors.white)),
            Text("Arrows left: ${game.state.arrows}",
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 5),
            Wrap(
              spacing: 10,
              children: clues
                  .map((c) => Chip(
                        label: Text(c),
                        backgroundColor: Colors.orangeAccent,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BoardWidget(game: game),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () => _move("up"),
                          child: const Text("⬆ Up")),
                      ElevatedButton(
                          onPressed: () => _move("left"),
                          child: const Text("⬅ Left")),
                      ElevatedButton(
                          onPressed: () => _move("right"),
                          child: const Text("➡ Right")),
                      ElevatedButton(
                          onPressed: () => _move("down"),
                          child: const Text("⬇ Down")),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () => _shoot("up"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent),
                          child: const Text("Shoot ⬆")),
                      ElevatedButton(
                          onPressed: () => _shoot("left"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent),
                          child: const Text("Shoot ⬅")),
                      ElevatedButton(
                          onPressed: () => _shoot("right"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent),
                          child: const Text("Shoot ➡")),
                      ElevatedButton(
                          onPressed: () => _shoot("down"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent),
                          child: const Text("Shoot ⬇")),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    game.state.hasGold
                        ? "💰 Gold collected!"
                        : "Gold not yet collected",
                    style: const TextStyle(color: Colors.amberAccent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
