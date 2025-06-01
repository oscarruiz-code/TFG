import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  final bool victory;
  final int coins;
  final int score;
  final VoidCallback onRetry;
  final VoidCallback onMenu;
  final VoidCallback onSaveAndExit;

  const GameOverDialog({
    super.key,
    required this.victory,
    required this.coins,
    required this.score,
    required this.onRetry,
    required this.onMenu,
    required this.onSaveAndExit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(victory ? '¡Victoria!' : 'Game Over'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Monedas: $coins'),
          if (victory) Text('Puntuación: $score'),
        ],
      ),
      actions: [
        if (!victory) ...[  // Solo mostrar estos botones si no es victoria
          TextButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
          TextButton(
            onPressed: onSaveAndExit,
            child: const Text('Guardar y Salir'),
          ),
        ],
        TextButton(
          onPressed: onMenu,
          child: const Text('Menú'),
        ),
      ],
    );
  }
}