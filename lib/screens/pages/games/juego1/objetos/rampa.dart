import 'package:flutter/material.dart';

class Rampa {
  final double x;
  final double y;
  final double width;
  final double height;
  final String sprite;

  Rampa({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.sprite = 'assets/objetos/rampa.png',
  });

  Rect get hitbox => Rect.fromLTWH(x, y, width, height);
}