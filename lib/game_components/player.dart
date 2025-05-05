import 'package:oscarruizcode_pingu/dependencias/imports.dart';

enum PenguinPlayerState {
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
  PenguinPlayerState currentState;
  int score = 0;
  bool isInvincible = false;
  
  // Dimensiones actualizadas para los sprites
  static const double defaultWidth = 104.0;
  static const double defaultHeight = 107.0;
  
  // Variables para la animación
  int currentFrame = 0;
  double animationTime = 0;
  final double frameTime = 0.1; // 100ms entre frames
  
  final Map<PenguinPlayerState, List<String>> animationSprites = {
    PenguinPlayerState.idle: ['assets/personajes/principal/andar/andar1.png'],
    PenguinPlayerState.walking: [
      'assets/personajes/principal/andar/andar1.png',
      'assets/personajes/principal/andar/andar2.png',
      'assets/personajes/principal/andar/andar3.png',
      'assets/personajes/principal/andar/andar4.png',
      'assets/personajes/principal/andar/andar5.png',
      'assets/personajes/principal/andar/andar6.png',
      'assets/personajes/principal/andar/andar7.png',
    ],
    PenguinPlayerState.sliding: ['assets/personajes/principal/andar/andar1.png'],
  };

  Player({
    required this.x,
    required this.y,
    this.speed = 5.0,
    this.size = defaultWidth,  // Updated to use new constant name
    this.isSliding = false,
    this.isFacingRight = true,
    this.currentState = PenguinPlayerState.idle,
  });

  void addPoints(int points) {
    score += points;
  }

  String getCurrentSprite() {
    final sprites = animationSprites[currentState]!;
    return sprites[currentFrame % sprites.length];
  }

  void updateAnimation(double deltaTime) {
    if (currentState == PenguinPlayerState.walking) {
      animationTime += deltaTime;
      if (animationTime >= frameTime) {
        animationTime = 0;
        currentFrame++;
      }
    } else {
      currentFrame = 0;
      animationTime = 0;
    }
  }

  void move(double dx, double dy, {double? groundLevel}) {
    // Movimiento solo horizontal
    x += dx * speed;

    // El personaje siempre debe estar sobre el suelo
    if (groundLevel != null) {
      y = groundLevel - (size * 0.5); // Ajusta para que esté justo encima de la plataforma
    }

    if (dx != 0) {
      currentState = PenguinPlayerState.walking;
      isFacingRight = dx > 0;
    } else {
      currentState = PenguinPlayerState.idle;
    }
  }

  void slide() {
    if (!isSliding) {
      isSliding = true;
      currentState = PenguinPlayerState.sliding;
      speed *= 1.5;
      Future.delayed(const Duration(seconds: 1), () {
        isSliding = false;
        speed /= 1.5;
        currentState = PenguinPlayerState.idle;
      });
    }
  }

  Rect get hitbox => Rect.fromCenter(
    center: Offset(x, y),
    width: defaultWidth * 0.8,  // Updated to use new constant name
    height: defaultHeight * 0.8, // Updated to use new constant name
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