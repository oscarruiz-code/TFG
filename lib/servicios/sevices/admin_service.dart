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

      if (newRole == 'admin' || newRole == 'subadmin') {
        // Promover a admin/subadmin: mover de users a admins
        await conn.query(
          'INSERT INTO admins (username, email, password, role) VALUES (?, ?, ?, ?)',
          [userData['username'], userData['email'], userData['password'], newRole],
        );
        
        // Eliminar de la tabla users
        await conn.query('DELETE FROM users WHERE id = ?', [userId]);
      } else if (newRole == 'user') {
        // Degradar a usuario: mover de admins a users
        await conn.query(
          'INSERT INTO users (username, email, password, role) VALUES (?, ?, ?, ?)',
          [userData['username'], userData['email'], userData['password'], newRole],
        );
        
        // Eliminar de la tabla admins
        await conn.query('DELETE FROM admins WHERE username = ?', [userData['username']]);
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
        // Insertar con valores predeterminados explícitos
        await conn.query(
          '''INSERT INTO admin_stats 
             (admin_id, tickets_game2, coins, rename_tickets, 
              has_used_free_rename, current_avatar, unlocked_premium_avatars)
             VALUES (?, 0, 0, 0, false, 'assets/avatar/defecto.png', '')''',
          [adminId],
        );
        results = await conn.query(
          'SELECT * FROM admin_stats WHERE admin_id = ?',
          [adminId],
        );
      }
      
      // Asegurarse de que los valores numéricos no sean nulos
      var data = results.first.fields;
      data['tickets_game2'] = data['tickets_game2'] ?? 0;
      data['coins'] = data['coins'] ?? 0;
      data['rename_tickets'] = data['rename_tickets'] ?? 0;
      data['has_used_free_rename'] = data['has_used_free_rename'] ?? false;
      data['current_avatar'] = data['current_avatar'] ?? 'assets/avatar/defecto.png';
      data['unlocked_premium_avatars'] = data['unlocked_premium_avatars'] ?? '';
      
      return PlayerStats.fromMap(data);
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