import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class AdminQueryRepository {
  // Consultas para obtener usuarios
  static Future<Results> getAllUsers(MySqlConnection conn) async {
    return await conn.query('SELECT * FROM users');
  }
  
  static Future<Results> getAllAdmins(MySqlConnection conn) async {
    return await conn.query('SELECT * FROM admins');
  }
  
  // Consultas para obtener usuario por ID
  static Future<Results> getUserById(MySqlConnection conn, int userId) async {
    return await conn.query('SELECT * FROM users WHERE id = ?', [userId]);
  }
  
  static Future<Results> getAdminById(MySqlConnection conn, int userId) async {
    return await conn.query('SELECT * FROM admins WHERE id = ?', [userId]);
  }
  
  // Consultas para bloquear/desbloquear usuarios
  static Future<Results> blockAdmin(MySqlConnection conn, int userId, bool block) async {
    return await conn.query(
      'UPDATE admins SET is_blocked = ? WHERE id = ?',
      [block ? 1 : 0, userId],
    );
  }
  
  static Future<Results> blockUser(MySqlConnection conn, int userId, bool block) async {
    return await conn.query(
      'UPDATE users SET is_blocked = ? WHERE id = ?',
      [block ? 1 : 0, userId],
    );
  }
  
  // Consultas para actualizar rol de usuario
  static Future<Results> updateAdminRole(MySqlConnection conn, int userId, String newRole) async {
    return await conn.query(
      'UPDATE admins SET role = ? WHERE id = ?',
      [newRole, userId],
    );
  }
  
  // Consultas para obtener datos de usuario para cambio de rol
  static Future<Results> getPlayerStats(MySqlConnection conn, int userId) async {
    return await conn.query(
      'SELECT * FROM player_stats WHERE user_id = ?',
      [userId],
    );
  }
  
  static Future<Results> getGameHistory(MySqlConnection conn, int userId) async {
    return await conn.query(
      'SELECT * FROM game_history WHERE user_id = ?',
      [userId],
    );
  }
  
  static Future<Results> getGameSaves(MySqlConnection conn, int userId) async {
    return await conn.query(
      'SELECT * FROM game_saves WHERE user_id = ?',
      [userId],
    );
  }
  
  // Consultas para insertar usuario como admin
  static Future<Results> insertAdmin(MySqlConnection conn, int userId, String username, 
      String email, String password, bool isActive, String role) async {
    return await conn.query(
      'INSERT INTO admins (id, username, email, password, is_active, role) VALUES (?, ?, ?, ?, ?, ?)',
      [userId, username, email, password, isActive ? 1 : 0, role],
    );
  }
  
  // Consultas para transferir estadísticas a admin_stats
  static Future<Results> insertAdminStats(MySqlConnection conn, int userId, int ticketsGame2, 
      int coins, int renameTickets, int hasUsedFreeRename, String currentAvatar, 
      String unlockedPremiumAvatars) async {
    return await conn.query(
      '''INSERT INTO admin_stats 
         (admin_id, tickets_game2, coins, rename_tickets, has_used_free_rename, 
          current_avatar, unlocked_premium_avatars) 
         VALUES (?, ?, ?, ?, ?, ?, ?)''',
      [userId, ticketsGame2, coins, renameTickets, hasUsedFreeRename, currentAvatar, unlockedPremiumAvatars],
    );
  }
  
  // Consultas para transferir historial de juegos a admin_game_history
  static Future<Results> insertAdminGameHistory(MySqlConnection conn, int userId, int gameType, 
      int score, int coins, int victory, int duration, DateTime playedAt) async {
    return await conn.query(
      '''INSERT INTO admin_game_history 
         (admin_id, game_type, score, coins, victory, duration, played_at) 
         VALUES (?, ?, ?, ?, ?, ?, ?)''',
      [userId, gameType, score, coins, victory, duration, playedAt],
    );
  }
  
  // Consultas para transferir partidas guardadas a admin_game_saves
  static Future<Results> insertAdminGameSave(MySqlConnection conn, int userId, int gameType, 
      double positionX, double positionY, double worldOffset, int currentLevel, 
      String collectedCoinsPositions, int coinsCollected, int health, int lastCheckpoint, 
      int duration, DateTime createdAt, DateTime updatedAt, bool isActive) async {
    return await conn.query(
      '''INSERT INTO admin_game_saves 
         (admin_id, game_type, position_x, position_y, world_offset, 
          current_level, collected_coins_positions, coins_collected, 
          health, last_checkpoint, duration, created_at, updated_at, is_active) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        userId, gameType, positionX, positionY, worldOffset, currentLevel, 
        collectedCoinsPositions, coinsCollected, health, lastCheckpoint, 
        duration, createdAt, updatedAt, isActive ? 1 : 0
      ],
    );
  }
  
  // Consultas para eliminar datos de usuario al cambiar rol
  static Future<Results> deleteGameHistory(MySqlConnection conn, int userId) async {
    return await conn.query('DELETE FROM game_history WHERE user_id = ?', [userId]);
  }
  
  static Future<Results> deleteGameSaves(MySqlConnection conn, int userId) async {
    return await conn.query('DELETE FROM game_saves WHERE user_id = ?', [userId]);
  }
  
  static Future<Results> deletePlayerStats(MySqlConnection conn, int userId) async {
    return await conn.query('DELETE FROM player_stats WHERE user_id = ?', [userId]);
  }
  
  static Future<Results> deleteUser(MySqlConnection conn, int userId) async {
    return await conn.query('DELETE FROM users WHERE id = ?', [userId]);
  }
  
  // Consultas para obtener datos de admin para cambio de rol
  static Future<Results> getAdminStats(MySqlConnection conn, int userId) async {
    return await conn.query(
      'SELECT * FROM admin_stats WHERE admin_id = ?',
      [userId],
    );
  }
  
  static Future<Results> getAdminGameHistory(MySqlConnection conn, int userId) async {
    return await conn.query(
      'SELECT * FROM admin_game_history WHERE admin_id = ?',
      [userId],
    );
  }
  
  static Future<Results> getAdminGameSaves(MySqlConnection conn, int userId) async {
    return await conn.query(
      'SELECT * FROM admin_game_saves WHERE admin_id = ?',
      [userId],
    );
  }
  
  // Consultas para insertar usuario desde admin
  static Future<Results> insertUser(MySqlConnection conn, int userId, String username, 
      String email, String password, bool isBlocked, bool isActive, String role) async {
    return await conn.query(
      'INSERT INTO users (id, username, email, password, is_blocked, is_active, role) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [userId, username, email, password, isBlocked ? 1 : 0, isActive ? 1 : 0, role],
    );
  }
  
  // Consultas para transferir estadísticas a player_stats
  static Future<Results> insertPlayerStats(MySqlConnection conn, int userId, int ticketsGame2, 
      int coins, int renameTickets, int hasUsedFreeRename, String currentAvatar, 
      String unlockedPremiumAvatars) async {
    return await conn.query(
      '''INSERT INTO player_stats 
         (user_id, tickets_game2, coins, rename_tickets, has_used_free_rename, 
          current_avatar, unlocked_premium_avatars) 
         VALUES (?, ?, ?, ?, ?, ?, ?)''',
      [userId, ticketsGame2, coins, renameTickets, hasUsedFreeRename, currentAvatar, unlockedPremiumAvatars],
    );
  }
  
  // Consultas para transferir historial de juegos a game_history
  static Future<Results> insertGameHistory(MySqlConnection conn, int userId, int gameType, 
      int score, int coins, int victory, int duration, DateTime playedAt) async {
    return await conn.query(
      '''INSERT INTO game_history 
         (user_id, game_type, score, coins, victory, duration, played_at) 
         VALUES (?, ?, ?, ?, ?, ?, ?)''',
      [userId, gameType, score, coins, victory, duration, playedAt],
    );
  }
  
  // Consultas para transferir partidas guardadas a game_saves
  static Future<Results> insertGameSave(MySqlConnection conn, int userId, int gameType, 
      double positionX, double positionY, double worldOffset, int currentLevel, 
      String collectedCoinsPositions, int coinsCollected, int health, int lastCheckpoint, 
      int duration, DateTime createdAt, DateTime updatedAt, bool isActive) async {
    return await conn.query(
      '''INSERT INTO game_saves 
         (user_id, game_type, position_x, position_y, world_offset, 
          current_level, collected_coins_positions, coins_collected, 
          health, last_checkpoint, duration, created_at, updated_at, is_active) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        userId, gameType, positionX, positionY, worldOffset, currentLevel, 
        collectedCoinsPositions, coinsCollected, health, lastCheckpoint, 
        duration, createdAt, updatedAt, isActive ? 1 : 0
      ],
    );
  }
  
  // Consultas para eliminar datos de admin al cambiar rol
  static Future<Results> deleteAdminGameHistory(MySqlConnection conn, int userId) async {
    return await conn.query('DELETE FROM admin_game_history WHERE admin_id = ?', [userId]);
  }
  
  static Future<Results> deleteAdminGameSaves(MySqlConnection conn, int userId) async {
    return await conn.query('DELETE FROM admin_game_saves WHERE admin_id = ?', [userId]);
  }
  
  static Future<Results> deleteAdminStats(MySqlConnection conn, int userId) async {
    return await conn.query('DELETE FROM admin_stats WHERE admin_id = ?', [userId]);
  }
  
  static Future<Results> deleteAdmin(MySqlConnection conn, int userId) async {
    return await conn.query('DELETE FROM admins WHERE id = ?', [userId]);
  }
  
  // Consultas para actualizar información de usuario
  static Future<Results> updateUserInfo(MySqlConnection conn, int userId, String username, String email) async {
    return await conn.query(
      'UPDATE users SET username = ?, email = ? WHERE id = ?',
      [username, email, userId],
    );
  }
  
  // Consultas para registrar nuevo usuario
  static Future<Results> registerUser(MySqlConnection conn, String username, String email, 
      String password, String role) async {
    return await conn.query(
      'INSERT INTO users (username, email, password, role) VALUES (?, ?, ?, ?)',
      [username, email, password, role],
    );
  }
  
  // Consultas para registrar nuevo admin
  static Future<Results> registerAdmin(MySqlConnection conn, String username, String email, 
      String password, String role) async {
    return await conn.query(
      'INSERT INTO admins (username, email, password, role) VALUES (?, ?, ?, ?)',
      [username, email, password, role],
    );
  }
  
  // Consultas para crear estadísticas de admin
  static Future<Results> createAdminStats(MySqlConnection conn, int adminId) async {
    return await conn.query(
      'INSERT INTO admin_stats (admin_id) VALUES (?)',
      [adminId],
    );
  }
  
  // Consultas para actualizar estadísticas de admin
  static Future<Results> updateAdminStats(MySqlConnection conn, int adminId, int renameTickets, 
      int coins, int ticketsGame2) async {
    return await conn.query(
      'UPDATE admin_stats SET rename_tickets = ?, coins = ?, tickets_game2 = ? WHERE admin_id = ?',
      [renameTickets, coins, ticketsGame2, adminId],
    );
  }
  
  // Consultas para verificar y actualizar roles de usuario
  static Future<Results> getUserRole(MySqlConnection conn, int userId) async {
    return await conn.query(
      'SELECT role FROM users WHERE id = ? UNION SELECT role FROM admins WHERE id = ?',
      [userId, userId],
    );
  }
  
  static Future<Results> updateTableUserInfo(MySqlConnection conn, String table, int userId, 
      String username, String email) async {
    return await conn.query(
      'UPDATE $table SET username = ?, email = ? WHERE id = ?',
      [username, email, userId],
    );
  }
}