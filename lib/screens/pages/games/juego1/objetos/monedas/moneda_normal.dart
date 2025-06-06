import '../../../../../../dependencias/imports.dart';

/// Implementación de moneda estándar que otorga puntos al jugador.
///
/// Esta moneda no proporciona ningún efecto especial al jugador,
/// pero suma 10 puntos al contador cuando es recolectada.
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