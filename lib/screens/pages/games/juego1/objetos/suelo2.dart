import 'package:flutter/material.dart';

class Suelo2 {
  final double x;
  final double y;
  final double width;
  final double height;
  final String sprite;

  Suelo2({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.sprite = 'assets/objetos/suelo/suelo2.png',
  });

  Rect get hitbox => Rect.fromLTWH(
    x + (width * 0.01),  // Ajustado para coincidir con la visualización
    y + (height * 0.35),  // Ajustado para coincidir con la visualización
    width * 0.93,  // Ajustado para coincidir con la visualización
    height * 0.45,  // Ajustado para coincidir con la visualización
  );
}