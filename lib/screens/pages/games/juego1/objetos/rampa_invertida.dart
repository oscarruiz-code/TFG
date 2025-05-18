import 'package:flutter/material.dart';

class RampaInvertida {
  final double x;
  final double y;
  final double width;
  final double height;
  
  String get sprite => 'assets/objetos/rampa/rampa_invertida.png';
  
  RampaInvertida({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  Rect get hitbox => Rect.fromLTWH(
    x + (width * 0.3),   // Aumentamos el offset como en la rampa normal
    y + (height * 0.1),
    width * 0.60,        // Reducimos el ancho del hitbox
    height * 0.85,
  );

  // Método para calcular la altura en un punto específico de la rampa
  double getAlturaEnPunto(double puntoX) {
    double porcentajeX = (puntoX - x) / width;
    // Ahora la altura aumenta de izquierda a derecha
    double alturaBase = y + (height * porcentajeX);
    
    // Suavizamos solo el final de la rampa (último 3%)
    if (porcentajeX > 0.97) {
      // Factor de suavizado extremadamente corto
      double factor = ((porcentajeX - 0.97) / 0.03);
      // Aplicamos una curva simple para el final
      factor = factor * factor;
      // Interpolamos con el suelo
      return alturaBase + (y - alturaBase) * factor;
    }
    
    return alturaBase;
  }
}