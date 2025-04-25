import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class Enemy {
  double x;
  double y;
  double speed;
  double size;
  bool isActive;
  final String sprite = 'assets/sprites/enemies/foca.png';

  Enemy({
    required this.x,
    required this.y,
    this.speed = 3.0,
    this.size = 40.0,
    this.isActive = true,
  });

  void move(double playerX, double playerY) {
    // Basic enemy movement towards player
    double angle = atan2(playerY - y, playerX - x);
    x += cos(angle) * speed;
    y += sin(angle) * speed;
  }

  Rect get hitbox => Rect.fromCenter(
    center: Offset(x, y),
    width: size,
    height: size,
  );
}