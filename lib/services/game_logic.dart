import 'dart:math';

enum Difficulty { easy, medium, hard }

class GameState {
  final int boardSize;
  Map<String, int> player;
  Map<String, int> wumpus;
  Map<String, int> gold;
  List<Map<String, int>> pits;
  int arrows;
  bool hasGold;
  bool wumpusAlive;
  String status; // "in_progress", "won", "dead"
  int turn;
  List<List<bool>> revealed;

  GameState({
    required this.boardSize,
    required this.player,
    required this.wumpus,
    required this.gold,
    required this.pits,
    required this.arrows,
    required this.status,
    required this.turn,
    required this.revealed,
    required this.hasGold,
    required this.wumpusAlive,
  });

  factory GameState.newGame(int size) {
    return GameState(
      boardSize: size,
      player: {"r": 0, "c": 0},
      wumpus: {"r": 2, "c": 1},
      gold: {"r": size - 1, "c": size - 1},
      pits: [],
      arrows: 3,
      status: "in_progress",
      turn: 0,
      hasGold: false,
      wumpusAlive: true,
      revealed: List.generate(size, (_) => List.generate(size, (_) => false)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "boardSize": boardSize,
      "player": player,
      "wumpus": wumpus,
      "gold": gold,
      "pits": pits,
      "arrows": arrows,
      "hasGold": hasGold,
      "wumpusAlive": wumpusAlive,
      "status": status,
      "turn": turn,
      "revealed": revealed,
    };
  }
}

class GameLogic {
  late GameState state;
  final Random _rand = Random();
  final Difficulty level;

  GameLogic({this.level = Difficulty.easy}) {
    int boardSize;
    int numPits;
    int arrows;

    switch (level) {
      case Difficulty.easy:
        boardSize = 4;
        numPits = 2;
        arrows = 1;
        break;
      case Difficulty.medium:
        boardSize = 5;
        numPits = 3;
        arrows = 1;
        break;
      case Difficulty.hard:
        boardSize = 6;
        numPits = 6;
        arrows = 1;
        break;
    }

    state = GameState.newGame(boardSize);
    state.arrows = arrows;

    // Place Wumpus, Gold, and Pits randomly
    state.wumpus = _randomCell(excludeStart: true);
    state.gold = _randomCell(exclude: [
      state.wumpus,
      {'r': 0, 'c': 0}
    ]);

    state.pits = [];
    for (int i = 0; i < numPits; i++) {
      state.pits.add(_randomCell(exclude: [
        state.wumpus,
        state.gold,
        {'r': 0, 'c': 0},
        ...state.pits
      ]));
    }

    state.revealed[0][0] = true; // starting cell revealed
  }

  Map<String, int> _randomCell(
      {List<Map<String, int>> exclude = const [], bool excludeStart = false}) {
    while (true) {
      int r = _rand.nextInt(state.boardSize);
      int c = _rand.nextInt(state.boardSize);
      Map<String, int> cell = {'r': r, 'c': c};
      if (excludeStart && r == 0 && c == 0) continue;
      if (exclude.any((e) => e['r'] == r && e['c'] == c)) continue;
      return cell;
    }
  }

  // Move the player
  void move(String direction) {
    if (state.status != "in_progress") return;

    int r = state.player['r']!;
    int c = state.player['c']!;

    if (direction == "up" && r > 0) r--;
    if (direction == "down" && r < state.boardSize - 1) r++;
    if (direction == "left" && c > 0) c--;
    if (direction == "right" && c < state.boardSize - 1) c++;

    state.player['r'] = r;
    state.player['c'] = c;
    state.turn++;
    state.revealed[r][c] = true;

    // Death conditions
    if (state.pits.any((p) => p['r'] == r && p['c'] == c)) {
      state.status = "dead";
      return;
    }
    if (state.wumpusAlive && r == state.wumpus['r'] && c == state.wumpus['c']) {
      state.status = "dead";
      return;
    }

    // Gold collection
    if (r == state.gold['r'] && c == state.gold['c']) {
      state.hasGold = true;
    }

    // Win if player has gold and returns to start
    if (r == 0 && c == 0 && state.hasGold) {
      state.status = "won";
    }
  }

  // Shoot arrow in a straight line
  bool shoot(String direction) {
    if (state.arrows <= 0 || state.status != "in_progress") return false;

    int r = state.player['r']!;
    int c = state.player['c']!;

    state.arrows--;

    while (r >= 0 && r < state.boardSize && c >= 0 && c < state.boardSize) {
      if (r == state.wumpus['r'] &&
          c == state.wumpus['c'] &&
          state.wumpusAlive) {
        state.wumpusAlive = false; // Wumpus killed
        return true;
      }
      if (direction == "up") r--;
      if (direction == "down") r++;
      if (direction == "left") c--;
      if (direction == "right") c++;
    }

    return false; // arrow missed
  }

  // Return clues for current cell
  List<String> getClues() {
    int r = state.player['r']!;
    int c = state.player['c']!;
    List<String> clues = [];

    for (var pit in state.pits) {
      if ((pit['r']! - r).abs() + (pit['c']! - c).abs() == 1) {
        clues.add("Breeze");
      }
    }

    if (state.wumpusAlive &&
        (state.wumpus['r']! - r).abs() + (state.wumpus['c']! - c).abs() == 1) {
      clues.add("Stench");
    }

    if (r == state.gold['r'] && c == state.gold['c']) {
      clues.add("Glitter");
    }

    return clues;
  }

  // Helper fields for saving
  int get boardSize => state.boardSize;
  Map<String, dynamic> toJson() => state.toJson();

  // Static placeholder to load a game
  static Future<GameLogic?> loadGame(String saveName) async {
    await Future.delayed(Duration(milliseconds: 200));
    return GameLogic(level: Difficulty.easy);
  }
}
