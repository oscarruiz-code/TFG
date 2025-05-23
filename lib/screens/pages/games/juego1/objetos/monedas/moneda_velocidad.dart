import '../../../../../../dependencias/imports.dart';

class MonedaVelocidad extends MonedaBase {
  // Constructor
  MonedaVelocidad({
    required double x,
    required double y,
  }) : super(
    x: x,
    y: y,
    spritePath: 'assets/personajes/items/monedas/monedavelocidad.png',
  );

  @override
  Rect get hitbox => Rect.fromLTWH(
    x + (width * 0.1),  // Ajuste del hitbox para mejor precisión
    y + (height * 0.1),
    width * 0.8,  // Reducción del área de colisión para mayor precisión
    height * 0.8,
  );

  @override
  void aplicarEfecto(dynamic player) {
    // Solo activa el power-up, no toques la velocidad base
    player.activarPowerUpVelocidad(AnimacionAndar.velocidad * 1.5, const Duration(seconds: 2));
  }
}