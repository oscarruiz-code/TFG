import '../../../../../../dependencias/imports.dart';


/// Moneda especial que otorga al jugador un power-up temporal de salto mejorado.
///
/// Al recolectarla, aumenta la fuerza de salto del jugador durante un tiempo limitado.
/// La mejora depende del estado actual del jugador (normal o agachado).
class MonedaSalto extends MonedaBase {
  MonedaSalto({
    required super.x,
    required super.y,
    super.isCollected,
  }) : super(
    spritePath: 'assets/personajes/items/monedas/monedasalto.png',
    valor: 0, 
  );

  @override
  void aplicarEfecto(dynamic player) {
    
  }
}