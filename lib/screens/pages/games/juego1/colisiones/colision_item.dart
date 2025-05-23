import '../../../../../dependencias/imports.dart';

class ColisionItem {
  bool verificar(dynamic player, dynamic hitbox) {
    // Ajustar la hitbox según el estado del jugador
    Rect playerHitbox = player.isSliding 
        ? Rect.fromLTWH(
            player.x - (player.size * 0.425),
            player.y - (player.size * 0.2),
            player.size * 0.85,
            player.size * 0.4,
          )
        : player.isCrouching
            ? Rect.fromLTWH(
                player.x - (player.size * 0.425),
                player.y - (player.size * 0.3),
                player.size * 0.85,
                player.size * 0.6,
              )
            : player.hitbox;
    return playerHitbox.overlaps(hitbox);
  }
}