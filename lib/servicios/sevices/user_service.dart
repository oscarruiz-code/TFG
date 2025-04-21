import '../conexion/mysql_connection.dart';

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
      var results = await conn.query(
        'SELECT id, username FROM users WHERE username = ? AND password = ?',
        [username, password],
      );
      
      if (results.isNotEmpty) {
        return {
          'id': results.first['id'],  // Changed from 'userId' to 'id'
          'username': results.first['username'],
        };
      }
      return null;
    } finally {
      await conn.close();
    }
  }
}