import '../../../../../../dependencias/imports.dart';

class MonedaVelocidad extends MonedaBase {
  // Constructor
  MonedaVelocidad({
    required super.x,
    required super.y,
    super.isCollected,
  }) : super(
    spritePath: 'assets/personajes/items/monedas/monedavelocidad.png',
  );

  @override
  Rect get hitbox => Rect.fromLTWH(
    x + (width * 0.1),  // Ajuste del hitbox para mejor precisión
    y + (height * 0.2),
    width * 0.8,  // Reducción del área de colisión para mayor precisión
    height * 0.6,
  );

  @override
  void aplicarEfecto(dynamic player) {
    if (player == null) return;
    
    print('Aplicando efecto de velocidad');
    print('Velocidad anterior: ${player.velocidadTemp}');
    
    // Usar el método específico para power-ups de velocidad
    player.activarPowerUpVelocidad(
      AnimacionAndar.velocidad * 1.5,
      const Duration(milliseconds: 3000) // Medio segundo de duración
    );
    
    print('Nueva velocidad: ${player.velocidadTemp}');
  }
}