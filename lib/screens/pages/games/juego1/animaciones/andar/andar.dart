/// Clase que define la animación de andar del personaje principal.
/// 
/// Contiene las rutas de los sprites utilizados en la animación,
/// la velocidad de movimiento, el tiempo entre frames y las dimensiones
/// del hitbox cuando el personaje está andando.
class AnimacionAndar {
  /// Lista de rutas a los sprites utilizados en la animación de andar.
  static const List<String> sprites = [
    'assets/personajes/principal/andar/andar1.png',
    'assets/personajes/principal/andar/andar2.png',
    'assets/personajes/principal/andar/andar3.png',
    'assets/personajes/principal/andar/andar4.png',
    'assets/personajes/principal/andar/andar5.png',
    'assets/personajes/principal/andar/andar6.png',
    'assets/personajes/principal/andar/andar7.png',
  ];
  
  /// Velocidad de movimiento del personaje cuando anda.
  /// Aumentada de 150 a 250 para un movimiento más rápido.
  static const double velocidad = 250;
  
  /// Tiempo entre frames de la animación en segundos.
  /// Reducido para una animación más rápida.
  static const double frameTime = 0.04;
  
  // Hitbox dimensions for normal walking
  /// Ancho del hitbox cuando el personaje está andando.
  static const double hitboxWidth = 0.85;
  /// Altura del hitbox cuando el personaje está andando.
  static const double hitboxHeight = 0.94;
  /// Desplazamiento horizontal del hitbox.
  static const double hitboxOffsetX = 0.425;
  /// Desplazamiento vertical del hitbox.
  static const double hitboxOffsetY = 0.50;
}