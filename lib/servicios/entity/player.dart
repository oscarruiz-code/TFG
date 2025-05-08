
class PlayerStats {
  final int? id;  // Hacer el id nullable
  final int userId;
  int ticketsGame2;
  int coins;
  int renameTickets;
  bool hasUsedFreeRename;
  String currentAvatar;
  List<String> unlockedPremiumAvatars;

  PlayerStats({
    this.id,  // Ya no es required
    required this.userId,
    this.ticketsGame2 = 0,
    this.coins = 0,
    this.renameTickets = 0,
    this.hasUsedFreeRename = false,
    this.currentAvatar = 'assets/perfil/gratis/perfil1.png',
    this.unlockedPremiumAvatars = const [],
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
    };
  }

  factory PlayerStats.fromMap(Map<String, dynamic> map) {
    return PlayerStats(
      id: map['id'] != null ? int.parse(map['id'].toString()) : null,
      userId: int.parse(map['user_id'].toString()),
      ticketsGame2: int.parse(map['tickets_game2'].toString()),
      coins: int.parse(map['coins'].toString()),
      renameTickets: int.parse(map['rename_tickets'].toString()),
      hasUsedFreeRename: map['has_used_free_rename'] == 1,
      currentAvatar: map['current_avatar'] ?? 'assets/perfil/gratis/perfil1.png',
      unlockedPremiumAvatars: (map['unlocked_premium_avatars'] as String?)?.split(',').where((s) => s.isNotEmpty).toList() ?? [],
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