class GameState {
  final int boardSize;
  Map<String, int> player;
  Map<String, int> wumpus;
  Map<String, int> gold;
  List<Map<String, int>> pits;
  int arrows;
  String status;
  int turn;

  // NEW: track if gold has been collected
  bool hasGold;

  // NEW: track revealed cells for hiding hazards
  late List<List<bool>> revealed;

  GameState({
    required this.boardSize,
    required this.player,
    required this.wumpus,
    required this.gold,
    required this.pits,
    required this.arrows,
    required this.status,
    required this.turn,
    this.hasGold = false,
  }) {
    // Initialize revealed grid
    revealed =
        List.generate(boardSize, (_) => List.generate(boardSize, (_) => false));
  }

  factory GameState.newGame(int size) {
    return GameState(
      boardSize: size,
      player: {"r": 0, "c": 0},
      wumpus: {"r": 2, "c": 1},
      gold: {"r": size - 1, "c": size - 1},
      pits: [
        {"r": 1, "c": 2}
      ],
      arrows: 3,
      status: "in_progress",
      turn: 0,
      hasGold: false,
    );
  }

  Map<String, dynamic> toJson() => {
        "boardSize": boardSize,
        "player": player,
        "wumpus": wumpus,
        "gold": gold,
        "pits": pits,
        "arrows": arrows,
        "status": status,
        "turn": turn,
        "hasGold": hasGold,
      };

  factory GameState.fromJson(Map<String, dynamic> j) {
    GameState gs = GameState(
      boardSize: j['boardSize'],
      player: Map<String, int>.from(j['player']),
      wumpus: Map<String, int>.from(j['wumpus']),
      gold: Map<String, int>.from(j['gold']),
      pits: List<Map<String, int>>.from(j['pits']),
      arrows: j['arrows'],
      status: j['status'],
      turn: j['turn'],
      hasGold: j['hasGold'] ?? false,
    );
    gs.revealed = List.generate(
        gs.boardSize, (_) => List.generate(gs.boardSize, (_) => false));
    gs.revealed[gs.player['r']!][gs.player['c']!] = true;
    return gs;
  }
}
