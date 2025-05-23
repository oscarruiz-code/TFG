import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  final bool victory;
  final int coins;
  final int score;  // Nuevo parámetro
  final VoidCallback onRetry;
  final VoidCallback onMenu;

  const GameOverDialog({
    Key? key,
    required this.victory,
    required this.coins,
    required this.score,  // Agregamos el parámetro requerido
    required this.onRetry,
    required this.onMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(victory ? '¡Victoria!' : 'Game Over'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Monedas: $coins'),
          if (victory) Text('Puntuación: $score'),  // Mostramos el score solo en victoria
        ],
      ),
      actions: [
        TextButton(
          onPressed: onRetry,
          child: const Text('Reintentar'),
        ),
        TextButton(
          onPressed: onMenu,
          child: const Text('Menú'),
        ),
      ],
    );
  }
}