import '../../../../../../dependencias/imports.dart';

class MonedaVelocidad extends MonedaBase {
  // Constructor
  MonedaVelocidad({
    required super.x,
    required super.y,
    super.isCollected,
  }) : super(
    spritePath: 'assets/personajes/items/monedas/monedavelocidad.png',
    valor: 0, // Establecer valor a 0 para que no sume al contador
  );

  @override
  void aplicarEfecto(dynamic player) {
    if (player == null) return;
    
    // Usar el método específico para power-ups de velocidad
    player.activarPowerUpVelocidad(
      AnimacionAndar.velocidad * 1.5,
      const Duration(milliseconds: 2000)
    );
  }
}