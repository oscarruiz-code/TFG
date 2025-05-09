import '../../../../../dependencias/imports.dart';

class GestorColisiones {
  bool verificarColisionSuelo(Player player, double groundLevel) {
    return player.y >= groundLevel - (player.size * 0.5);
  }

  bool verificarColisionObstaculo(Player player, Rect obstaculoHitbox) {
    return player.hitbox.overlaps(obstaculoHitbox);
  }

  bool verificarColisionItem(Player player, Rect itemHitbox) {
    return player.hitbox.overlaps(itemHitbox);
  }
}