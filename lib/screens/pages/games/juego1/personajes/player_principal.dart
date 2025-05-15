import '../../../../../dependencias/imports.dart';

enum PenguinPlayerState {
  idle,
  walking,
  jumping,
  sliding,
  crouching,
  walkingCrouched
}

class Player {
  static const double defaultHeight = 100.0;
  
  double x;
  double y;
  double velocidadVertical = 0;
  double gravedad = AnimacionSalto.gravedad;
  double fuerzaSalto = -AnimacionSalto.fuerzaSalto;
  double size = defaultHeight;
  bool isJumping = false;
  bool isSliding = false;
  bool isFacingRight = true;
  double speed = AnimacionAndar.velocidad;
  double lastMoveDirection = 0;
  bool canSlide = true;
  bool canJump = true;
  
  PenguinPlayerState currentState = PenguinPlayerState.idle;
  double animationTime = 0;
  final GameEventBus _eventBus = GameEventBus();
  
  Player({
    required this.x,
    required this.y,
  });
  
  Rect get hitbox => Rect.fromLTWH(
    x - (size * 0.4),
    y - (size * 0.5),
    size * 0.8,
    size * (isSliding ? 0.5 : 1.0),
  );
  
  bool isCrouching = false;
  
  void move(double dx, double dy, {required double groundLevel}) {
    if (isSliding) return;
    
    if (dx != 0) {
      x += dx * (isCrouching ? AnimacionAndarAgachado.velocidad : speed);
      isFacingRight = dx > 0;
      lastMoveDirection = dx;
      
      // Emitir evento de actualización de posición
      _eventBus.emit(GameEvents.playerUpdatePosition, {
        'x': x,
        'y': y,
        'isFacingRight': isFacingRight
      });
      
      if (currentState != PenguinPlayerState.jumping) {
        currentState = isCrouching ? PenguinPlayerState.walkingCrouched : PenguinPlayerState.walking;
        _eventBus.emit(GameEvents.playerMove, {'direction': dx > 0 ? 'right' : 'left'});
      }
    } else {
      lastMoveDirection = 0;
      if (currentState != PenguinPlayerState.jumping && !isSliding) {
        currentState = isCrouching ? PenguinPlayerState.crouching : PenguinPlayerState.idle;
        _eventBus.emit(GameEvents.playerIdle);
      }
    }
  }

  void crouch() {
    if (!isJumping && !isSliding) {
      isCrouching = true;
      currentState = lastMoveDirection != 0 ? 
        PenguinPlayerState.walkingCrouched : PenguinPlayerState.crouching;
      _eventBus.emit(GameEvents.playerCrouch); // Emitir evento de agacharse
    }
  }

  void standUp() {
    if (isCrouching) {
      isCrouching = false;
      currentState = lastMoveDirection != 0 ? 
        PenguinPlayerState.walking : PenguinPlayerState.idle;
      _eventBus.emit(GameEvents.playerStandUp); // Emitir evento de levantarse
    }
  }

  void jump() {
    if (canJump && !isJumping && !isSliding) {
      isJumping = true;
      velocidadVertical = fuerzaSalto;
      currentState = PenguinPlayerState.jumping;
      _eventBus.emit(GameEvents.playerJump); // Emitir evento de salto
    }
  }

  void slide() {
    if (canSlide && !isSliding && !isJumping) {
      isSliding = true;
      currentState = PenguinPlayerState.sliding;
      _eventBus.emit(GameEvents.playerSlide); // Emitir evento de deslizamiento
      
      // Programar el fin del deslizamiento
      Future.delayed(const Duration(milliseconds: 800), () {
        isSliding = false;
        currentState = PenguinPlayerState.idle;
        _eventBus.emit(GameEvents.playerEndSlide); // Emitir evento de fin de deslizamiento
      });
    }
  }

  void updateAnimation(double dt) {
    animationTime += dt;
    if (isJumping) {
      velocidadVertical += gravedad * dt;
      y += velocidadVertical * dt;
      
      _eventBus.emit(GameEvents.playerUpdatePosition, {
        'x': x,
        'y': y,
        'velocidadVertical': velocidadVertical
      });
    }
  }

  void handleCollision(dynamic objeto) {
    _eventBus.emit(GameEvents.playerCollision, {
      'objeto': objeto,
      'playerState': currentState.toString()
    });
  }

  String getCurrentSprite() {
    switch (currentState) {
      case PenguinPlayerState.idle:
        return AnimacionAndar.sprites[0];
      case PenguinPlayerState.walking:
        // Sincronizar la animación con el movimiento
        int frame = ((animationTime / AnimacionAndar.frameTime) * speed).floor() % AnimacionAndar.sprites.length;
        return AnimacionAndar.sprites[frame];
      case PenguinPlayerState.jumping:
        if (velocidadVertical < -200) {
          double frameTime = velocidadVertical < 0 ? 
            AnimacionSalto.frameTime : AnimacionSalto.frameTimeCaida;
          int frame = (animationTime / frameTime).floor() % AnimacionSalto.sprites.length;
          return AnimacionSalto.sprites[frame];
        } else if (velocidadVertical < 200) {
          return AnimacionSalto.sprites[1];
        } else {
          return AnimacionSalto.sprites[2];
        }
      case PenguinPlayerState.sliding:
        double tiempoTotal = 0.8;
        double tiempoTranscurrido = (animationTime % tiempoTotal) / tiempoTotal;
        
        if (tiempoTranscurrido < 0.25) {
          return AnimacionDeslizarse.sprites[0];
        } else if (tiempoTranscurrido < 0.5) {
          return AnimacionDeslizarse.sprites[1];
        } else if (tiempoTranscurrido < 0.75) {
          return AnimacionDeslizarse.sprites[2];
        } else {
          return AnimacionDeslizarse.sprites[3];
        }
      case PenguinPlayerState.crouching:
        int frame = (animationTime / AnimacionAgacharse.frameTime).floor() % AnimacionAgacharse.sprites.length;
        return AnimacionAgacharse.sprites[frame];
      case PenguinPlayerState.walkingCrouched:
        int frame = (animationTime / AnimacionAndarAgachado.frameTime).floor() % AnimacionAndarAgachado.sprites.length;
        return AnimacionAndarAgachado.sprites[frame];
    }
  }

}