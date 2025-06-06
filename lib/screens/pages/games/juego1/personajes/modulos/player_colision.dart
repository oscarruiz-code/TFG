import 'package:oscarruizcode_pingu/dependencias/imports.dart';

/// Maneja la detección de colisiones del jugador con elementos del entorno.
///
/// Define los hitboxes dinámicos según el estado del jugador (agachado, saltando, deslizándose),
/// inicializa los listeners para eventos de colisión y procesa las respuestas a estas colisiones.
class PlayerCollision {
  double x;
  double y;
  double size;
  bool isSliding;
  bool isJumping;
  bool isCrouching;
  double lastMoveDirection;
  
  // Bus de eventos
  final GameEventBus _eventBus = GameEventBus();
  
  PlayerCollision({
    required this.x,
    required this.y,
    required this.size,
    required this.isSliding,
    required this.isJumping,
    required this.isCrouching,
    required this.lastMoveDirection,
  });
  
  void initializeCollisionListeners(Player player) {
    _eventBus.on(GameEvents.playerCollisionTop, (_) {
      player.isJumping = false;
      player.velocidadVertical = 0;
      player.isOnGround = true;
      player.canJump = true;

      if (player.currentState == PenguinPlayerState.jumping) {
        player.currentState =
            player.isCrouching
                ? PenguinPlayerState.crouching
                : PenguinPlayerState.idle;
      }
    });

    _eventBus.on(GameEvents.playerCollisionBottom, (_) {
      if (player.velocidadVertical < 0) {
        player.velocidadVertical = 0;
      }
    });

    _eventBus.on(GameEvents.playerInVoid, (_) {
      player.morir();
    });

    _eventBus.on(GameEvents.playerCollisionWithHouse, (_) {
      // Emitir evento de victoria
      _eventBus.emit(GameEvents.gameOver, {'victory': true});

      // Detener al jugador
      player.lastMoveDirection = 0;
      player.isJumping = false;
      player.isSliding = false;
      player.velocidadVertical = 0;

      // Cambiar estado a idle para mostrar animación de victoria
      player.currentState = PenguinPlayerState.idle;
    });

    _eventBus.on(GameEvents.coinCollected, (coin) {
      coin.markAsCollected();
      // Aplicar el efecto específico de la moneda
      coin.aplicarEfecto(player);
      // Solo incrementar el contador si la moneda tiene valor
      if (coin.valor > 0) {
        player.monedas += coin.valor;
      }
    });
  }

  void disposeCollisionListeners() {
    _eventBus.offAll(GameEvents.playerCollisionTop);
    _eventBus.offAll(GameEvents.playerCollisionBottom);
    _eventBus.offAll(GameEvents.playerInVoid);
    _eventBus.offAll(GameEvents.playerCollisionWithHouse);
    _eventBus.offAll(GameEvents.coinCollected);
  }
  
  // Hitbox del jugador
  Rect get hitbox {
    if (isSliding) {
      return _getHitboxFromAnimation(
        isCrouching
            ? AnimacionDeslizarseAgachado.hitboxWidth
            : AnimacionDeslizarse.hitboxWidth,
        isCrouching
            ? AnimacionDeslizarseAgachado.hitboxHeight
            : AnimacionDeslizarse.hitboxHeight,
        isCrouching
            ? AnimacionDeslizarseAgachado.hitboxOffsetX
            : AnimacionDeslizarse.hitboxOffsetX,
        isCrouching
            ? AnimacionDeslizarseAgachado.hitboxOffsetY
            : AnimacionDeslizarse.hitboxOffsetY,
      );
    } else if (isJumping) {
      return _getHitboxFromAnimation(
        isCrouching
            ? AnimacionSaltoAgachado.hitboxWidth
            : AnimacionSalto.hitboxWidth,
        isCrouching
            ? AnimacionSaltoAgachado.hitboxHeight
            : AnimacionSalto.hitboxHeight,
        isCrouching
            ? AnimacionSaltoAgachado.hitboxOffsetX
            : AnimacionSalto.hitboxOffsetX,
        isCrouching
            ? AnimacionSaltoAgachado.hitboxOffsetY
            : AnimacionSalto.hitboxOffsetY,
      );
    } else if (isCrouching) {
      return _getHitboxFromAnimation(
        lastMoveDirection != 0
            ? AnimacionAndarAgachado.hitboxWidth
            : AnimacionAgacharse.hitboxWidth,
        lastMoveDirection != 0
            ? AnimacionAndarAgachado.hitboxHeight
            : AnimacionAgacharse.hitboxHeight,
        lastMoveDirection != 0
            ? AnimacionAndarAgachado.hitboxOffsetX
            : AnimacionAgacharse.hitboxOffsetX,
        lastMoveDirection != 0
            ? AnimacionAndarAgachado.hitboxOffsetY
            : AnimacionAgacharse.hitboxOffsetY,
      );
    } else {
      return _getHitboxFromAnimation(
        AnimacionAndar.hitboxWidth,
        AnimacionAndar.hitboxHeight,
        AnimacionAndar.hitboxOffsetX,
        AnimacionAndar.hitboxOffsetY,
      );
    }
  }

  Rect _getHitboxFromAnimation(
    double width,
    double height,
    double offsetX,
    double offsetY,
  ) {
    return Rect.fromLTWH(
      x - (size * offsetX),
      y - (size * offsetY),
      size * width,
      size * height,
    );
  }
}