import '../../../../../../dependencias/imports.dart';

class MonedaNormal extends MonedaBase {
  MonedaNormal({
    required double x,
    required double y,
  }) : super(
    x: x,
    y: y,
    spritePath: 'assets/personajes/items/monedas/monedacoin.png',
    valor: 1, // <-- Agrega esto
  );

  @override
  void aplicarEfecto(dynamic player) {
    // No need to do anything here since coins are handled in Game1
  }
}