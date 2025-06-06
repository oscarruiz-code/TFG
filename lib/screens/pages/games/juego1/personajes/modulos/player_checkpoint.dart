import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class PlayerCheckpoint {
  double checkpointX = 0;
  double checkpointY = 0;
  double checkpointWorldOffset = 0;
  
  // Bus de eventos
  final GameEventBus _eventBus = GameEventBus();
  
  PlayerCheckpoint();
  
  void setCheckpoint(double x, double y, double worldOffset) {
    checkpointX = x;
    checkpointY = y;
    checkpointWorldOffset = worldOffset;
    _eventBus.emit(GameEvents.checkpointSet);
  }

  void respawnAtCheckpoint(Player player) {
    // Restaurar la posición al último checkpoint guardado
    if (checkpointX != 0) {
      player.x = checkpointX;
      player.y = checkpointY;
  
      // Restaurar estado del jugador
      player.isJumping = false;
      player.isSliding = false;
      player.isCrouching = false;
      player.velocidadVertical = 0;
      player.currentState = PenguinPlayerState.idle;
  
      // Emitir evento de respawn para notificar a otros componentes
      _eventBus.emit(GameEvents.playerRespawn);
    }
  }

  void morir(Player player) {
    // Reiniciar al jugador en su último checkpoint
    player.isJumping = false;
    player.isSliding = false;
    player.velocidadVertical = 0;

    // Emitir evento para que el juego maneje la pérdida de vida y el respawn
    _eventBus.emit(GameEvents.playerRespawn);

    // Restaurar estado del jugador
    player.currentState = PenguinPlayerState.idle;

    // Si hay un checkpoint guardado, respawnear allí
    if (checkpointX != 0) {
      respawnAtCheckpoint(player);
    }
  }
}