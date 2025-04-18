class PlayerStats {
  final int id;
  final int userId;
  int ticketsGame2;
  int coins;
  int renameTickets;
  bool hasUsedFreeRename;

  PlayerStats({
    required this.id,
    required this.userId,
    this.ticketsGame2 = 0,
    this.coins = 0,
    this.renameTickets = 0,
    this.hasUsedFreeRename = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'tickets_game2': ticketsGame2,
      'coins': coins,
      'rename_tickets': renameTickets,
      'has_used_free_rename': hasUsedFreeRename ? 1 : 0,
    };
  }

  factory PlayerStats.fromMap(Map<String, dynamic> map) {
    return PlayerStats(
      id: map['id'],
      userId: map['user_id'],
      ticketsGame2: map['tickets_game2'],
      coins: map['coins'],
      renameTickets: map['rename_tickets'],
      hasUsedFreeRename: map['has_used_free_rename'] == 1,
    );
  }
}