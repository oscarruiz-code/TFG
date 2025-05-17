class AnimacionDeslizarse {
  static const List<String> sprites = [
    'assets/personajes/principal/deslizarse/deslizarse1.png',
    'assets/personajes/principal/deslizarse/deslizarse2.png',
    'assets/personajes/principal/deslizarse/deslizarse3.png',
    'assets/personajes/principal/deslizarse/deslizarse4.png',
  ];
  
  static const double velocidad = 200.0; // Aumentada para deslizamiento más dinámico
  static const double distancia = 100.0; // Mayor distancia de deslizamiento
  static const double frameTime = 0.04; // Más rápido para mejor fluidez
  static const double frameTimeUltimo = 0.25; // Reducido para mejor transición
}