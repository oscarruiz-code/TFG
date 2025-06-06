import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class AdminService {
  Future<List<User>> getAllUsers() async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Obtener usuarios regulares
      var userResults = await AdminQueryRepository.getAllUsers(conn);
      var users = userResults.map((row) => User.fromMap(row.fields)).toList();
      
      // Obtener administradores
      var adminResults = await AdminQueryRepository.getAllAdmins(conn);
      var admins = adminResults.map((row) => User.fromMap(row.fields)).toList();
      
      // Combinar ambas listas
      return [...users, ...admins];
    } finally {
      await conn.close();
    }
  }

  Future<User> getUserById(int userId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Primero buscar en la tabla admins
      var results = await AdminQueryRepository.getAdminById(conn, userId);
      
      // Si no se encuentra en admins, buscar en users
      if (results.isEmpty) {
        results = await AdminQueryRepository.getUserById(conn, userId);
        if (results.isEmpty) {
          throw Exception('Usuario no encontrado');
        }
      }
      
      return User.fromMap(results.first.fields);
    } finally {
      await conn.close();
    }
  }

  Future<void> blockUser(int userId, bool block, {int? loggedUserId, String? loggedUserRole}) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Verificar permisos
      if (loggedUserId != null && loggedUserRole != null) {
        // Obtener información del usuario a bloquear
        User targetUser = await getUserById(userId);
        bool isSuperAdmin = loggedUserId == 8; // El superadmin es el ID 8
        
        // Regla 1: Un subadmin puede bloquear usuarios y otros subadmins
        if (loggedUserRole == 'subadmin' && targetUser.role == 'admin') {
          throw Exception('No tienes permisos para bloquear a un administrador');
        }
        
        // Regla 2: Solo el superadmin puede bloquear a otros administradores
        if (targetUser.role == 'admin' && !isSuperAdmin) {
          throw Exception('Solo el superadmin puede bloquear a un administrador');
        }
        
        // Regla 3: Nadie puede bloquear al superadmin
        if (userId == 8 && loggedUserId != 8) {
          throw Exception('No se puede bloquear al superadmin');
        }
      }
      
      // Determinar en qué tabla está el usuario
      var adminResults = await AdminQueryRepository.getAdminById(conn, userId);
      
      if (adminResults.isNotEmpty) {
        // Es un admin o subadmin
        await AdminQueryRepository.blockAdmin(conn, userId, block);
      } else {
        // Es un usuario regular
        await AdminQueryRepository.blockUser(conn, userId, block);
      }
    } finally {
      await conn.close();
    }
  }

  Future<void> updateUserRole(int userId, String newRole, {int? loggedUserId, String? loggedUserRole}) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Obtener información del usuario actual
      String currentRole;
      Map<String, dynamic> userData;
      
      // Primero buscar en la tabla admins
      var adminResults = await AdminQueryRepository.getAdminById(conn, userId);
      
      if (adminResults.isNotEmpty) {
        userData = adminResults.first.fields;
        currentRole = userData['role'];
      } else {
        // Si no está en admins, buscar en users
        var userResults = await AdminQueryRepository.getUserById(conn, userId);
        
        if (userResults.isEmpty) {
          throw Exception('Usuario no encontrado');
        }
        
        userData = userResults.first.fields;
        currentRole = userData['role'];
      }
      
      // Si el rol no ha cambiado, no hacer nada
      if (currentRole == newRole) {
        return;
      }
      
      // Verificar permisos de cambio de rol
      if (loggedUserId != null && loggedUserRole != null) {
        bool isSuperAdmin = loggedUserId == 8; // El superadmin es el ID 8
        
        // Regla 1: Un subadmin solo puede promover usuarios a subadmin y degradar subadmins a user
        if (loggedUserRole == 'subadmin') {
          // No puede promover a admin
          if (newRole == 'admin') {
            throw Exception('No tienes permisos para promover a administrador');
          }
          
          // No puede modificar a un admin
          if (currentRole == 'admin') {
            throw Exception('No tienes permisos para modificar a un administrador');
          }
        }
        
        // Regla 2: Solo el superadmin puede degradar a un admin a subadmin o a user
        if (currentRole == 'admin' && (newRole == 'subadmin' || newRole == 'user') && !isSuperAdmin) {
          throw Exception('Solo el superadmin puede degradar a un administrador');
        }
        
        // Regla 3: Un admin normal puede modificar a cualquier usuario excepto a otros admins
        if (loggedUserRole == 'admin' && !isSuperAdmin && currentRole == 'admin' && loggedUserId != userId) {
          throw Exception('Solo el superadmin puede modificar a otros administradores');
        }
        
        // Regla 4: Nadie puede modificar al superadmin excepto él mismo
        if (userId == 8 && loggedUserId != 8) {
          throw Exception('No se puede modificar al superadmin');
        }
      }
      
      // Cambio entre admin y subadmin (misma tabla)
      if ((currentRole == 'admin' || currentRole == 'subadmin') && 
          (newRole == 'admin' || newRole == 'subadmin')) {
        await AdminQueryRepository.updateAdminRole(conn, userId, newRole);
        return;
      }
      
      // Cambio de user a admin/subadmin
      if (currentRole == 'user' && (newRole == 'admin' || newRole == 'subadmin')) {
        // Obtener datos del usuario
        var playerStatsResults = await AdminQueryRepository.getPlayerStats(conn, userId);
        
        if (playerStatsResults.isEmpty) {
          throw Exception('Estadísticas de jugador no encontradas');
        }
        
        var playerStatsData = playerStatsResults.first.fields;
        
        // Obtener historial de juegos
        var gameHistoryResults = await AdminQueryRepository.getGameHistory(conn, userId);
        
        // Obtener partidas guardadas
        var gameSavesResults = await AdminQueryRepository.getGameSaves(conn, userId);
        
        // Insertar en la tabla admins
        await AdminQueryRepository.insertAdmin(
          conn, 
          userId,
          userData['username'],
          userData['email'],
          userData['password'],
          userData['is_active'] == 1,
          newRole
        );
        
        // Transferir estadísticas a admin_stats
        await AdminQueryRepository.insertAdminStats(
          conn,
          userId,
          playerStatsData['tickets_game2'],
          playerStatsData['coins'],
          playerStatsData['rename_tickets'],
          playerStatsData['has_used_free_rename'],
          playerStatsData['current_avatar'],
          playerStatsData['unlocked_premium_avatars']
        );
        
        // Transferir historial de juegos a admin_game_history
        for (var gameHistory in gameHistoryResults) {
          await AdminQueryRepository.insertAdminGameHistory(
            conn,
            userId,
            gameHistory.fields['game_type'],
            gameHistory.fields['score'],
            gameHistory.fields['coins'],
            gameHistory.fields['victory'],
            gameHistory.fields['duration'],
            gameHistory.fields['played_at']
          );
        }
        
        // Transferir partidas guardadas a admin_game_saves
        for (var gameSave in gameSavesResults) {
          await AdminQueryRepository.insertAdminGameSave(
            conn,
            userId,
            gameSave.fields['game_type'],
            gameSave.fields['position_x'],
            gameSave.fields['position_y'],
            gameSave.fields['world_offset'],
            gameSave.fields['current_level'],
            gameSave.fields['collected_coins_positions'],
            gameSave.fields['coins_collected'],
            gameSave.fields['health'],
            gameSave.fields['last_checkpoint'],
            gameSave.fields['duration'],
            gameSave.fields['created_at'],
            gameSave.fields['updated_at'],
            gameSave.fields['is_active'] == 1
          );
        }
        
        // Eliminar de la tabla users y tablas relacionadas
        await AdminQueryRepository.deleteGameHistory(conn, userId);
        await AdminQueryRepository.deleteGameSaves(conn, userId);
        await AdminQueryRepository.deletePlayerStats(conn, userId);
        await AdminQueryRepository.deleteUser(conn, userId);
      } 
      // Cambio de admin/subadmin a user
      else if ((currentRole == 'admin' || currentRole == 'subadmin') && newRole == 'user') {
        // Obtener estadísticas del admin
        var adminStatsResults = await AdminQueryRepository.getAdminStats(conn, userId);
        
        if (adminStatsResults.isEmpty) {
          throw Exception('Estadísticas de administrador no encontradas');
        }
        
        var adminStatsData = adminStatsResults.first.fields;
        
        // Obtener historial de juegos del admin
        var adminGameHistoryResults = await AdminQueryRepository.getAdminGameHistory(conn, userId);
        
        // Obtener partidas guardadas del admin
        var adminGameSavesResults = await AdminQueryRepository.getAdminGameSaves(conn, userId);
        
        // Insertar en la tabla users
        await AdminQueryRepository.insertUser(
          conn,
          userId,
          userData['username'],
          userData['email'],
          userData['password'],
          false, // is_blocked
          userData['is_active'] == 1,
          newRole
        );
        
        // Transferir estadísticas a player_stats
        await AdminQueryRepository.insertPlayerStats(
          conn,
          userId,
          adminStatsData['tickets_game2'],
          adminStatsData['coins'],
          adminStatsData['rename_tickets'],
          adminStatsData['has_used_free_rename'],
          adminStatsData['current_avatar'],
          adminStatsData['unlocked_premium_avatars']
        );
        
        // Transferir historial de juegos a game_history
        for (var gameHistory in adminGameHistoryResults) {
          await AdminQueryRepository.insertGameHistory(
            conn,
            userId,
            gameHistory.fields['game_type'],
            gameHistory.fields['score'],
            gameHistory.fields['coins'],
            gameHistory.fields['victory'],
            gameHistory.fields['duration'],
            gameHistory.fields['played_at']
          );
        }
        
        // Transferir partidas guardadas a game_saves
        for (var gameSave in adminGameSavesResults) {
          await AdminQueryRepository.insertGameSave(
            conn,
            userId,
            gameSave.fields['game_type'],
            gameSave.fields['position_x'],
            gameSave.fields['position_y'],
            gameSave.fields['world_offset'],
            gameSave.fields['current_level'],
            gameSave.fields['collected_coins_positions'],
            gameSave.fields['coins_collected'],
            gameSave.fields['health'],
            gameSave.fields['last_checkpoint'],
            gameSave.fields['duration'],
            gameSave.fields['created_at'],
            gameSave.fields['updated_at'],
            gameSave.fields['is_active'] == 1
          );
        }
        
        // Eliminar de la tabla admins y tablas relacionadas
        await AdminQueryRepository.deleteAdminGameHistory(conn, userId);
        await AdminQueryRepository.deleteAdminGameSaves(conn, userId);
        await AdminQueryRepository.deleteAdminStats(conn, userId);
        await AdminQueryRepository.deleteAdmin(conn, userId);
      }
    } finally {
      await conn.close();
    }
  }

  Future<void> deleteUser(int userId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await AdminQueryRepository.deleteUser(conn, userId);
    } finally {
      await conn.close();
    }
  }

  Future<void> updateUserInfo(int userId, String username, String email) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await AdminQueryRepository.updateUserInfo(conn, userId, username, email);
    } finally {
      await conn.close();
    }
  }

  Future<int> registerUser({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var result = await AdminQueryRepository.registerUser(conn, username, email, password, role);
      // Return the inserted user's ID
      return result.insertId!;
    } finally {
      await conn.close();
    }
  }

  Future<User> getAdminById(int adminId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var results = await AdminQueryRepository.getAdminById(conn, adminId);
      if (results.isEmpty) {
        throw Exception('Administrador no encontrado');
      }
      return User.fromMap(results.first.fields);
    } finally {
      await conn.close();
    }
  }

  Future<int> registerAdmin({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var result = await AdminQueryRepository.registerAdmin(conn, username, email, password, role);
      return result.insertId!;
    } finally {
      await conn.close();
    }
  }

  Future<void> createAdminStats(int adminId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await AdminQueryRepository.createAdminStats(conn, adminId);
    } finally {
      await conn.close();
    }
  }

  Future<PlayerStats> getAdminStats(int adminId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var results = await AdminQueryRepository.getAdminStats(conn, adminId);

      if (results.isEmpty) {
        await createAdminStats(adminId);
        results = await AdminQueryRepository.getAdminStats(conn, adminId);
      }

      return PlayerStats.fromMap(results.first.fields);
    } finally {
      await conn.close();
    }
  }

  Future<void> updateUser(int userId, String username, String email, String newRole) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Verificar si el usuario existe y obtener su rol actual
      var userResults = await AdminQueryRepository.getUserRole(conn, userId);
      
      if (userResults.isEmpty) {
        throw Exception('Usuario no encontrado');
      }

      String currentRole = userResults.first.fields['role'];

      // Si el rol ha cambiado, manejar la transición
      if (currentRole != newRole) {
        if (newRole == 'admin' || newRole == 'subadmin') {
          // Mover de users a admins
          var userData = await AdminQueryRepository.getUserById(conn, userId);
          if (userData.isNotEmpty) {
            await AdminQueryRepository.insertAdmin(
              conn, 
              userId, 
              username, 
              email, 
              userData.first.fields['password'], 
              true, // is_active
              newRole
            );
            await AdminQueryRepository.deleteUser(conn, userId);
          }
        } else {
          // Mover de admins a users
          var adminData = await AdminQueryRepository.getAdminById(conn, userId);
          if (adminData.isNotEmpty) {
            await AdminQueryRepository.insertUser(
              conn, 
              userId, 
              username, 
              email, 
              adminData.first.fields['password'], 
              false, // is_blocked
              true, // is_active
              newRole
            );
            await AdminQueryRepository.deleteAdmin(conn, userId);
          }
        }
      } else {
        // Solo actualizar datos sin cambiar rol
        String table = (newRole == 'admin' || newRole == 'subadmin') ? 'admins' : 'users';
        await AdminQueryRepository.updateTableUserInfo(conn, table, userId, username, email);
      }
    } finally {
      await conn.close();
    }
  }

  Future<void> updateAdminStats(int adminId, int renameTickets, int coins, int ticketsGame2) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await AdminQueryRepository.updateAdminStats(conn, adminId, renameTickets, coins, ticketsGame2);
    } finally {
      await conn.close();
    }
  }
}