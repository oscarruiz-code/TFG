/// Clase que define la animación de salto agachado del personaje principal.
/// 
/// Contiene las rutas de los sprites utilizados en la animación,
/// la fuerza del salto, la gravedad, el tiempo entre frames
/// y las dimensiones del hitbox cuando el personaje salta estando agachado.
class AnimacionSaltoAgachado {
  /// Lista de rutas a los sprites utilizados en la animación de salto agachado.
  static const List<String> sprites = [
    'assets/personajes/principal/saltar_agachado/saltar_agachado1.png',
    'assets/personajes/principal/saltar_agachado/saltar_agachado2.png',
  ];
  
  /// Fuerza vertical aplicada al personaje al saltar estando agachado.
  /// Aumentada de 150.0 para saltos aún más altos.
  static const double fuerzaSalto = 320.0;
  
  /// Fuerza de gravedad aplicada al personaje durante el salto.
  /// Aumentada de 300.0 para caídas aún más rápidas.
  static const double gravedad = 700.0;
  
  /// Tiempo entre frames de la animación en segundos durante el ascenso.
  static const double frameTime = 0.05;
  
  /// Tiempo entre frames de la animación en segundos durante la caída.
  static const double frameTimeCaida = 0.1;

  // Hitbox dimensions for crouched jumping
  /// Ancho del hitbox cuando el personaje salta estando agachado.
  /// Igual que salto normal.
  static const double hitboxWidth = 0.7;
  
  /// Altura del hitbox cuando el personaje salta estando agachado.
  /// Igual que salto normal.
  static const double hitboxHeight = 0.35;
  
  /// Desplazamiento vertical del hitbox.
  /// Igual que salto normal.
  static const double hitboxOffsetY = 0.3;
  
  /// Desplazamiento horizontal del hitbox.
  /// Igual que salto normal para mantener consistencia en el posicionamiento.
  static const double hitboxOffsetX = 0.4;
}
