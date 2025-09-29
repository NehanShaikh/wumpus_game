import 'package:flutter/material.dart';
import '../services/game_logic.dart';

class DifficultySelector extends StatelessWidget {
  final Function(Difficulty) onSelected;
  DifficultySelector({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select Difficulty"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
              onPressed: () => onSelected(Difficulty.easy),
              child: Text("Easy")),
          ElevatedButton(
              onPressed: () => onSelected(Difficulty.medium),
              child: Text("Medium")),
          ElevatedButton(
              onPressed: () => onSelected(Difficulty.hard),
              child: Text("Hard")),
        ],
      ),
    );
  }
}
