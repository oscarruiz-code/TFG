/// Clase que define la animación de deslizarse agachado del personaje principal.
///
/// Contiene las rutas de los sprites utilizados en la animación,
/// la velocidad de movimiento, la distancia recorrida, el tiempo entre frames
/// y las dimensiones del hitbox cuando el personaje se desliza agachado.
class AnimacionDeslizarseAgachado {
  /// Lista de rutas a los sprites utilizados en la animación de deslizarse agachado.
  static const List<String> sprites = [
    'assets/personajes/principal/deslizarse_agachado/deslizarse_agachado1.png',
    'assets/personajes/principal/deslizarse_agachado/deslizarse_agachado2.png',
    'assets/personajes/principal/deslizarse_agachado/deslizarse_agachado3.png',
  ];

  /// Velocidad de movimiento del personaje cuando se desliza agachado.
  /// Velocidad más lenta cuando está agachado.
  static const double velocidad = 150.0;

  /// Distancia que recorre el personaje al deslizarse agachado.
  /// Aumentado de 20.0 a 50.0 y luego a 100.0 unidades.
  static const double distancia = 100.0;

  /// Tiempo entre frames de la animación en segundos.
  static const double frameTime = 0.04;

  /// Tiempo del último frame de la animación en segundos.
  static const double frameTimeUltimo = 0.4;

  // Hitbox dimensions for crouched sliding
  /// Ancho del hitbox cuando el personaje se desliza agachado.
  static const double hitboxWidth = 0.9;

  /// Altura del hitbox cuando el personaje se desliza agachado.
  static const double hitboxHeight = 0.35;

  /// Desplazamiento horizontal del hitbox.
  static const double hitboxOffsetX = 0.45;

  /// Desplazamiento vertical del hitbox.
  static const double hitboxOffsetY = 0.35;
}
