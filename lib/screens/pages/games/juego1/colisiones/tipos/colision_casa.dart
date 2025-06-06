import '../../../../../../dependencias/imports.dart';

/// Clase que gestiona la detección de colisiones entre el jugador y las casas.
/// Proporciona métodos para verificar si existe superposición entre los hitboxes.
class ColisionCasa {
  /// Verifica si existe una colisión entre el jugador y una casa.
  /// 
  /// Parámetros:
  /// - [player]: Objeto jugador con su hitbox en coordenadas de pantalla.
  /// - [casa]: Objeto casa que se quiere comprobar.
  /// - [worldOffset]: Desplazamiento del mundo para ajustar la posición de la casa.
  /// 
  /// Retorna [bool] indicando si hay colisión (true) o no (false).
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