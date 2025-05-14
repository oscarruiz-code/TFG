import 'package:flutter/material.dart';

class Rampa {
  final double x;
  final double y;
  final double width;
  final double height;
  final bool invertida;
  
  String get sprite => invertida ? 
    'assets/objetos/rampa/rampa_invertida.png' : 
    'assets/objetos/rampa/rampa.png';
  
  Rampa({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.invertida = false,
  });

  Rect get hitbox => Rect.fromLTWH(x, y, width, height);
}