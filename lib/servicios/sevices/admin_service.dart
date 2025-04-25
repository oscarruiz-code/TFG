import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class AdminService {
  Future<List<User>> getAllUsers() async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var results = await conn.query('SELECT * FROM users');
      return results.map((row) => User.fromMap(row.fields)).toList();
    } finally {
      await conn.close();
    }
  }

  Future<User> getUserById(int userId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var results = await conn.query('SELECT * FROM users WHERE id = ?', [userId]);
      if (results.isEmpty) {
        throw Exception('Usuario no encontrado');
      }
      return User.fromMap(results.first.fields);
    } finally {
      await conn.close();
    }
  }

  Future<void> blockUser(int userId, bool block) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await conn.query(
        'UPDATE users SET is_blocked = ? WHERE id = ?',
        [block ? 1 : 0, userId],
      );
    } finally {
      await conn.close();
    }
  }

  Future<void> updateUserRole(int userId, String newRole) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await conn.query(
        'UPDATE users SET role = ? WHERE id = ?',
        [newRole, userId],
      );
    } finally {
      await conn.close();
    }
  }

  Future<void> deleteUser(int userId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await conn.query('DELETE FROM users WHERE id = ?', [userId]);
    } finally {
      await conn.close();
    }
  }

  Future<void> updateUserInfo(int userId, String username, String email) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await conn.query(
        'UPDATE users SET username = ?, email = ? WHERE id = ?',
        [username, email, userId],
      );
    } finally {
      await conn.close();
    }
  }

  Future<void> registerUser({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await conn.query(
        'INSERT INTO users (username, email, password, role) VALUES (?, ?, ?, ?)',
        [username, email, password, role],
      );
    } finally {
      await conn.close();
    }
  }
}