
/// Clase que almacena las estadísticas y recursos de un jugador.
///
/// Mantiene un registro de los recursos del jugador (monedas, tickets),
/// su avatar actual y los avatares premium desbloqueados.
class PlayerStats {
  final int? id;
  final int userId;
  int ticketsGame2;
  int coins;
  int renameTickets;
  bool hasUsedFreeRename;
  String currentAvatar;
  List<String> unlockedPremiumAvatars;

  /// Crea una nueva instancia de estadísticas de jugador.
  ///
  /// Parámetros:
  /// * [id] - Identificador único de las estadísticas, puede ser nulo para nuevos registros.
  /// * [userId] - ID del usuario al que pertenecen estas estadísticas.
  /// * [ticketsGame2] - Tickets disponibles para el juego 2. Por defecto es 0.
  /// * [coins] - Monedas acumuladas por el jugador. Por defecto es 0.
  /// * [renameTickets] - Tickets para cambiar nombre. Por defecto es 0.
  /// * [hasUsedFreeRename] - Indica si ya usó el cambio de nombre gratuito. Por defecto es false.
  /// * [currentAvatar] - Ruta al avatar actual del jugador. Por defecto es el primer avatar gratuito.
  /// * [unlockedPremiumAvatars] - Lista de rutas a avatares premium desbloqueados. Por defecto está vacía.
  PlayerStats({
    this.id,
    required this.userId,
    this.ticketsGame2 = 0,
    this.coins = 0,
    this.renameTickets = 0,
    this.hasUsedFreeRename = false,
    this.currentAvatar = 'assets/perfil/gratis/perfil1.png',
    this.unlockedPremiumAvatars = const [],
  });

  /// Convierte el objeto PlayerStats a un mapa para almacenamiento en base de datos.
  ///
  /// Los avatares premium desbloqueados se almacenan como una cadena separada por comas.
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

  /// Crea un objeto PlayerStats a partir de un mapa de datos.
  ///
  /// Utiliza la función auxiliar _parseInt para manejar diferentes tipos de datos
  /// que pueden venir de la base de datos.
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
    );
  }

  /// Verifica si el jugador tiene desbloqueado un avatar premium específico.
  ///
  /// Retorna true si el avatar está en la lista de avatares premium desbloqueados.
  bool hasPremiumAvatar(String avatarPath) {
    return unlockedPremiumAvatars.contains(avatarPath);
  }

  /// Lista de rutas a todos los avatares gratuitos disponibles en el sistema.
  static List<String> get freeAvatars => [
    'assets/perfil/gratis/perfil1.png',
    'assets/perfil/gratis/perfil2.png',
    'assets/perfil/gratis/perfil3.png',
    'assets/perfil/gratis/perfil4.png',
    'assets/perfil/gratis/perfil5.png',
  ];

  /// Lista de rutas a todos los avatares premium disponibles en el sistema.
  static List<String> get premiumAvatars => [
    'assets/perfil/premium/perfil6.png',
    'assets/perfil/premium/perfil7.png',
    'assets/perfil/premium/perfil8.png',
  ];
}

/// Función auxiliar para convertir valores dinámicos a enteros.
///
/// Maneja casos donde el valor puede ser nulo, ya ser un entero o una cadena.
/// Retorna 0 si el valor no puede ser convertido a entero.
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String && value.isNotEmpty) return int.tryParse(value) ?? 0;
  return 0;
}