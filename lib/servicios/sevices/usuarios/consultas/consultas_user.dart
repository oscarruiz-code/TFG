import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class UserQueryRepository {
  // Consultas para usuarios
  static Future<Results> insertUser(MySqlConnection conn, String username, String email, String password) async {
    return await conn.query(
      'INSERT INTO users (username, email, password, role) VALUES (?, ?, ?, ?)',
      [username, email, password, 'user']
    );
  }
  
  static Future<void> insertPlayerStats(MySqlConnection conn, int userId) async {
    await conn.query(
      'INSERT INTO player_stats (user_id) VALUES (?)',
      [userId]
    );
  }
  
  static Future<Results> checkUserCredentials(MySqlConnection conn, String username, String password) async {
    return await conn.query(
      'SELECT * FROM users WHERE username = ? AND password = ? AND is_active = TRUE',
      [username, password]
    );
  }
  
  static Future<Results> checkAdminCredentials(MySqlConnection conn, String username, String password) async {
    return await conn.query(
      'SELECT * FROM admins WHERE username = ? AND password = ? AND is_active = TRUE',
      [username, password]
    );
  }
  
  static Future<Results> checkUsernameInUsers(MySqlConnection conn, String username) async {
    return await conn.query(
      'SELECT * FROM users WHERE username = ?',
      [username]
    );
  }
  
  static Future<Results> checkUsernameInAdmins(MySqlConnection conn, String username) async {
    return await conn.query(
      'SELECT * FROM admins WHERE username = ?',
      [username]
    );
  }
  
  static Future<Results> getUserInfo(MySqlConnection conn, String username, String password) async {
    return await conn.query(
      'SELECT id, username, role, is_blocked FROM users WHERE username = ? AND password = ? AND is_active = TRUE',
      [username, password]
    );
  }
  
  static Future<Results> getAdminInfo(MySqlConnection conn, String username, String password) async {
    return await conn.query(
      'SELECT id, username, role, is_blocked FROM admins WHERE username = ? AND password = ? AND is_active = TRUE',
      [username, password]
    );
  }
  
  static Future<Results> updateUserPassword(MySqlConnection conn, int userId, String newPassword) async {
    return await conn.query(
      'UPDATE users SET password = ? WHERE id = ?',
      [newPassword, userId]
    );
  }
  
  static Future<Results> updateAdminPassword(MySqlConnection conn, int userId, String newPassword) async {
    return await conn.query(
      'UPDATE admins SET password = ? WHERE id = ?',
      [newPassword, userId]
    );
  }
}