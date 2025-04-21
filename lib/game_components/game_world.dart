import 'package:flutter/material.dart';
import 'dart:math';
import 'player.dart';
import 'enemy.dart';
import 'powerup.dart';

class GameWorld {
  final Size worldSize;
  final Player player;
  final List<Enemy> enemies;
  final List<PowerUp> powerUps;
  final Random random = Random();
  int score = 0;
  int level = 1;
  List<Rect> platforms = [];
  
  GameWorld({
    required this.worldSize,
    required this.player,
  }) : enemies = [],
       powerUps = [];

  void update() {
    // Update player
    _keepInBounds(player);

    // Update enemies
    for (var enemy in enemies) {
      if (enemy.isActive) {
        enemy.move(player.x, player.y);
        _keepInBounds(enemy);
      }
    }

    // Check collisions
    _checkCollisions();

    // Spawn new enemies based on level
    if (random.nextDouble() < 0.02 * level) {
      _spawnEnemy();
    }

    // Spawn power-ups occasionally
    if (random.nextDouble() < 0.005) {
      _spawnPowerUp();
    }

    // Spawn platforms occasionally (for Game1)
    if (random.nextDouble() < 0.02) {
      _spawnPlatform();
    }
    
    // Mover plataformas hacia arriba
    for (int i = platforms.length - 1; i >= 0; i--) {
      var platform = platforms[i];
      platforms[i] = Rect.fromLTWH(
        platform.left,
        platform.top - 2.0,  // Velocidad de movimiento
        platform.width,
        platform.height
      );
      
      // Eliminar plataformas que salen de la pantalla
      if (platforms[i].bottom < 0) {
        platforms.removeAt(i);
        score += 10;  // Puntos por esquivar plataforma
      }
    }
  }

  void _keepInBounds(dynamic entity) {
    entity.x = entity.x.clamp(0, worldSize.width - entity.size);
    entity.y = entity.y.clamp(0, worldSize.height - entity.size);
  }

  void _spawnEnemy() {
    // Spawn enemy at random edge position
    double x, y;
    if (random.nextBool()) {
      x = random.nextDouble() * worldSize.width;
      y = random.nextBool() ? 0 : worldSize.height;
    } else {
      x = random.nextBool() ? 0 : worldSize.width;
      y = random.nextDouble() * worldSize.height;
    }

    enemies.add(Enemy(
      x: x,
      y: y,
    ));
  }

  void _spawnPowerUp() {
    powerUps.add(PowerUp(
      x: random.nextDouble() * worldSize.width,
      y: random.nextDouble() * worldSize.height,
    ));
  }

  void _checkCollisions() {
    // Check enemy collisions
    for (var enemy in enemies) {
      if (enemy.isActive && enemy.hitbox.overlaps(player.hitbox)) {
        // Handle player-enemy collision
      }
    }

    // Check power-up collisions
    for (var powerUp in powerUps) {
      if (powerUp.isActive && powerUp.hitbox.overlaps(player.hitbox)) {
        powerUp.apply(player);
        powerUp.isActive = false;
      }
    }

    // Clean up inactive entities
    enemies.removeWhere((enemy) => !enemy.isActive);
    powerUps.removeWhere((powerUp) => !powerUp.isActive);
  }

  void _spawnPlatform() {
    platforms.add(Rect.fromLTWH(
      random.nextDouble() * (worldSize.width - 100),
      worldSize.height,
      100,  // ancho de plataforma
      20    // alto de plataforma
    ));
  }
}