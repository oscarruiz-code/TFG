class AnimacionSaltoAgachado {
  static const List<String> sprites = [
    'assets/personajes/principal/saltar_agachado/saltar_agachado1.png',
    'assets/personajes/principal/saltar_agachado/saltar_agachado2.png',
  ];
  
  static const double fuerzaSalto = 400.0; // Menor fuerza que el salto normal
  static const double gravedad = 1500.0; // Misma gravedad
  static const double frameTime = 0.05;
  static const double frameTimeCaida = 0.14;
}