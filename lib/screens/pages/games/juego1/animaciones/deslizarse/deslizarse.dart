/// Clase que define la animación de deslizarse del personaje principal.
/// 
/// Contiene las rutas de los sprites utilizados en la animación,
/// la velocidad de movimiento, la distancia recorrida, el tiempo entre frames
/// y las dimensiones del hitbox cuando el personaje se desliza.
class AnimacionDeslizarse {
  /// Lista de rutas a los sprites utilizados en la animación de deslizarse.
  static const List<String> sprites = [
    'assets/personajes/principal/deslizarse/deslizarse1.png',
    'assets/personajes/principal/deslizarse/deslizarse2.png',
    'assets/personajes/principal/deslizarse/deslizarse3.png',
    'assets/personajes/principal/deslizarse/deslizarse4.png',
  ];
  
  /// Velocidad de movimiento del personaje cuando se desliza.
  /// Ajustado para deslizamiento de 20 unidades.
  static const double velocidad = 200.0;
  
  /// Distancia que recorre el personaje al deslizarse.
  /// Distancia exacta de 20 unidades (actualizada a 150.0).
  static const double distancia = 150.0;
  
  /// Tiempo entre frames de la animación en segundos.
  static const double frameTime = 0.03;
  
  /// Tiempo del último frame de la animación en segundos.
  static const double frameTimeUltimo = 0.3;
  
  // Hitbox dimensions for sliding
  /// Ancho del hitbox cuando el personaje se desliza.
  static const double hitboxWidth = 0.9;
  
  /// Altura del hitbox cuando el personaje se desliza.
  static const double hitboxHeight = 0.35;
  
  /// Desplazamiento horizontal del hitbox.
  static const double hitboxOffsetX = 0.45;
  
  /// Desplazamiento vertical del hitbox.
  static const double hitboxOffsetY = 0.15;
}