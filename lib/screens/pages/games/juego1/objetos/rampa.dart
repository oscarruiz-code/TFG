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
    x + (width * 0.3),   // Aumentamos significativamente el offset
    y + (height * 0.01),
    width * 0.45,        // Reducimos aún más el ancho del hitbox
    height * 0.95,
  );

  // Método para calcular la altura en un punto específico de la rampa
  double getAlturaEnPunto(double puntoX) {
    double porcentajeX = (puntoX - x) / width;
    // Calculamos la altura base de la rampa con una pendiente más pronunciada
    double alturaBase = y + height - (height * porcentajeX);
    
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