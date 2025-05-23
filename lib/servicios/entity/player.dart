
class PlayerStats {
  final int? id;
  final int userId;
  int ticketsGame2;
  int coins;
  int renameTickets;
  bool hasUsedFreeRename;
  String currentAvatar;
  List<String> unlockedPremiumAvatars;
  int bestScore;
  int playTime;
  double worldOffset;
  int currentLevel;
  int health;
  String? lastCheckpoint;

  PlayerStats({
    this.id,
    required this.userId,
    this.ticketsGame2 = 0,
    this.coins = 0,
    this.renameTickets = 0,
    this.hasUsedFreeRename = false,
    this.currentAvatar = 'assets/perfil/gratis/perfil1.png',
    this.unlockedPremiumAvatars = const [],
    this.bestScore = 0,
    this.playTime = 0,
    this.worldOffset = 0.0,
    this.currentLevel = 1,
    this.health = 100,
    this.lastCheckpoint,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'tickets_game2': ticketsGame2,
      'coins': coins,
      'rename_tickets': renameTickets,
      'has_used_free_rename': hasUsedFreeRename ? 1 : 0,
      'current_avatar': currentAvatar,
      'unlocked_premium_avatars': unlockedPremiumAvatars.join(','),
      'best_score': bestScore,
      'play_time': playTime,
      'world_offset': worldOffset,
      'current_level': currentLevel,
      'health': health,
      'last_checkpoint': lastCheckpoint,
    };
  }

  factory PlayerStats.fromMap(Map<String, dynamic> map) {
    return PlayerStats(
      id: map['id'] != null ? _parseInt(map['id']) : null,
      userId: _parseInt(map['user_id'] ?? map['admin_id']),
      ticketsGame2: _parseInt(map['tickets_game2']),
      coins: _parseInt(map['coins']),
      renameTickets: _parseInt(map['rename_tickets']),
      hasUsedFreeRename: map['has_used_free_rename'] == 1,
      currentAvatar: map['current_avatar'] ?? 'assets/perfil/gratis/perfil1.png',
      unlockedPremiumAvatars: (map['unlocked_premium_avatars'] as String?)?.split(',').where((s) => s.isNotEmpty).toList() ?? [],
      bestScore: _parseInt(map['best_score']),
      playTime: _parseInt(map['play_time']),
      worldOffset: map['world_offset'] != null ? (map['world_offset'] as num).toDouble() : 0.0,
      currentLevel: _parseInt(map['current_level']),
      health: _parseInt(map['health']),
      lastCheckpoint: map['last_checkpoint'],
    );
  }

  bool hasPremiumAvatar(String avatarPath) {
    return unlockedPremiumAvatars.contains(avatarPath);
  }

  static List<String> get freeAvatars => [
    'assets/perfil/gratis/perfil1.png',
    'assets/perfil/gratis/perfil2.png',
    'assets/perfil/gratis/perfil3.png',
    'assets/perfil/gratis/perfil4.png',
    'assets/perfil/gratis/perfil5.png',
  ];

  static List<String> get premiumAvatars => [
    'assets/perfil/premium/perfil6.png',
    'assets/perfil/premium/perfil7.png',
    'assets/perfil/premium/perfil8.png',
  ];
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String && value.isNotEmpty) return int.tryParse(value) ?? 0;
  return 0;
}