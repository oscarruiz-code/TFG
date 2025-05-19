import 'moneda_base.dart';

class MonedaVelocidad extends MonedaBase {
  MonedaVelocidad({
    required double x,
    required double y,
  }) : super(
    x: x,
    y: y,
    spritePath: 'assets/personajes/items/monedas/monedavelocidad.png',
  );

  @override
  void aplicarEfecto(dynamic player) {
    // Aumentar velocidad temporalmente
    player.velocidadTemp = player.velocidad * 1.3;
    Future.delayed(const Duration(seconds: 5), () {
      player.velocidadTemp = player.velocidad;
    });
  }
}