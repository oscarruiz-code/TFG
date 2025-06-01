import '../../../../../../dependencias/imports.dart';

class MonedaNormal extends MonedaBase {
  MonedaNormal({
    required super.x,
    required super.y,
    super.isCollected,
  }) : super(
    spritePath: 'assets/personajes/items/monedas/monedacoin.png',
    valor: 10,
  );

  @override
  void aplicarEfecto(dynamic player) {

  }
}