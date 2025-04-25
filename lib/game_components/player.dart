import 'package:oscarruizcode_pingu/dependencias/imports.dart';

enum PenguinPlayerState {  // Renamed from PlayerState to be more specific
  idle,
  walking,
  sliding
}

class Player {
  double x;
  double y;
  double speed;
  double size;
  bool isSliding;
  bool isFacingRight;
  PenguinPlayerState currentState;  // Updated to use new enum name
  int score = 0;  // Añadimos el score
  bool isInvincible = false;  // Añadimos estado de invencibilidad
  
  final Map<PenguinPlayerState, String> sprites = {  // Updated map to use new enum
    PenguinPlayerState.idle: 'assets/sprites/penguin/parado/parado.png',
    PenguinPlayerState.walking: 'assets/sprites/penguin/andando/andar1.png',
    PenguinPlayerState.sliding: 'assets/sprites/penguin/deslizandose/deslizarse2.png',
  };

  Player({
    required this.x,
    required this.y,
    this.speed = 5.0,
    this.size = 50.0,
    this.isSliding = false,
    this.isFacingRight = true,
    this.currentState = PenguinPlayerState.idle,  // Updated default value
  });

  void addPoints(int points) {
    score += points;
  }

  String getCurrentSprite() {
    return sprites[currentState]!;
  }

  void move(double dx, double dy) {
    x += dx * speed;
    y += dy * speed;
    if (dx != 0) {
      isFacingRight = dx > 0;
    }
  }

  void slide() {
    if (!isSliding) {
      isSliding = true;
      speed *= 1.5;
      // Reset sliding after 1 second
      Future.delayed(const Duration(seconds: 1), () {
        isSliding = false;
        speed /= 1.5;
      });
    }
  }

  Rect get hitbox => Rect.fromCenter(
    center: Offset(x, y),
    width: size,
    height: size,
  );

  bool canAttack = true;
  Duration attackCooldown = const Duration(milliseconds: 500);

  void attack() {
    if (canAttack) {
      canAttack = false;
      Future.delayed(attackCooldown, () {
        canAttack = true;
      });
    }
  }
}