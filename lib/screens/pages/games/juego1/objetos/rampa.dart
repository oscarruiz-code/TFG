import 'package:flutter/material.dart';

class Rampa {
  final double x;
  final double y;
  final double width;
  final double height;
  
  String get sprite => 'assets/objetos/rampa/rampa.png';
  
  Rampa({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  Rect get hitbox => Rect.fromLTWH(
    x + (width * 0.09),
    y + (height * 0.01),
    width * 0.85,
    height * 0.95,
  );

  // Método para calcular la altura en un punto específico de la rampa
  double getAlturaEnPunto(double puntoX) {
    double porcentajeX = (puntoX - x) / width;
    // Calculamos la altura base de la rampa
    double alturaBase = y + (height * 0.75) - (height * 0.85 * porcentajeX);
    
    // Suavizamos la transición al final de la rampa (último 40%)
    if (porcentajeX > 0.6) {
      // Calculamos un factor de suavizado para el final con una curva más suave
      double factor = ((porcentajeX - 0.6) / 0.4);
      // Aplicamos una curva de octavo grado para una transición extremadamente suave
      factor = factor * factor * factor * factor * factor * factor * factor * factor;
      // Interpolamos suavemente entre la altura de la rampa y la altura del suelo
      return alturaBase + (y - alturaBase) * factor;
    }
    
    return alturaBase;
  }
}