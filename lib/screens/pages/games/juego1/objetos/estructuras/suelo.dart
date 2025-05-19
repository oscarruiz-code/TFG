import 'package:flutter/material.dart';

class Suelo {
  final double x;
  final double y;
  final double width;
  final double height;
  final String sprite;

  Suelo({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.sprite = 'assets/objetos/suelo/suelo.png',
  });

  Rect get hitbox => Rect.fromLTWH(
    x + (width * 0.05),
    y + (height * 0.40),
    width * 0.88,
    height * 0.7,
  );
}