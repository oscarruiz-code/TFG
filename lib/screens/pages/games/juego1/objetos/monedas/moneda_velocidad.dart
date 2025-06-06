import '../../../../../../dependencias/imports.dart';

/// Moneda especial que otorga al jugador un power-up temporal de velocidad.
///
/// Al recolectarla, aumenta la velocidad de movimiento del jugador durante un tiempo limitado.
class MonedaVelocidad extends MonedaBase {
  // Constructor
  MonedaVelocidad({
    required super.x,
    required super.y,
    super.isCollected,
  }) : super(
    spritePath: 'assets/personajes/items/monedas/monedavelocidad.png',
    valor: 0,
  );

  @override
  void aplicarEfecto(dynamic player) {
   
  }
}