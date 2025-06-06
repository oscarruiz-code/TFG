import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class UserService {
  Future<int> createUser(String username, String email, String password) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var result = await UserQueryRepository.insertUser(conn, username, email, password);
      
      int userId = result.insertId ?? -1;
      
      // Crear el registro en player_stats
      if (userId != -1) {
        await UserQueryRepository.insertPlayerStats(conn, userId);
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
      var userResults = await UserQueryRepository.checkUserCredentials(conn, username, password);
      
      if (userResults.isNotEmpty) {
        return true;
      }
      
      var adminResults = await UserQueryRepository.checkAdminCredentials(conn, username, password);
      
      return adminResults.isNotEmpty;
    } finally {
      await conn.close();
    }
  }

  Future<bool> usernameExists(String username) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Verificar en la tabla de usuarios
      var userResults = await UserQueryRepository.checkUsernameInUsers(conn, username);
      
      if (userResults.isNotEmpty) {
        return true;
      }
      
      // Verificar en la tabla de admins
      var adminResults = await UserQueryRepository.checkUsernameInAdmins(conn, username);
      
      return adminResults.isNotEmpty;
    } finally {
      await conn.close();
    }
  }

  Future<Map<String, dynamic>?> checkUserAndGetInfo(String username, String password) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Primero buscar en la tabla de users y verificar si está bloqueado
      var userResults = await UserQueryRepository.getUserInfo(conn, username, password);
      
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
      var adminResults = await UserQueryRepository.getAdminInfo(conn, username, password);
      
      if (adminResults.isNotEmpty) {
        // Verificar si el administrador está bloqueado
        if (adminResults.first['is_blocked'] == 1) {
          return null; // Administrador bloqueado
        }
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
      var userResult = await UserQueryRepository.updateUserPassword(conn, userId, newPassword);
      
      // Si no se actualizó ningún usuario, intentar en la tabla de admins
      if (userResult.affectedRows == 0) {
        await UserQueryRepository.updateAdminPassword(conn, userId, newPassword);
      }
    } finally {
      await conn.close();
    }
  }
}