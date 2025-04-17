import '../conexion/mysql_connection.dart';

class UserService {
  Future<int> createUser(String username, String password) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var result = await conn.query(
        'INSERT INTO users (username, password) VALUES (?, ?)',
        [username, password]
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
}