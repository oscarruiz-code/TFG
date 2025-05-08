import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class UserService {
  Future<int> createUser(String username, String email, String password) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var result = await conn.query(
        'INSERT INTO users (username, email, password, role) VALUES (?, ?, ?, ?)',
        [username, email, password, 'user']
      );
      
      int userId = result.insertId ?? -1;
      
      // Crear el registro en player_stats
      if (userId != -1) {
        await conn.query(
          'INSERT INTO player_stats (user_id) VALUES (?)',
          [userId]
        );
      }
      
      return userId;
    } finally {
      await conn.close();
    }
  }

  Future<bool> checkUser(String username, String password) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Verificar en ambas tablas
      var userResults = await conn.query(
        'SELECT * FROM users WHERE username = ? AND password = ? AND is_active = TRUE',
        [username, password]
      );
      
      if (userResults.isNotEmpty) {
        return true;
      }
      
      var adminResults = await conn.query(
        'SELECT * FROM admins WHERE username = ? AND password = ? AND is_active = TRUE',
        [username, password]
      );
      
      return adminResults.isNotEmpty;
    } finally {
      await conn.close();
    }
  }

  Future<bool> usernameExists(String username) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Verificar en la tabla de usuarios
      var userResults = await conn.query(
        'SELECT * FROM users WHERE username = ?',
        [username]
      );
      
      if (userResults.isNotEmpty) {
        return true;
      }
      
      // Verificar en la tabla de admins
      var adminResults = await conn.query(
        'SELECT * FROM admins WHERE username = ?',
        [username]
      );
      
      return adminResults.isNotEmpty;
    } finally {
      await conn.close();
    }
  }

  Future<Map<String, dynamic>?> checkUserAndGetInfo(String username, String password) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Primero buscar en la tabla de users y verificar si está bloqueado
      var userResults = await conn.query(
        'SELECT id, username, role, is_blocked FROM users WHERE username = ? AND password = ? AND is_active = TRUE',
        [username, password],
      );
      
      if (userResults.isNotEmpty) {
        if (userResults.first['is_blocked'] == 1) {
          return null; // Usuario bloqueado
        }
        return {
          'id': userResults.first['id'],
          'username': userResults.first['username'],
          'role': userResults.first['role'] ?? 'user',
        };
      }

      return null;
    } finally {
      await conn.close();
    }
  }

  Future<Map<String, dynamic>?> checkAdminAndGetInfo(String username, String password) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var adminResults = await conn.query(
        'SELECT id, username, role FROM admins WHERE username = ? AND password = ? AND is_active = TRUE',
        [username, password],
      );
      
      if (adminResults.isNotEmpty) {
        return {
          'id': adminResults.first['id'],
          'username': adminResults.first['username'],
          'role': adminResults.first['role'] ?? 'admin',
        };
      }

      return null;
    } finally {
      await conn.close();
    }
  }

  Future<void> updatePassword(int userId, String newPassword) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Intentar actualizar en la tabla de usuarios
      var userResult = await conn.query(
        'UPDATE users SET password = ? WHERE id = ?',
        [newPassword, userId],
      );
      
      // Si no se actualizó ningún usuario, intentar en la tabla de admins
      if (userResult.affectedRows == 0) {
        await conn.query(
          'UPDATE admins SET password = ? WHERE id = ?',
          [newPassword, userId],
        );
      }
    } finally {
      await conn.close();
    }
  }
}