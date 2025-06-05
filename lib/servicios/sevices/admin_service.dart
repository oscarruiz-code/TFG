import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class AdminService {
  Future<List<User>> getAllUsers() async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Obtener usuarios regulares
      var userResults = await conn.query('SELECT * FROM users');
      var users = userResults.map((row) => User.fromMap(row.fields)).toList();
      
      // Obtener administradores
      var adminResults = await conn.query('SELECT * FROM admins');
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
      var results = await conn.query('SELECT * FROM admins WHERE id = ?', [userId]);
      
      // Si no se encuentra en admins, buscar en users
      if (results.isEmpty) {
        results = await conn.query('SELECT * FROM users WHERE id = ?', [userId]);
        if (results.isEmpty) {
          throw Exception('Usuario no encontrado');
        }
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
      // Obtener información del usuario actual
      var userResults = await conn.query(
        'SELECT * FROM users WHERE id = ?',
        [userId],
      );
      
      if (userResults.isEmpty) {
        throw Exception('Usuario no encontrado');
      }

      var userData = userResults.first.fields;

      // Obtener estadísticas del jugador antes de cambiar su rol
      var statsResults = await conn.query(
        'SELECT * FROM player_stats WHERE user_id = ?',
        [userId],
      );
      
      if (statsResults.isEmpty) {
        throw Exception('Estadísticas de usuario no encontradas');
      }
      
      var playerStatsData = statsResults.first.fields;

      // Obtener historial de juegos del usuario
      var gameHistoryResults = await conn.query(
        'SELECT * FROM game_history WHERE user_id = ?',
        [userId],
      );
      
      // Obtener partidas guardadas del usuario
      var gameSavesResults = await conn.query(
        'SELECT * FROM game_saves WHERE user_id = ?',
        [userId],
      );

      if (newRole == 'admin' || newRole == 'subadmin') {
        // Promover a admin/subadmin: mover de users a admins
        await conn.query(
          'INSERT INTO admins (username, email, password, role) VALUES (?, ?, ?, ?)',
          [userData['username'], userData['email'], userData['password'], newRole],
        );
        
        // Obtener el ID del nuevo admin
        var newAdminResults = await conn.query(
          'SELECT id FROM admins WHERE username = ?',
          [userData['username']],
        );
        
        if (newAdminResults.isEmpty) {
          throw Exception('Error al crear el administrador');
        }
        
        int newAdminId = newAdminResults.first.fields['id'];
        
        // Transferir estadísticas a admin_stats
        await conn.query(
          '''INSERT INTO admin_stats 
             (admin_id, tickets_game2, coins, rename_tickets, has_used_free_rename, 
              current_avatar, unlocked_premium_avatars, best_score, play_time, 
              world_offset, current_level, health, last_checkpoint) 
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
          [
            newAdminId,
            playerStatsData['tickets_game2'],
            playerStatsData['coins'],
            playerStatsData['rename_tickets'],
            playerStatsData['has_used_free_rename'],
            playerStatsData['current_avatar'],
            playerStatsData['unlocked_premium_avatars'],
            playerStatsData['best_score'],
            playerStatsData['play_time'],
            playerStatsData['world_offset'],
            playerStatsData['current_level'],
            playerStatsData['health'],
            playerStatsData['last_checkpoint'],
          ],
        );
        
        // Transferir historial de juegos a admin_game_history
        for (var gameHistory in gameHistoryResults) {
          await conn.query(
            '''INSERT INTO admin_game_history 
               (admin_id, game_type, score, coins, victory, duration, played_at) 
               VALUES (?, ?, ?, ?, ?, ?, ?)''',
            [
              newAdminId,
              gameHistory.fields['game_type'],
              gameHistory.fields['score'],
              gameHistory.fields['coins'],
              gameHistory.fields['victory'],
              gameHistory.fields['duration'],
              gameHistory.fields['played_at'],
            ],
          );
        }
        
        // Transferir partidas guardadas a admin_game_saves
        for (var gameSave in gameSavesResults) {
          await conn.query(
            '''INSERT INTO admin_game_saves 
               (admin_id, game_type, position_x, position_y, world_offset, 
                current_level, collected_coins_positions, coins_collected, 
                health, last_checkpoint, duration, created_at, updated_at, is_active) 
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
            [
              newAdminId,
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
              gameSave.fields['is_active'],
            ],
          );
        }
        
        // Eliminar de la tabla users y player_stats
        await conn.query('DELETE FROM game_history WHERE user_id = ?', [userId]);
        await conn.query('DELETE FROM game_saves WHERE user_id = ?', [userId]);
        await conn.query('DELETE FROM player_stats WHERE user_id = ?', [userId]);
        await conn.query('DELETE FROM users WHERE id = ?', [userId]);
      } else if (newRole == 'user') {
        // Obtener información del admin actual
        var adminResults = await conn.query(
          'SELECT * FROM admins WHERE username = ?',
          [userData['username']],
        );
        
        if (adminResults.isEmpty) {
          throw Exception('Administrador no encontrado');
        }
        
        var adminData = adminResults.first.fields;
        int adminId = adminData['id'];
        
        // Obtener estadísticas del admin
        var adminStatsResults = await conn.query(
          'SELECT * FROM admin_stats WHERE admin_id = ?',
          [adminId],
        );
        
        if (adminStatsResults.isEmpty) {
          throw Exception('Estadísticas de administrador no encontradas');
        }
        
        var adminStatsData = adminStatsResults.first.fields;
        
        // Obtener historial de juegos del admin
        var adminGameHistoryResults = await conn.query(
          'SELECT * FROM admin_game_history WHERE admin_id = ?',
          [adminId],
        );
        
        // Obtener partidas guardadas del admin
        var adminGameSavesResults = await conn.query(
          'SELECT * FROM admin_game_saves WHERE admin_id = ?',
          [adminId],
        );
        
        // Degradar a usuario: mover de admins a users
        await conn.query(
          'INSERT INTO users (username, email, password, role) VALUES (?, ?, ?, ?)',
          [adminData['username'], adminData['email'], adminData['password'], newRole],
        );
        
        // Obtener el ID del nuevo usuario
        var newUserResults = await conn.query(
          'SELECT id FROM users WHERE username = ?',
          [adminData['username']],
        );
        
        if (newUserResults.isEmpty) {
          throw Exception('Error al crear el usuario');
        }
        
        int newUserId = newUserResults.first.fields['id'];
        
        // Transferir estadísticas a player_stats
        await conn.query(
          '''INSERT INTO player_stats 
             (user_id, tickets_game2, coins, rename_tickets, has_used_free_rename, 
              current_avatar, unlocked_premium_avatars, best_score, play_time, 
              world_offset, current_level, health, last_checkpoint) 
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
          [
            newUserId,
            adminStatsData['tickets_game2'],
            adminStatsData['coins'],
            adminStatsData['rename_tickets'],
            adminStatsData['has_used_free_rename'],
            adminStatsData['current_avatar'],
            adminStatsData['unlocked_premium_avatars'],
            adminStatsData['best_score'],
            adminStatsData['play_time'],
            adminStatsData['world_offset'],
            adminStatsData['current_level'],
            adminStatsData['health'],
            adminStatsData['last_checkpoint'],
          ],
        );
        
        // Transferir historial de juegos a game_history
        for (var gameHistory in adminGameHistoryResults) {
          await conn.query(
            '''INSERT INTO game_history 
               (user_id, game_type, score, coins, victory, duration, played_at) 
               VALUES (?, ?, ?, ?, ?, ?, ?)''',
            [
              newUserId,
              gameHistory.fields['game_type'],
              gameHistory.fields['score'],
              gameHistory.fields['coins'],
              gameHistory.fields['victory'],
              gameHistory.fields['duration'],
              gameHistory.fields['played_at'],
            ],
          );
        }
        
        // Transferir partidas guardadas a game_saves
        for (var gameSave in adminGameSavesResults) {
          await conn.query(
            '''INSERT INTO game_saves 
               (user_id, game_type, position_x, position_y, world_offset, 
                current_level, collected_coins_positions, coins_collected, 
                health, last_checkpoint, duration, created_at, updated_at, is_active) 
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
            [
              newUserId,
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
              gameSave.fields['is_active'],
            ],
          );
        }
        
        // Eliminar de la tabla admins y admin_stats
        await conn.query('DELETE FROM admin_game_history WHERE admin_id = ?', [adminId]);
        await conn.query('DELETE FROM admin_game_saves WHERE admin_id = ?', [adminId]);
        await conn.query('DELETE FROM admin_stats WHERE admin_id = ?', [adminId]);
        await conn.query('DELETE FROM admins WHERE id = ?', [adminId]);
      }
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

  Future<int> registerUser({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var result = await conn.query(
        'INSERT INTO users (username, email, password, role) VALUES (?, ?, ?, ?)',
        [username, email, password, role],
      );
      // Return the inserted user's ID
      return result.insertId!;
    } finally {
      await conn.close();
    }
  }

  Future<User> getAdminById(int adminId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var results = await conn.query('SELECT * FROM admins WHERE id = ?', [adminId]);
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
      var result = await conn.query(
        'INSERT INTO admins (username, email, password, role) VALUES (?, ?, ?, ?)',
        [username, email, password, role],
      );
      return result.insertId!;
    } finally {
      await conn.close();
    }
  }

  Future<void> createAdminStats(int adminId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await conn.query(
        'INSERT INTO admin_stats (admin_id) VALUES (?)',
        [adminId],
      );
    } finally {
      await conn.close();
    }
  }

  Future<PlayerStats> getAdminStats(int adminId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var results = await conn.query(
        'SELECT * FROM admin_stats WHERE admin_id = ?',
        [adminId],
      );

      if (results.isEmpty) {
        await createAdminStats(adminId);
        results = await conn.query(
          'SELECT * FROM admin_stats WHERE admin_id = ?',
          [adminId],
        );
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
      var userResults = await conn.query(
        'SELECT role FROM users WHERE id = ? UNION SELECT role FROM admins WHERE id = ?',
        [userId, userId]
      );
      
      if (userResults.isEmpty) {
        throw Exception('Usuario no encontrado');
      }

      String currentRole = userResults.first.fields['role'];

      // Si el rol ha cambiado, manejar la transición
      if (currentRole != newRole) {
        if (newRole == 'admin' || newRole == 'subadmin') {
          // Mover de users a admins
          var userData = await conn.query('SELECT * FROM users WHERE id = ?', [userId]);
          if (userData.isNotEmpty) {
            await conn.query(
              'INSERT INTO admins (id, username, email, password, is_active, role) VALUES (?, ?, ?, ?, ?, ?)',
              [userId, username, email, userData.first.fields['password'], 1, newRole]
            );
            await conn.query('DELETE FROM users WHERE id = ?', [userId]);
          }
        } else {
          // Mover de admins a users
          var adminData = await conn.query('SELECT * FROM admins WHERE id = ?', [userId]);
          if (adminData.isNotEmpty) {
            await conn.query(
              'INSERT INTO users (id, username, email, password, is_blocked, is_active, role) VALUES (?, ?, ?, ?, ?, ?, ?)',
              [userId, username, email, adminData.first.fields['password'], 0, 1, newRole]
            );
            await conn.query('DELETE FROM admins WHERE id = ?', [userId]);
          }
        }
      } else {
        // Solo actualizar datos sin cambiar rol
        String table = (newRole == 'admin' || newRole == 'subadmin') ? 'admins' : 'users';
        await conn.query(
          'UPDATE $table SET username = ?, email = ? WHERE id = ?',
          [username, email, userId]
        );
      }
    } finally {
      await conn.close();
    }
  }

  Future<void> updateAdminStats(int adminId, int renameTickets, int coins, int ticketsGame2) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await conn.query(
        'UPDATE admin_stats SET rename_tickets = ?, coins = ?, tickets_game2 = ? WHERE admin_id = ?',
        [renameTickets, coins, ticketsGame2, adminId]
      );
    } finally {
      await conn.close();
    }
  }
}