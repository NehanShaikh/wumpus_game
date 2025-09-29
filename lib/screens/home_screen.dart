import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';
import 'difficulty_selector.dart';
import 'game_screen.dart';
import '../services/game_logic.dart';
import 'login_screen.dart'; // import your login screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? stats;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => loading = true);
    final token = await AuthService.getToken();
    if (token == null) {
      print("No token found, cannot fetch stats");
      setState(() => loading = false);
      return;
    }

    try {
      final res = await http.get(
        Uri.parse(
            "https://nacreous-treva-downheartedly.ngrok-free.dev/api/games/stats"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
      );

      print("Stats response status: ${res.statusCode}");
      print("Stats response body: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          stats = data["summary"] ?? {};
          loading = false;
        });
      } else {
        print("Failed to fetch stats: ${res.body}");
        setState(() => loading = false);
      }
    } catch (e) {
      print("Error fetching stats: $e");
      setState(() => loading = false);
    }
  }

  Future<bool> _onWillPop() async {
    // Clear token or keep it, depends on your logic
    // await AuthService.clearToken();

    // Navigate back to login page
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    return false; // prevent default back navigation
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // intercept back button
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "🏹 Hunt the Wumpus",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 6,
                            color: Colors.black45,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text("🎮 Start New Game"),
                      onPressed: () => _showDifficultyDialog(context),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text("💾 Saved Games"),
                      onPressed: () {
                        if (stats == null || stats!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("No saved games found.")),
                          );
                        } else {
                          _showStatsDialog(context);
                        }
                      },
                    ),
                    if (loading)
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.blueGrey[900],
        title: const Text(
          "📊 Saved Games Stats",
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: stats!.entries.map((entry) {
              final diff = entry.key;
              final data = entry.value;
              return Card(
                color: Colors.black54,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "$diff → Wins: ${data['wins']} | Losses: ${data['losses']} | Matches: ${data['matches']}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Close", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => DifficultySelector(
        onSelected: (level) {
          Navigator.pop(context);
          _startGame(context, level);
        },
      ),
    );
  }

  void _startGame(BuildContext context, Difficulty level) {
    final game = GameLogic(level: level);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          game: game,
          onGameSaved: _fetchStats,
        ),
      ),
    );
  }
}
