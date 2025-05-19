import 'moneda_base.dart';

class MonedaNormal extends MonedaBase {
  MonedaNormal({
    required double x,
    required double y,
  }) : super(
    x: x,
    y: y,
    spritePath: 'assets/personajes/items/monedas/monedacoin.png',
  );

  @override
  void aplicarEfecto(dynamic player) {
    // Aumentar monedas del jugador en 20
    player.monedas += 20;
  }
}