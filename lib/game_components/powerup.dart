import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class PowerUp {
  double x;
  double y;
  double size;
  bool isActive;
  final String sprite = 'assets/sprites/items/pez2.png';
  final int pointValue = 100;

  PowerUp({
    required this.x,
    required this.y,
    this.size = 30.0,
    this.isActive = true,
  });

  Rect get hitbox => Rect.fromCenter(
    center: Offset(x, y),
    width: size,
    height: size,
  );

  void apply(Player player) {
    if (isActive) {
      player.addPoints(pointValue);  // Ahora sí está definido en Player
      player.speed *= 1.2;  // Bonus temporal de velocidad
      isActive = false;
      
      // Restaurar la velocidad después de 3 segundos
      Future.delayed(const Duration(seconds: 3), () {
        player.speed /= 1.2;
      });
    }
  }
}