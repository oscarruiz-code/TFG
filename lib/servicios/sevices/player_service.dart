import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class PlayerService {

    Future<void> updateRenameTickets(int userId, int newAmount) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await conn.query(
        'UPDATE player_stats SET rename_tickets = ? WHERE user_id = ?',
        [newAmount, userId],
      );
    } finally {
      await conn.close();
    }
  }
  
   Future<bool> updateProfilePicture(int userId, String avatarPath) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Obtener stats actuales del jugador
      var stats = await getPlayerStats(userId);
      
      // Verificar si el avatar es gratuito
      if (PlayerStats.freeAvatars.contains(avatarPath)) {
        await conn.query(
          'UPDATE player_stats SET current_avatar = ? WHERE user_id = ?',
          [avatarPath, userId],
        );
        return true;
      }
      
      // Si es premium, verificar si está desbloqueado
      if (PlayerStats.premiumAvatars.contains(avatarPath) && 
          stats.hasPremiumAvatar(avatarPath)) {
        await conn.query(
          'UPDATE player_stats SET current_avatar = ? WHERE user_id = ?',
          [avatarPath, userId],
        );
        return true;
      }
      
      return false; // No tiene permiso para usar este avatar
    } finally {
      await conn.close();
    }
  }
  
  Future<PlayerStats> getPlayerStats(int userId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Primero verificar si es un admin
      var adminResults = await conn.query(
        'SELECT id FROM admins WHERE id = ?',
        [userId],
      );

      if (adminResults.isNotEmpty) {
        var results = await conn.query(
          'SELECT * FROM admin_stats WHERE admin_id = ?',
          [userId],
        );

        if (results.isEmpty) {
          await conn.query(
            'INSERT INTO admin_stats (admin_id) VALUES (?)',
            [userId],
          );
          results = await conn.query(
            'SELECT * FROM admin_stats WHERE admin_id = ?',
            [userId],
          );
        }
        return PlayerStats.fromMap(results.first.fields);
      }

      // Si no es admin, continuar con la lógica existente para usuarios normales
      var results = await conn.query(
        'SELECT * FROM player_stats WHERE user_id = ?',
        [userId],
      );

      if (results.isEmpty) {
        await conn.query(
          'INSERT INTO player_stats (user_id) VALUES (?)',
          [userId],
        );
        results = await conn.query(
          'SELECT * FROM player_stats WHERE user_id = ?',
          [userId],
        );
      }

      return PlayerStats.fromMap(results.first.fields);
    } finally {
      await conn.close();
    }
  }

  Future<void> updateCoins(int userId, int amount) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Primero verificar si es un admin
      var adminResults = await conn.query(
        'SELECT id FROM admins WHERE id = ?',
        [userId],
      );

      if (adminResults.isNotEmpty) {
        await conn.query(
          'UPDATE admin_stats SET coins = ? WHERE admin_id = ?',
          [amount, userId],
        );
      } else {
        await conn.query(
          'UPDATE player_stats SET coins = ? WHERE user_id = ?',
          [amount, userId],
        );
      }
    } finally {
      await conn.close();
    }
  }

  Future<void> updateTicketsGame2(int userId, int amount) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await conn.query(
        'UPDATE player_stats SET tickets_game2 = ? WHERE user_id = ?',
        [amount, userId],
      );
    } finally {
      await conn.close();
    }
  }

  Future<bool> useRenameTicket(int userId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var stats = await getPlayerStats(userId);
      
      if (!stats.hasUsedFreeRename) {
        await conn.query(
          'UPDATE player_stats SET has_used_free_rename = 1 WHERE user_id = ?',
          [userId],
        );
        return true;
      } else if (stats.renameTickets > 0) {
        await conn.query(
          'UPDATE player_stats SET rename_tickets = rename_tickets - 1 WHERE user_id = ?',
          [userId],
        );
        return true;
      }
      return false;
    } finally {
      await conn.close();
    }
  }

  Future<void> registerGamePlay(int userId, int gameType, int score, int duration) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Verificar si es un admin
      var adminResults = await conn.query(
        'SELECT id FROM admins WHERE id = ?',
        [userId],
      );

      if (adminResults.isNotEmpty) {
        await conn.query(
          'INSERT INTO admin_game_history (admin_id, game_type, score, duration) VALUES (?, ?, ?, ?)',
          [userId, gameType, score, duration],
        );
      } else {
        await conn.query(
          'INSERT INTO game_history (user_id, game_type, score, duration) VALUES (?, ?, ?, ?)',
          [userId, gameType, score, duration],
        );
      }
    } finally {
      await conn.close();
    }
  }

  Future<List<Map<String, dynamic>>> getGameHistory(int userId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Verificar si es un admin
      var adminResults = await conn.query(
        'SELECT id FROM admins WHERE id = ?',
        [userId],
      );

      if (adminResults.isNotEmpty) {
        var results = await conn.query(
          'SELECT * FROM admin_game_history WHERE admin_id = ? ORDER BY played_at DESC',
          [userId],
        );
        return results.map((row) => row.fields).toList();
      }

      var results = await conn.query(
        'SELECT * FROM game_history WHERE user_id = ? ORDER BY played_at DESC',
        [userId],
      );

      return results.map((row) => row.fields).toList();
    } finally {
      await conn.close();
    }
  }

  Future<List<Map<String, dynamic>>> getTopScores(int userId, int gameType) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Obtener puntuaciones de usuarios normales
      var userResults = await conn.query(
        '''SELECT gh.*, u.username 
           FROM game_history gh
           JOIN users u ON gh.user_id = u.id
           WHERE gh.game_type = ?
           UNION ALL
           SELECT gh.*, a.username 
           FROM admin_game_history gh
           JOIN admins a ON gh.admin_id = a.id
           WHERE gh.game_type = ?
           ORDER BY score DESC 
           LIMIT 5''',
        [gameType, gameType],
      );

      return userResults.map((row) => row.fields).toList();
    } finally {
      await conn.close();
    }
  }

  Future<bool> updateUsername(int userId, String newUsername) async {
      final conn = await DatabaseConnection.getConnection();
      try {
        // First check if username already exists
        var checkResults = await conn.query(
          'SELECT id FROM users WHERE username = ? AND id != ?',
          [newUsername, userId],
        );
        
        if (checkResults.isNotEmpty) {
          return false; // Username already taken
        }
  
        await conn.query(
          'UPDATE users SET username = ? WHERE id = ?',
          [newUsername, userId],
        );
        return true; // Update successful
      } finally {
        await conn.close();
      }
    }

  Future<void> setUsedFreeRename(int userId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await conn.query(
        'UPDATE player_stats SET has_used_free_rename = true WHERE user_id = ?',
        [userId],
      );
    } finally {
      await conn.close();
    }
  }
  
  Future<void> updateUnlockedPremiumAvatars(int userId, List<String> avatars) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await conn.query(
        'UPDATE player_stats SET unlocked_premium_avatars = ? WHERE user_id = ?',
        [avatars.join(','), userId],
      );
    } finally {
      await conn.close();
    }
  }
  
  Future<void> deletePlayerStats(int userId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await conn.query('DELETE FROM player_stats WHERE user_id = ?', [userId]);
    } finally {
      await conn.close();
    }
  }

  Future<void> updatePlayerStats(int userId, int renameTickets, int coins, int ticketsGame2) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await conn.query(
        'UPDATE player_stats SET rename_tickets = ?, coins = ?, tickets_game2 = ? WHERE user_id = ?',
        [renameTickets, coins, ticketsGame2, userId]
      );
    } finally {
      await conn.close();
    }
  }

  Future<void> unlockPremiumAvatar(int userId, String avatarPath) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Obtener los avatares desbloqueados actuales
      var stats = await getPlayerStats(userId);
      List<String> unlocked = List<String>.from(stats.unlockedPremiumAvatars);
      if (!unlocked.contains(avatarPath)) {
        unlocked.add(avatarPath);
        String updatedAvatars = unlocked.join(',');
        await conn.query(
          'UPDATE player_stats SET unlocked_premium_avatars = ? WHERE user_id = ?',
          [updatedAvatars, userId],
        );
      }
    } finally {
      await conn.close();
    }
  }

  Future<void> saveGameProgress({
    required int userId,
    required int gameType,
    required int score,
    required int coins,
    required bool victory,
    required int duration,
    required double worldOffset,
    required double playerX,
    required double playerY,
    required int health,
  }) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Desactivar guardados anteriores
      await conn.query(
        'UPDATE game_saves SET is_active = FALSE WHERE user_id = ? AND game_type = ?',
        [userId, gameType],
      );
      
      // Guardar el nuevo estado del juego
      await conn.query(
        '''INSERT INTO game_saves 
           (user_id, game_type, position_x, position_y, coins_collected, 
            health, is_active)
           VALUES (?, ?, ?, ?, ?, ?, TRUE)''',
        [userId, gameType, playerX, playerY, coins, health],
      );

      // Guardar en el historial
      await conn.query(
        'INSERT INTO game_history (user_id, game_type, score, coins, victory, duration) VALUES (?, ?, ?, ?, ?, ?)',
        [userId, gameType, score, coins, victory ? 1 : 0, duration],
      );
    } finally {
      await conn.close();
    }
  }

  Future<void> updatePlayerCoins(
    {required int userId, 
    required int coinsToAdd}) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var stats = await getPlayerStats(userId);
      int newCoins = stats.coins + coinsToAdd;
      
      await conn.query(
        'UPDATE player_stats SET coins = ? WHERE user_id = ?',
        [newCoins, userId]
      );
    } finally {
      await conn.close();
    }
  }

  Future<void> saveGameState({
    required int userId,
    required int gameType,
    required double positionX,
    required double positionY,
    required int currentLevel,
    required int coinsCollected,
    required int health,
    String? lastCheckpoint,
  }) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Verificar si es admin
      var adminResults = await conn.query(
        'SELECT id FROM admins WHERE id = ?',
        [userId],
      );

      if (adminResults.isNotEmpty) {
        // Desactivar guardados anteriores
        await conn.query(
          'UPDATE admin_game_saves SET is_active = FALSE WHERE admin_id = ? AND game_type = ?',
          [userId, gameType],
        );
        
        // Crear nuevo guardado
        await conn.query(
          '''INSERT INTO admin_game_saves 
             (admin_id, game_type, position_x, position_y, current_level, 
              coins_collected, health, last_checkpoint)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
          [userId, gameType, positionX, positionY, currentLevel, 
           coinsCollected, health, lastCheckpoint],
        );
      } else {
        // Desactivar guardados anteriores
        await conn.query(
          'UPDATE game_saves SET is_active = FALSE WHERE user_id = ? AND game_type = ?',
          [userId, gameType],
        );
        
        // Crear nuevo guardado
        await conn.query(
          '''INSERT INTO game_saves 
             (user_id, game_type, position_x, position_y, current_level, 
              coins_collected, health, last_checkpoint)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
          [userId, gameType, positionX, positionY, currentLevel, 
           coinsCollected, health, lastCheckpoint],
        );
      }
    } finally {
      await conn.close();
    }
  }

  Future<Map<String, dynamic>?> loadGameState(int userId, int gameType) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Verificar si es admin
      var adminResults = await conn.query(
        'SELECT id FROM admins WHERE id = ?',
        [userId],
      );

      if (adminResults.isNotEmpty) {
        var results = await conn.query(
          '''SELECT * FROM admin_game_saves 
             WHERE admin_id = ? AND game_type = ? AND is_active = TRUE
             ORDER BY updated_at DESC LIMIT 1''',
          [userId, gameType],
        );
        
        if (results.isEmpty) return null;
        return results.first.fields;
      } else {
        var results = await conn.query(
          '''SELECT * FROM game_saves 
             WHERE user_id = ? AND game_type = ? AND is_active = TRUE
             ORDER BY updated_at DESC LIMIT 1''',
          [userId, gameType],
        );
        
        if (results.isEmpty) return null;
        return results.first.fields;
      }
    } finally {
      await conn.close();
    }
  }

  Future<Map<String, dynamic>?> getSavedGame(int userId) async {
    return loadGameState(userId, 1); // Asumimos que Game1 tiene gameType = 1
  }

  Future<void> deleteSavedGame(int userId) async {
    await deleteGameSave(userId, 1); // Asumimos que Game1 tiene gameType = 1
  }

  Future<void> deleteGameSave(int userId, int gameType) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Verificar si es admin
      var adminResults = await conn.query(
        'SELECT id FROM admins WHERE id = ?',
        [userId],
      );

      if (adminResults.isNotEmpty) {
        await conn.query(
          'UPDATE admin_game_saves SET is_active = FALSE WHERE admin_id = ? AND game_type = ?',
          [userId, gameType],
        );
      } else {
        await conn.query(
          'UPDATE game_saves SET is_active = FALSE WHERE user_id = ? AND game_type = ?',
          [userId, gameType],
        );
      }
    } finally {
      await conn.close();
    }
  }
}