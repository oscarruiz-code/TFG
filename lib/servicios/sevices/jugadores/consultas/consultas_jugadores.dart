import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class PlayerQueryRepository {
  // Consultas para verificar si es admin
  static Future<Results> checkIfAdmin(MySqlConnection conn, int userId) async {
    return await conn.query(
      'SELECT id FROM admins WHERE id = ?',
      [userId],
    );
  }
  
  // Consultas para tickets de renombre
  static Future<Results> updateAdminRenameTickets(MySqlConnection conn, int userId, int newAmount) async {
    return await conn.query(
      'UPDATE admin_stats SET rename_tickets = ? WHERE admin_id = ?',
      [newAmount, userId],
    );
  }
  
  static Future<Results> updateUserRenameTickets(MySqlConnection conn, int userId, int newAmount) async {
    return await conn.query(
      'UPDATE player_stats SET rename_tickets = ? WHERE user_id = ?',
      [newAmount, userId],
    );
  }
  
  // Consultas para avatar
  static Future<Results> updateAdminAvatar(MySqlConnection conn, int userId, String avatarPath) async {
    return await conn.query(
      'UPDATE admin_stats SET current_avatar = ? WHERE admin_id = ?',
      [avatarPath, userId],
    );
  }
  
  static Future<Results> updateUserAvatar(MySqlConnection conn, int userId, String avatarPath) async {
    return await conn.query(
      'UPDATE player_stats SET current_avatar = ? WHERE user_id = ?',
      [avatarPath, userId],
    );
  }
  
  // Consultas para estadísticas de jugador
  static Future<Results> getAdminStats(MySqlConnection conn, int userId) async {
    return await conn.query(
      'SELECT * FROM admin_stats WHERE admin_id = ?',
      [userId],
    );
  }
  
  static Future<Results> getUserStats(MySqlConnection conn, int userId) async {
    return await conn.query(
      'SELECT * FROM player_stats WHERE user_id = ?',
      [userId],
    );
  }
  
  static Future<Results> insertAdminStats(MySqlConnection conn, int userId) async {
    return await conn.query(
      'INSERT INTO admin_stats (admin_id) VALUES (?)',
      [userId],
    );
  }
  
  static Future<Results> insertUserStats(MySqlConnection conn, int userId) async {
    return await conn.query(
      'INSERT INTO player_stats (user_id) VALUES (?)',
      [userId],
    );
  }
  
  // Consultas para monedas
  static Future<Results> updateAdminCoins(MySqlConnection conn, int userId, int amount) async {
    return await conn.query(
      'UPDATE admin_stats SET coins = ? WHERE admin_id = ?',
      [amount, userId],
    );
  }
  
  static Future<Results> updateUserCoins(MySqlConnection conn, int userId, int amount) async {
    return await conn.query(
      'UPDATE player_stats SET coins = ? WHERE user_id = ?',
      [amount, userId],
    );
  }
  
  // Consultas para tickets de juego 2
  static Future<Results> updateAdminTicketsGame2(MySqlConnection conn, int userId, int amount) async {
    return await conn.query(
      'UPDATE admin_stats SET tickets_game2 = ? WHERE admin_id = ?',
      [amount, userId],
    );
  }
  
  static Future<Results> updateUserTicketsGame2(MySqlConnection conn, int userId, int amount) async {
    return await conn.query(
      'UPDATE player_stats SET tickets_game2 = ? WHERE user_id = ?',
      [amount, userId],
    );
  }
  
  // Consultas para uso de tickets de renombre
  static Future<Results> setUserHasUsedFreeRename(MySqlConnection conn, int userId) async {
    return await conn.query(
      'UPDATE player_stats SET has_used_free_rename = 1 WHERE user_id = ?',
      [userId],
    );
  }
  
  static Future<Results> decrementUserRenameTickets(MySqlConnection conn, int userId) async {
    return await conn.query(
      'UPDATE player_stats SET rename_tickets = rename_tickets - 1 WHERE user_id = ?',
      [userId],
    );
  }
  
  // Consultas para historial de juego
  static Future<Results> insertAdminGameHistory(MySqlConnection conn, int userId, int gameType, int score, int duration) async {
    return await conn.query(
      'INSERT INTO admin_game_history (admin_id, game_type, score, duration) VALUES (?, ?, ?, ?)',
      [userId, gameType, score, duration],
    );
  }
  
  static Future<Results> insertUserGameHistory(MySqlConnection conn, int userId, int gameType, int score, int duration) async {
    return await conn.query(
      'INSERT INTO game_history (user_id, game_type, score, duration) VALUES (?, ?, ?, ?)',
      [userId, gameType, score, duration],
    );
  }
  
  static Future<Results> getAdminGameHistory(MySqlConnection conn, int userId) async {
    return await conn.query(
      'SELECT * FROM admin_game_history WHERE admin_id = ? ORDER BY played_at DESC',
      [userId],
    );
  }
  
  static Future<Results> getUserGameHistory(MySqlConnection conn, int userId) async {
    return await conn.query(
      'SELECT * FROM game_history WHERE user_id = ? ORDER BY played_at DESC',
      [userId],
    );
  }
  
  // Consultas para puntuaciones máximas
  static Future<Results> getTopScores(MySqlConnection conn, int gameType) async {
    return await conn.query(
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
  }
  
  // Consultas para actualización de nombre de usuario
  static Future<Results> checkUsernameExists(MySqlConnection conn, String newUsername, int userId) async {
    return await conn.query(
      'SELECT id FROM users WHERE username = ? AND id != ?',
      [newUsername, userId],
    );
  }
  
  static Future<Results> updateUsername(MySqlConnection conn, int userId, String newUsername) async {
    return await conn.query(
      'UPDATE users SET username = ? WHERE id = ?',
      [newUsername, userId],
    );
  }
  
  // Consultas para avatares premium
  static Future<Results> updateUnlockedPremiumAvatars(MySqlConnection conn, int userId, String avatars) async {
    return await conn.query(
      'UPDATE player_stats SET unlocked_premium_avatars = ? WHERE user_id = ?',
      [avatars, userId],
    );
  }
  
  // Consultas para eliminar estadísticas de jugador
  static Future<Results> deletePlayerStats(MySqlConnection conn, int userId) async {
    return await conn.query(
      'DELETE FROM player_stats WHERE user_id = ?',
      [userId],
    );
  }
  
  // Consultas para actualizar estadísticas de jugador
  static Future<Results> updatePlayerStats(MySqlConnection conn, int userId, int renameTickets, int coins, int ticketsGame2) async {
    return await conn.query(
      'UPDATE player_stats SET rename_tickets = ?, coins = ?, tickets_game2 = ? WHERE user_id = ?',
      [renameTickets, coins, ticketsGame2, userId],
    );
  }
  
  // Consultas para guardar progreso de juego
  static Future<Results> deleteAdminGameSaves(MySqlConnection conn, int userId, int gameType) async {
    return await conn.query(
      'DELETE FROM admin_game_saves WHERE admin_id = ? AND game_type = ?',
      [userId, gameType],
    );
  }
  
  static Future<Results> deleteUserGameSaves(MySqlConnection conn, int userId, int gameType) async {
    return await conn.query(
      'DELETE FROM game_saves WHERE user_id = ? AND game_type = ?',
      [userId, gameType],
    );
  }
  
  static Future<Results> insertAdminGameSave(MySqlConnection conn, int userId, int gameType, double playerX, double playerY, 
      double worldOffset, int coins, int health, int currentLevel, String? lastCheckpoint, String? collectedCoinsPositions, int duration) async {
    return await conn.query(
      '''INSERT INTO admin_game_saves 
         (admin_id, game_type, position_x, position_y, world_offset,
          coins_collected, health, current_level, last_checkpoint, is_active, collected_coins_positions, duration)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, TRUE, ?, ?)''',
      [
        userId,
        gameType,
        playerX,
        playerY,
        worldOffset,
        coins,
        health,
        currentLevel,
        lastCheckpoint,
        collectedCoinsPositions,
        duration,
      ],
    );
  }
  
  static Future<Results> insertUserGameSave(MySqlConnection conn, int userId, int gameType, double playerX, double playerY, 
      double worldOffset, int coins, int health, int currentLevel, String? lastCheckpoint, String? collectedCoinsPositions, int duration) async {
    return await conn.query(
      '''INSERT INTO game_saves 
         (user_id, game_type, position_x, position_y, world_offset,
          coins_collected, health, current_level, last_checkpoint, is_active, collected_coins_positions, duration)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, TRUE, ?, ?)''',
      [
        userId,
        gameType,
        playerX,
        playerY,
        worldOffset,
        coins,
        health,
        currentLevel,
        lastCheckpoint,
        collectedCoinsPositions,
        duration,
      ],
    );
  }
  
  // Consultas para cargar estado de juego
  static Future<Results> loadAdminGameState(MySqlConnection conn, int userId, int gameType) async {
    return await conn.query(
      '''SELECT * FROM admin_game_saves 
         WHERE admin_id = ? AND game_type = ? AND is_active = TRUE
         ORDER BY updated_at DESC LIMIT 1''',
      [userId, gameType],
    );
  }
  
  static Future<Results> loadUserGameState(MySqlConnection conn, int userId, int gameType) async {
    return await conn.query(
      '''SELECT * FROM game_saves 
         WHERE user_id = ? AND game_type = ? AND is_active = TRUE
         ORDER BY updated_at DESC LIMIT 1''',
      [userId, gameType],
    );
  }
  
  // Consultas para registrar victorias en el historial de juego
  static Future<Results> registerAdminVictory(MySqlConnection conn, int userId, int gameType, int score, int coins, int duration) async {
    return await conn.query(
      'INSERT INTO admin_game_history (admin_id, game_type, score, coins, victory, duration) VALUES (?, ?, ?, ?, ?, ?)',
      [userId, gameType, score, coins, 1, duration],
    );
  }
  
  static Future<Results> registerUserVictory(MySqlConnection conn, int userId, int gameType, int score, int coins, int duration) async {
    return await conn.query(
      'INSERT INTO game_history (user_id, game_type, score, coins, victory, duration) VALUES (?, ?, ?, ?, ?, ?)',
      [userId, gameType, score, coins, 1, duration],
    );
  }
  
  // Consultas para guardar estado de juego
  static Future<Results> deactivateAdminGameSaves(MySqlConnection conn, int userId, int gameType) async {
    return await conn.query(
      'UPDATE admin_game_saves SET is_active = FALSE WHERE admin_id = ? AND game_type = ?',
      [userId, gameType],
    );
  }
  
  static Future<Results> deactivateUserGameSaves(MySqlConnection conn, int userId, int gameType) async {
    return await conn.query(
      'UPDATE game_saves SET is_active = FALSE WHERE user_id = ? AND game_type = ?',
      [userId, gameType],
    );
  }
  
  static Future<Results> insertAdminGameState(MySqlConnection conn, int userId, int gameType, double positionX, double positionY, 
      int currentLevel, int coinsCollected, int health, String? lastCheckpoint, int duration) async {
    return await conn.query(
      '''INSERT INTO admin_game_saves 
         (admin_id, game_type, position_x, position_y, current_level, 
          coins_collected, health, last_checkpoint, duration)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        userId,
        gameType,
        positionX,
        positionY,
        currentLevel,
        coinsCollected,
        health,
        lastCheckpoint,
        duration,
      ],
    );
  }
  
  static Future<Results> insertUserGameState(MySqlConnection conn, int userId, int gameType, double positionX, double positionY, 
      int currentLevel, int coinsCollected, int health, String? lastCheckpoint, int duration) async {
    return await conn.query(
      '''INSERT INTO game_saves 
         (user_id, game_type, position_x, position_y, current_level, 
          coins_collected, health, last_checkpoint, duration)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        userId,
        gameType,
        positionX,
        positionY,
        currentLevel,
        coinsCollected,
        health,
        lastCheckpoint,
        duration,
      ],
    );
  }
  
  // Consultas para obtener partidas guardadas
  static Future<Results> getAdminSavedGameByType(MySqlConnection conn, int userId, int gameType) async {
    return await conn.query(
      'SELECT * FROM admin_game_saves WHERE admin_id = ? AND game_type = ? AND is_active = TRUE',
      [userId, gameType],
    );
  }
  
  static Future<Results> getAllAdminSavedGames(MySqlConnection conn, int userId) async {
    return await conn.query(
      'SELECT * FROM admin_game_saves WHERE admin_id = ? AND is_active = TRUE',
      [userId],
    );
  }
  
  static Future<Results> getUserSavedGameByType(MySqlConnection conn, int userId, int gameType) async {
    return await conn.query(
      'SELECT * FROM game_saves WHERE user_id = ? AND game_type = ? AND is_active = TRUE',
      [userId, gameType],
    );
  }
  
  static Future<Results> getAllUserSavedGames(MySqlConnection conn, int userId) async {
    return await conn.query(
      'SELECT * FROM game_saves WHERE user_id = ? AND is_active = TRUE',
      [userId],
    );
  }
  
  // Consultas para eliminar partidas guardadas
  static Future<Results> deleteAllAdminSavedGames(MySqlConnection conn, int userId) async {
    return await conn.query(
      'DELETE FROM admin_game_saves WHERE admin_id = ?',
      [userId],
    );
  }
  
  static Future<Results> deleteAllUserSavedGames(MySqlConnection conn, int userId) async {
    return await conn.query(
      'DELETE FROM game_saves WHERE user_id = ?',
      [userId],
    );
  }
  
  static Future<Results> deleteAdminGameSaveByType(MySqlConnection conn, int userId, int gameType) async {
    return await conn.query(
      'DELETE FROM admin_game_saves WHERE admin_id = ? AND game_type = ?',
      [userId, gameType],
    );
  }
  
  static Future<Results> deleteUserGameSaveByType(MySqlConnection conn, int userId, int gameType) async {
    return await conn.query(
      'DELETE FROM game_saves WHERE user_id = ? AND game_type = ?',
      [userId, gameType],
    );
  }
}