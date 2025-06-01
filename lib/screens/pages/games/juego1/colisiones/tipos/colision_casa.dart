import '../../../../../../dependencias/imports.dart';

class ColisionCasa {
  bool verificar(Player player, Casa casa, double worldOffset) {
    // El jugador ya está en coordenadas de pantalla, solo ajustamos la casa
    final casaScreenX = casa.x - worldOffset;
    
    final casaHitbox = Rect.fromLTWH(
      casaScreenX + (casa.width * 0.1),
      casa.hitbox.top,
      casa.width * 0.8,
      casa.height * 0.8
    );
    
    // Usamos directamente el hitbox del jugador sin ajustar por worldOffset
    final playerHitbox = player.hitbox;
    
    return playerHitbox.overlaps(casaHitbox);
  }
}