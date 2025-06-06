import 'package:oscarruizcode_pingu/dependencias/imports.dart';

/// Diálogo que se muestra al finalizar un juego, ya sea por victoria o derrota.
///
/// Presenta información sobre el resultado del juego, incluyendo monedas recolectadas,
/// puntuación obtenida y duración de la partida. Ofrece opciones para reintentar,
/// volver al menú principal o guardar y salir.
class GameOverDialog extends StatelessWidget {
  final bool victory;
  final int coins;
  final int score;
  final int duration;
  final VoidCallback onRetry;
  final VoidCallback onMenu;
  final VoidCallback onSaveAndExit;
  final int userId;
  final String username;

  const GameOverDialog({
    super.key,
    required this.victory,
    required this.coins,
    required this.score,
    required this.duration,
    required this.onRetry,
    required this.onMenu,
    required this.onSaveAndExit,
    required this.userId,
    required this.username,
  });

  /// Formatea la duración en segundos al formato mm:ss.
  ///
  /// Convierte el total de segundos en minutos y segundos, asegurando
  /// que los segundos siempre se muestren con dos dígitos.
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
          Text('Puntuación: $score'), 
          Text('Duración: ${_formatDuration(duration)}'),
        ],
      ),
      actions: [
        if (!victory) ...[  
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              // Navegar a la pantalla de transición en lugar de directamente al juego
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => TransicionGame1(
                    userId: userId, 
                    username: username,
                  ),
                ),
              );
            },
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