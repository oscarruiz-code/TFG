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
    this.sprite = 'assets/objetos/suelo2.png',
  });

  Rect get hitbox => Rect.fromLTWH(x, y, width, height);
}