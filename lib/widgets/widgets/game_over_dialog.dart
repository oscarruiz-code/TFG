import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  final bool victory;
  final int coins;
  final int score;
  final int duration; // Añadido parámetro de duración
  final VoidCallback onRetry;
  final VoidCallback onMenu;
  final VoidCallback onSaveAndExit;

  const GameOverDialog({
    super.key,
    required this.victory,
    required this.coins,
    required this.score,
    required this.duration, // Añadido como requerido
    required this.onRetry,
    required this.onMenu,
    required this.onSaveAndExit,
  });

  // Función para formatear la duración en formato mm:ss
  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(victory ? '¡Victoria!' : 'Game Over'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Monedas: $coins'),
          Text('Puntuación: $score'), // Mostrar siempre la puntuación
          Text('Duración: ${_formatDuration(duration)}'), // Añadida la duración
        ],
      ),
      actions: [
        if (!victory) ...[  
          TextButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
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