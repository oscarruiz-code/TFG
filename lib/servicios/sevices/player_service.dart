import '../conexion/mysql_connection.dart';
import '../entity/player.dart';

class PlayerService {

    Future<void> updateRenameTickets(int userId, int newAmount) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await conn.query(
        'UPDATE player_stats SET rename_tickets = ? WHERE user_id = ?',
        [newAmount, userId],
      );
    } finally {
      await conn.close();
    }
  }
  
  Future<PlayerStats> getPlayerStats(int userId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var results = await conn.query(
        'SELECT * FROM player_stats WHERE user_id = ?',
        [userId],
      );

      if (results.isEmpty) {
        await conn.query(
          'INSERT INTO player_stats (user_id) VALUES (?)',
          [userId],
        );
        results = await conn.query(
          'SELECT * FROM player_stats WHERE user_id = ?',
          [userId],
        );
      }

      return PlayerStats.fromMap(results.first.fields);
    } finally {
      await conn.close();
    }
  }

  Future<void> updateCoins(int userId, int amount) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await conn.query(
        'UPDATE player_stats SET coins = ? WHERE user_id = ?',
        [amount, userId],
      );
    } finally {
      await conn.close();
    }
  }

  Future<void> updateTicketsGame2(int userId, int amount) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await conn.query(
        'UPDATE player_stats SET tickets_game2 = ? WHERE user_id = ?',
        [amount, userId],
      );
    } finally {
      await conn.close();
    }
  }

  Future<bool> useRenameTicket(int userId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var stats = await getPlayerStats(userId);
      
      if (!stats.hasUsedFreeRename) {
        await conn.query(
          'UPDATE player_stats SET has_used_free_rename = 1 WHERE user_id = ?',
          [userId],
        );
        return true;
      } else if (stats.renameTickets > 0) {
        await conn.query(
          'UPDATE player_stats SET rename_tickets = rename_tickets - 1 WHERE user_id = ?',
          [userId],
        );
        return true;
      }
      return false;
    } finally {
      await conn.close();
    }
  }

  Future<void> registerGamePlay(int userId, int gameType, int score, int duration) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await conn.query(
        'INSERT INTO game_history (user_id, game_type, score, duration) VALUES (?, ?, ?, ?)',
        [userId, gameType, score, duration],
      );
    } finally {
      await conn.close();
    }
  }

  Future<List<Map<String, dynamic>>> getGameHistory(int userId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var results = await conn.query(
        'SELECT * FROM game_history WHERE user_id = ? ORDER BY played_at DESC',
        [userId],
      );

      return results.map((row) => row.fields).toList();
    } finally {
      await conn.close();
    }
  }

  Future<List<Map<String, dynamic>>> getTopScores(int userId, int gameType) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var results = await conn.query(
        'SELECT * FROM game_history WHERE user_id = ? AND game_type = ? ORDER BY score DESC LIMIT 5',
        [userId, gameType],
      );

      return results.map((row) => row.fields).toList();
    } finally {
      await conn.close();
    }
  }

  Future<bool> updateUsername(int userId, String newUsername) async {
      final conn = await DatabaseConnection.getConnection();
      try {
        // First check if username already exists
        var checkResults = await conn.query(
          'SELECT id FROM users WHERE username = ? AND id != ?',
          [newUsername, userId],
        );
        
        if (checkResults.isNotEmpty) {
          return false; // Username already taken
        }
  
        await conn.query(
          'UPDATE users SET username = ? WHERE id = ?',
          [newUsername, userId],
        );
        return true; // Update successful
      } finally {
        await conn.close();
      }
    }

  Future<void> setUsedFreeRename(int userId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await conn.query(
        'UPDATE player_stats SET has_used_free_rename = true WHERE user_id = ?',
        [userId],
      );
    } finally {
      await conn.close();
    }
  }
}