import '../../../../../../dependencias/imports.dart';

/// Clase que gestiona la detección de colisiones entre el jugador y los items coleccionables.
/// Proporciona métodos para verificar si existe superposición entre los hitboxes.
class ColisionItem {
  /// Verifica si existe una colisión entre el jugador y una moneda.
  /// 
  /// Parámetros:
  /// - [player]: Objeto jugador con su hitbox en coordenadas de pantalla.
  /// - [moneda]: Objeto moneda que se quiere comprobar.
  /// - [worldOffset]: Desplazamiento del mundo para ajustar la posición de la moneda.
  /// 
  /// Retorna [bool] indicando si hay colisión (true) o no (false).
  /// No detecta colisión si la moneda ya ha sido recolectada.
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
