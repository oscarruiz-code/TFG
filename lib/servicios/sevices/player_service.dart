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
      await conn.query(
        'UPDATE player_stats SET coins = ? WHERE user_id = ?',
        [amount, userId],
      );
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
      var results = await conn.query(
        'SELECT * FROM game_history WHERE user_id = ? AND game_type = ? ORDER BY score DESC LIMIT 5',
        [userId, gameType],
      );

      return results.map((row) => row.fields).toList();
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
}