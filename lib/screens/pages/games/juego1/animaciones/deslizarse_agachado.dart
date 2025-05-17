class AnimacionDeslizarseAgachado {
  static const List<String> sprites = [
    'assets/personajes/principal/deslizarse_agachado/deslizarse_agachado1.png',
    'assets/personajes/principal/deslizarse_agachado/deslizarse_agachado2.png',
    'assets/personajes/principal/deslizarse_agachado/deslizarse_agachado3.png',
  ];
  
  static const double velocidad = 120.0; // Más lento que el deslizamiento normal
  static const double distancia = 60.0; // Menor distancia que el deslizamiento normal
  static const double frameTime = 0.06;
  static const double frameTimeUltimo = 0.35;
}