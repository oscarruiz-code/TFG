/// Clase que define la animación de agacharse del personaje principal.
/// 
/// Contiene las rutas de los sprites utilizados en la animación,
/// el tiempo entre frames y las dimensiones del hitbox cuando
/// el personaje está agachado.
class AnimacionAgacharse {
  /// Lista de rutas a los sprites utilizados en la animación de agacharse.
  static const List<String> sprites = [
    'assets/personajes/principal/agacharse/agacharse1.png',
    'assets/personajes/principal/agacharse/agacharse2.png',
    'assets/personajes/principal/agacharse/agacharse3.png',
  ];
  
  /// Tiempo entre frames de la animación en segundos.
  static const double frameTime = 0.1;
  
  // Hitbox dimensions for crouching
  /// Ancho del hitbox cuando el personaje está agachado.
  static const double hitboxWidth = 0.9;
  /// Altura del hitbox cuando el personaje está agachado.
  static const double hitboxHeight = 0.8;
  /// Desplazamiento horizontal del hitbox.
  static const double hitboxOffsetX = 0.5;
  /// Desplazamiento vertical del hitbox.
  static const double hitboxOffsetY = 0.35;
}