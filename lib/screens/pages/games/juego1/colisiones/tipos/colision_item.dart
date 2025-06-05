import '../../../../../../dependencias/imports.dart';

class ColisionItem {
  bool verificar(Player player, MonedaBase moneda, double worldOffset) {
    if (moneda.isCollected) return false;

    // Obtener hitboxes en coordenadas del mundo
    final Rect playerHitbox = player.hitbox;
    final Rect monedaHitbox = moneda.hitbox;

    // Añadir un pequeño margen a la hitbox del jugador para mejorar la detección
    final Rect playerHitboxExpanded = Rect.fromLTWH(
      playerHitbox.left - 5,
      playerHitbox.top - 5,
      playerHitbox.width + 10,
      playerHitbox.height + 10
    );
    
    // Solo ajustar la moneda por worldOffset, el jugador ya está en coordenadas de pantalla
    final Rect monedaHitboxScreen = monedaHitbox.translate(-worldOffset, 0);

    bool collision = playerHitboxExpanded.overlaps(monedaHitboxScreen);
    return collision;
  }
}
