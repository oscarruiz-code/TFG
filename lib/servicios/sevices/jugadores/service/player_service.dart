import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class PlayerService {
  Future<void> updateRenameTickets(int userId, int newAmount) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Primero verificar si es un admin
      var adminResults = await PlayerQueryRepository.checkIfAdmin(conn, userId);

      if (adminResults.isNotEmpty) {
        await PlayerQueryRepository.updateAdminRenameTickets(conn, userId, newAmount);
      } else {
        await PlayerQueryRepository.updateUserRenameTickets(conn, userId, newAmount);
      }
    } finally {
      await conn.close();
    }
  }

  Future<bool> updateProfilePicture(int userId, String avatarPath) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Obtener stats actuales del jugador
      var stats = await getPlayerStats(userId);
      
      // Verificar si es un admin
      var adminResults = await PlayerQueryRepository.checkIfAdmin(conn, userId);
      
      bool isAdmin = adminResults.isNotEmpty;

      // Verificar si el avatar es gratuito
      if (PlayerStats.freeAvatars.contains(avatarPath)) {
        if (isAdmin) {
          await PlayerQueryRepository.updateAdminAvatar(conn, userId, avatarPath);
        } else {
          await PlayerQueryRepository.updateUserAvatar(conn, userId, avatarPath);
        }
        return true;
      }

      // Si es premium, verificar si está desbloqueado
      if (PlayerStats.premiumAvatars.contains(avatarPath) &&
          stats.hasPremiumAvatar(avatarPath)) {
        if (isAdmin) {
          await PlayerQueryRepository.updateAdminAvatar(conn, userId, avatarPath);
        } else {
          await PlayerQueryRepository.updateUserAvatar(conn, userId, avatarPath);
        }
        return true;
      }

      return false; // No tiene permiso para usar este avatar
    } finally {
      await conn.close();
    }
  }

  Future<PlayerStats> getPlayerStats(int userId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Primero verificar si es un admin
      var adminResults = await PlayerQueryRepository.checkIfAdmin(conn, userId);

      if (adminResults.isNotEmpty) {
        var results = await PlayerQueryRepository.getAdminStats(conn, userId);

        if (results.isEmpty) {
          await PlayerQueryRepository.insertAdminStats(conn, userId);
          results = await PlayerQueryRepository.getAdminStats(conn, userId);
        }
        return PlayerStats.fromMap(results.first.fields);
      }

      // Si no es admin, continuar con la lógica existente para usuarios normales
      var results = await PlayerQueryRepository.getUserStats(conn, userId);

      if (results.isEmpty) {
        await PlayerQueryRepository.insertUserStats(conn, userId);
        results = await PlayerQueryRepository.getUserStats(conn, userId);
      }

      return PlayerStats.fromMap(results.first.fields);
    } finally {
      await conn.close();
    }
  }

  Future<void> updateCoins(int userId, int amount) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Primero verificar si es un admin
      var adminResults = await PlayerQueryRepository.checkIfAdmin(conn, userId);

      if (adminResults.isNotEmpty) {
        await PlayerQueryRepository.updateAdminCoins(conn, userId, amount);
      } else {
        await PlayerQueryRepository.updateUserCoins(conn, userId, amount);
      }
    } finally {
      await conn.close();
    }
  }

  Future<void> updateTicketsGame2(int userId, int amount) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Primero verificar si es un admin
      var adminResults = await PlayerQueryRepository.checkIfAdmin(conn, userId);

      if (adminResults.isNotEmpty) {
        await PlayerQueryRepository.updateAdminTicketsGame2(conn, userId, amount);
      } else {
        await PlayerQueryRepository.updateUserTicketsGame2(conn, userId, amount);
      }
    } finally {
      await conn.close();
    }
  }

  Future<bool> useRenameTicket(int userId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var stats = await getPlayerStats(userId);

      if (!stats.hasUsedFreeRename) {
        await PlayerQueryRepository.setUserHasUsedFreeRename(conn, userId);
        return true;
      } else if (stats.renameTickets > 0) {
        await PlayerQueryRepository.decrementUserRenameTickets(conn, userId);
        return true;
      }
      return false;
    } finally {
      await conn.close();
    }
  }

  Future<void> registerGamePlay(
    int userId,
    int gameType,
    int score,
    int duration,
  ) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Verificar si es un admin
      var adminResults = await PlayerQueryRepository.checkIfAdmin(conn, userId);

      if (adminResults.isNotEmpty) {
        await PlayerQueryRepository.insertAdminGameHistory(conn, userId, gameType, score, duration);
      } else {
        await PlayerQueryRepository.insertUserGameHistory(conn, userId, gameType, score, duration);
      }
    } finally {
      await conn.close();
    }
  }

  Future<List<Map<String, dynamic>>> getGameHistory(int userId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Verificar si es un admin
      var adminResults = await PlayerQueryRepository.checkIfAdmin(conn, userId);

      if (adminResults.isNotEmpty) {
        var results = await PlayerQueryRepository.getAdminGameHistory(conn, userId);
        return results.map((row) => row.fields).toList();
      }

      var results = await PlayerQueryRepository.getUserGameHistory(conn, userId);
      return results.map((row) => row.fields).toList();
    } finally {
      await conn.close();
    }
  }

  Future<List<Map<String, dynamic>>> getTopScores(
    int userId,
    int gameType,
  ) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var userResults = await PlayerQueryRepository.getTopScores(conn, gameType);
      return userResults.map((row) => row.fields).toList();
    } finally {
      await conn.close();
    }
  }

  Future<bool> updateUsername(int userId, String newUsername) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // First check if username already exists
      var checkResults = await PlayerQueryRepository.checkUsernameExists(conn, newUsername, userId);

      if (checkResults.isNotEmpty) {
        return false; // Username already taken
      }

      await PlayerQueryRepository.updateUsername(conn, userId, newUsername);
      return true; // Update successful
    } finally {
      await conn.close();
    }
  }

  Future<void> setUsedFreeRename(int userId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await PlayerQueryRepository.setUserHasUsedFreeRename(conn, userId);
    } finally {
      await conn.close();
    }
  }

  Future<void> updateUnlockedPremiumAvatars(
    int userId,
    List<String> avatars,
  ) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await PlayerQueryRepository.updateUnlockedPremiumAvatars(conn, userId, avatars.join(','));
    } finally {
      await conn.close();
    }
  }

  Future<void> deletePlayerStats(int userId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await PlayerQueryRepository.deletePlayerStats(conn, userId);
    } finally {
      await conn.close();
    }
  }

  Future<void> updatePlayerStats(
    int userId,
    int renameTickets,
    int coins,
    int ticketsGame2,
  ) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      await PlayerQueryRepository.updatePlayerStats(conn, userId, renameTickets, coins, ticketsGame2);
    } finally {
      await conn.close();
    }
  }

  Future<void> unlockPremiumAvatar(int userId, String avatarPath) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Obtener los avatares desbloqueados actuales
      var stats = await getPlayerStats(userId);
      List<String> unlocked = List<String>.from(stats.unlockedPremiumAvatars);
      if (!unlocked.contains(avatarPath)) {
        unlocked.add(avatarPath);
        String updatedAvatars = unlocked.join(',');
        await PlayerQueryRepository.updateUnlockedPremiumAvatars(conn, userId, updatedAvatars);
      }
    } finally {
      await conn.close();
    }
  }

  Future<void> saveGameProgress({
    required int userId,
    required int gameType,
    required int score,
    required int coins,
    required bool victory,
    required int duration,
    required double worldOffset,
    required double playerX,
    required double playerY,
    required int health,
    required int currentLevel,
    String? lastCheckpoint,
    String? collectedCoinsPositions,
  }) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Check if user is admin
      var adminResults = await PlayerQueryRepository.checkIfAdmin(conn, userId);

      if (adminResults.isNotEmpty) {
        // Handle admin game save - ELIMINAR físicamente las partidas antiguas
        await PlayerQueryRepository.deleteAdminGameSaves(conn, userId, gameType);
        await PlayerQueryRepository.insertAdminGameSave(
          conn, userId, gameType, playerX, playerY, worldOffset,
          coins, health, currentLevel, lastCheckpoint, collectedCoinsPositions, duration
        );
      } else {
        // Handle regular user game save - ELIMINAR físicamente las partidas antiguas
        await PlayerQueryRepository.deleteUserGameSaves(conn, userId, gameType);
        await PlayerQueryRepository.insertUserGameSave(
          conn, userId, gameType, playerX, playerY, worldOffset,
          coins, health, currentLevel, lastCheckpoint, collectedCoinsPositions, duration
        );
      }

      // Register in game history if victory
      if (victory) {
        if (adminResults.isNotEmpty) {
          await PlayerQueryRepository.registerAdminVictory(conn, userId, gameType, score, coins, duration);
        } else {
          await PlayerQueryRepository.registerUserVictory(conn, userId, gameType, score, coins, duration);
        }
      }
    } finally {
      await conn.close();
    }
  }

  Future<void> updatePlayerCoins({
    required int userId,
    required int coinsToAdd,
  }) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      var stats = await getPlayerStats(userId);
      int newCoins = stats.coins + coinsToAdd;

      await PlayerQueryRepository.updateUserCoins(conn, userId, newCoins);
    } finally {
      await conn.close();
    }
  }

  Future<void> saveGameState({
    required int userId,
    required int gameType,
    required double positionX,
    required double positionY,
    required int currentLevel,
    required int coinsCollected,
    required int health,
    required int duration,
    String? lastCheckpoint,
  }) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Verificar si es admin
      var adminResults = await PlayerQueryRepository.checkIfAdmin(conn, userId);

      if (adminResults.isNotEmpty) {
        await PlayerQueryRepository.deactivateAdminGameSaves(conn, userId, gameType);
        await PlayerQueryRepository.insertAdminGameState(
          conn, userId, gameType, positionX, positionY, currentLevel,
          coinsCollected, health, lastCheckpoint, duration
        );
      } else {
        await PlayerQueryRepository.deactivateUserGameSaves(conn, userId, gameType);
        await PlayerQueryRepository.insertUserGameState(
          conn, userId, gameType, positionX, positionY, currentLevel,
          coinsCollected, health, lastCheckpoint, duration
        );
      }
    } finally {
      await conn.close();
    }
  }

  Future<Map<String, dynamic>?> loadGameState(int userId, int gameType) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Verificar si es admin
      var adminResults = await PlayerQueryRepository.checkIfAdmin(conn, userId);

      Map<String, dynamic>? result;
      if (adminResults.isNotEmpty) {
        var results = await PlayerQueryRepository.loadAdminGameState(conn, userId, gameType);

        if (results.isEmpty) return null;
        result = results.first.fields;
        // Añadir log para depuración
        debugPrint('Admin game data loaded: $result');
      } else {
        var results = await PlayerQueryRepository.loadUserGameState(conn, userId, gameType);

        if (results.isEmpty) return null;
        result = results.first.fields;
        // Añadir log para depuración
        debugPrint('User game data loaded: $result');
        debugPrint('Collected coins positions from DB: ${result["collected_coins_positions"]}');
      }
      return result;
    } finally {
      await conn.close();
    }
  }

  Future<Map<String, dynamic>?> getSavedGame(int userId, {int? gameType}) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Check if user is admin
      var adminResults = await PlayerQueryRepository.checkIfAdmin(conn, userId);

      var results;
      if (adminResults.isNotEmpty) {
        if (gameType != null) {
          results = await PlayerQueryRepository.getAdminSavedGameByType(conn, userId, gameType);
        } else {
          results = await PlayerQueryRepository.getAllAdminSavedGames(conn, userId);
        }
      } else {
        if (gameType != null) {
          results = await PlayerQueryRepository.getUserSavedGameByType(conn, userId, gameType);
        } else {
          results = await PlayerQueryRepository.getAllUserSavedGames(conn, userId);
        }
      }

      if (results.isEmpty) return null;
      return results.first.fields;
    } finally {
      await conn.close();
    }
  }

  Future<bool> deleteSavedGame(int userId) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Verificar si es un admin
      var adminResults = await PlayerQueryRepository.checkIfAdmin(conn, userId);

      var result;
      if (adminResults.isNotEmpty) {
        // Es un administrador, eliminar físicamente
        result = await PlayerQueryRepository.deleteAllAdminSavedGames(conn, userId);
      } else {
        // Es un usuario normal, eliminar físicamente
        result = await PlayerQueryRepository.deleteAllUserSavedGames(conn, userId);
      }

      // Devolver true si se eliminó alguna fila
      return (result.affectedRows ?? 0) > 0;
    } catch (e) {
      debugPrint('Error al eliminar la partida guardada: ${e.toString()}');
      return false;
    } finally {
      await conn.close();
    }
  }

  Future<bool> deleteGameSave(int userId, int gameType) async {
    final conn = await DatabaseConnection.getConnection();
    try {
      // Verificar si es admin
      var adminResults = await PlayerQueryRepository.checkIfAdmin(conn, userId);

      if (adminResults.isNotEmpty) {
        var result = await PlayerQueryRepository.deleteAdminGameSaveByType(conn, userId, gameType);
        if ((result.affectedRows ?? 0) == 0) {
          return false;
        }
        return true;
      } else {
        var result = await PlayerQueryRepository.deleteUserGameSaveByType(conn, userId, gameType);
        if ((result.affectedRows ?? 0) == 0) {
          return false;
        }
        return true;
      }
    } catch (e) {
      debugPrint('Error al eliminar la partida guardada: ${e.toString()}');
      return false;
    } finally {
      await conn.close();
    }
  }
}