import '../../../../../../dependencias/imports.dart';

class ColisionItem {
  bool verificar(Player player, MonedaBase moneda, double worldOffset) {
    if (moneda.isCollected) return false;

    // Obtener hitboxes en coordenadas del mundo
    final Rect playerHitbox = player.hitbox;
    final Rect monedaHitbox = moneda.hitbox;

    // Solo ajustar la moneda por worldOffset, el jugador ya está en coordenadas de pantalla
    final Rect playerHitboxScreen = playerHitbox;
    final Rect monedaHitboxScreen = monedaHitbox.translate(-worldOffset, 0);

    bool collision = playerHitboxScreen.overlaps(monedaHitboxScreen);
    return collision;
  }
}
