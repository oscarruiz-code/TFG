import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class UserService {
  Future<int> createUser(String username, String email, String password) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var result = await conn.query(
        'INSERT INTO users (username, email, password) VALUES (?, ?, ?)',
        [username, email, password]
      );
      return result.insertId ?? -1;
    } finally {
      await conn.close();
    }
  }

  Future<bool> checkUser(String username, String password) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var results = await conn.query(
        'SELECT * FROM users WHERE username = ? AND password = ?',
        [username, password]
      );
      return results.isNotEmpty;
    } finally {
      await conn.close();
    }
  }

  Future<bool> usernameExists(String username) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var results = await conn.query(
        'SELECT * FROM users WHERE username = ?',
        [username]
      );
      return results.isNotEmpty;
    } finally {
      await conn.close();
    }
  }

  Future<Map<String, dynamic>?> checkUserAndGetInfo(String username, String password) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Primero buscar en la tabla de admins
      var adminResults = await conn.query(
        'SELECT id, username, role FROM admins WHERE username = ? AND password = ?',
        [username, password],
      );
      
      if (adminResults.isNotEmpty) {
        return {
          'id': adminResults.first['id'],
          'username': adminResults.first['username'],
          'role': adminResults.first['role'] ?? 'admin',
        };
      }

      // Si no se encuentra en admins, buscar en users y verificar si está bloqueado
      var userResults = await conn.query(
        'SELECT id, username, role, is_blocked FROM users WHERE username = ? AND password = ?',
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

  Future<void> updatePassword(int userId, String newPassword) async {
      final conn = await DatabaseConnection.getConnection();
      try {
          await conn.query(
              'UPDATE users SET password = ? WHERE id = ?',
              [newPassword, userId],
          );
      } finally {
          await conn.close();
      }
  }
}