import 'moneda_base.dart';

class MonedaSalto extends MonedaBase {
  MonedaSalto({
    required double x,
    required double y,
  }) : super(
    x: x,
    y: y,
    spritePath: 'assets/personajes/items/monedas/monedasalto.png',
  );

  @override
  void aplicarEfecto(dynamic player) {
    // Aumentar fuerza de salto temporalmente
    player.fuerzaSaltoTemp = player.fuerzaSalto * 1.5;
    Future.delayed(const Duration(seconds: 5), () {
      player.fuerzaSaltoTemp = player.fuerzaSalto;
    });
  }
}