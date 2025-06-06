/// Clase que define la animación de andar agachado del personaje principal.
/// 
/// Contiene las rutas de los sprites utilizados en la animación,
/// la velocidad de movimiento, el tiempo entre frames y las dimensiones
/// del hitbox cuando el personaje está andando agachado.
class AnimacionAndarAgachado {
  /// Lista de rutas a los sprites utilizados en la animación de andar agachado.
  static const List<String> sprites = [
    'assets/personajes/principal/andar_agachado/andar_agachado1.png',
    'assets/personajes/principal/andar_agachado/andar_agachado2.png',
    'assets/personajes/principal/andar_agachado/andar_agachado3.png',
    'assets/personajes/principal/andar_agachado/andar_agachado4.png',
    'assets/personajes/principal/andar_agachado/andar_agachado5.png',
    'assets/personajes/principal/andar_agachado/andar_agachado6.png',
  ];
  
  /// Velocidad de movimiento del personaje cuando anda agachado.
  /// Ajustada proporcionalmente con la velocidad normal.
  static const double velocidad = 250;
  
  /// Tiempo entre frames de la animación en segundos.
  /// Igualada con la animación normal.
  static const double frameTime = 0.03;
  
  // Hitbox dimensions for crouched walking
  /// Ancho del hitbox cuando el personaje está andando agachado.
  static const double hitboxWidth = 0.9;
  /// Altura del hitbox cuando el personaje está andando agachado.
  static const double hitboxHeight = 0.8;
  /// Desplazamiento horizontal del hitbox.
  static const double hitboxOffsetX = 0.5;
  /// Desplazamiento vertical del hitbox.
  static const double hitboxOffsetY = 0.5;
}