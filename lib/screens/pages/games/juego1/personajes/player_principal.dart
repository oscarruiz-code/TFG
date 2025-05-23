import '../../../../../dependencias/imports.dart';

enum PenguinPlayerState {
  idle,
  walking,
  jumping,
  sliding,
  crouching,
  walkingCrouched,
}

class Player {
  // Constantes
  static const double defaultHeight = 50.0;
  static const double frameTime = 0.1;

  // Propiedades de posición y dimensiones
  double x;
  double y;
  double size = defaultHeight;

  // Propiedades de movimiento
  double velocidadVertical = 0;
  double gravedad = AnimacionSalto.gravedad;
  double fuerzaSalto = -AnimacionSalto.fuerzaSalto;
  final double velocidadBase = AnimacionAndar.velocidad * 0.6;
  final double velocidadBaseAgachado = AnimacionAndarAgachado.velocidad * 0.6;
  double velocidadTemp = 0;
  double lastMoveDirection = 0;
  bool isFacingRight = true;
  double speed = 0; // <-- Añade esta línea

  // Estados del jugador
  bool isJumping = false;
  bool isSliding = false;
  bool isCrouching = false;
  bool isStandingUp = false;
  bool isInvulnerable = false;
  bool canSlide = true;
  bool canJump = true;

  // Animación
  int crouchFrame = 0;
  int slideFrame = 0;
  int frameIndex = 0;
  double slideDistance = 0;
  double animationTime = 0;
  PenguinPlayerState currentState = PenguinPlayerState.idle;

  // Sistema de checkpoint
  double checkpointX = 0;
  double checkpointY = 0;
  double checkpointWorldOffset = 0;

  // Coleccionables y power-ups
  int monedas = 0;
  double fuerzaSaltoTemp = -AnimacionSalto.fuerzaSalto;

  // Bus de eventos
  final GameEventBus _eventBus = GameEventBus();

  Player({required this.x, required this.y});

  // Hitbox del jugador
  Rect get hitbox => Rect.fromLTWH(
    x - (size * 0.46),
    y - (size * (isCrouching ? 0.25 : 0.45)),
    size * 0.85,
    size * (isSliding ? 0.4 : (isCrouching ? 0.5 : 0.94)),
  );

  // Movimiento básico
  void move(double dx, double dy, {required double groundLevel}) {
    if (isSliding) return;

    if (dx != 0) {
      _handleMovement(dx, groundLevel);
    } else {
      _handleIdle();
    }
  }

  void _handleMovement(double dx, double groundLevel) {
    // Usar la velocidad base según el estado
    double baseSpeed = isCrouching ? velocidadBaseAgachado : velocidadBase;
    // Si hay power-up activo, usarlo, si no, usar base
    double currentSpeed = velocidadTemp > 0 ? velocidadTemp : baseSpeed;

    speed = currentSpeed;

    // Actualizar la dirección y el estado de movimiento
    isFacingRight = dx > 0;
    lastMoveDirection = dx;

    // Actualizar el estado y la posición
    if (!isJumping && !isSliding) {
      currentState =
          isCrouching
              ? PenguinPlayerState.walkingCrouched
              : PenguinPlayerState.walking;
      // Usar la posición actual (que incluye cualquier desplazamiento previo)
      x += dx * currentSpeed;
    }

    _adjustGroundPosition(groundLevel);
    _updateMovementState();
    _emitMovementEvents(dx);
  }

  void updateWalkingAnimation(double dtSeconds) {
    if (!isJumping && !isSliding && lastMoveDirection != 0) {
      animationTime += dtSeconds;
      double frameTime =
          isCrouching
              ? AnimacionAndarAgachado.frameTime
              : AnimacionAndar.frameTime;

      if (animationTime >= frameTime) {
        animationTime = 0.0;
        frameIndex =
            (frameIndex + 1) %
            (isCrouching
                ? AnimacionAndarAgachado.sprites.length
                : AnimacionAndar.sprites.length);
      }
    } else if (lastMoveDirection == 0) {
      // Resetear la animación cuando no hay movimiento
      frameIndex = 0;
      animationTime = 0.0;
    }
  }

  String _getWalkingSprite() {
    if (lastMoveDirection != 0) {
      final sprites =
          isCrouching ? AnimacionAndarAgachado.sprites : AnimacionAndar.sprites;
      return sprites[frameIndex];
    }
    return isCrouching
        ? AnimacionAndarAgachado.sprites[0]
        : AnimacionAndar.sprites[0];
  }

  // Cuando recojas una moneda de velocidad, haz esto:
  void activarPowerUpVelocidad(double nuevaVelocidad, Duration duracion) {
    velocidadTemp = nuevaVelocidad;
    Future.delayed(duracion, () {
      velocidadTemp = 0; // Vuelve a la velocidad base automáticamente
    });
  }

  void _adjustGroundPosition(double groundLevel) {
    if (y >= groundLevel - size * 0.5) {
      y = groundLevel - size * 0.5;
    }
  }

  void _updateMovementState() {
    if (!isJumping) {
      currentState =
          isCrouching
              ? PenguinPlayerState.walkingCrouched
              : PenguinPlayerState.walking;
    }
  }

  void _handleIdle() {
    lastMoveDirection = 0;
    animationTime = 0.0;
    if (!isJumping && !isSliding) {
      currentState =
          isCrouching ? PenguinPlayerState.crouching : PenguinPlayerState.idle;
      _eventBus.emit(GameEvents.playerIdle);
    }
  }

  // Obtener sprite actual
  String getCurrentSprite() {
    if (isJumping) return _getJumpingSprite();
    if (isSliding) return _getSlidingSprite();
    if (isCrouching || isStandingUp) return _getCrouchingSprite();
    return _getWalkingSprite();
  }

  String _getJumpingSprite() {
    final sprites =
        isCrouching ? AnimacionSaltoAgachado.sprites : AnimacionSalto.sprites;
    // La dirección (isFacingRight) ya se maneja en el widget que renderiza el sprite
    if (velocidadVertical < 0) return sprites[0]; // Subiendo
    if (velocidadVertical > 0)
      return isCrouching ? sprites[1] : sprites[2]; // Cayendo
    return isCrouching ? sprites[0] : sprites[1]; // Punto más alto
  }

  String _getSlidingSprite() {
    return AnimacionDeslizarse.sprites[slideFrame];
  }

  String _getCrouchingSprite() {
    if (isJumping) return AnimacionSaltoAgachado.sprites[0];
    if (isSliding) return AnimacionDeslizarseAgachado.sprites[0];
    if (lastMoveDirection != 0) {
      return AnimacionAndarAgachado.sprites[frameIndex];
    }
    return AnimacionAgacharse.sprites[crouchFrame];
  }

  void resetWalkingAnimation() {
    if (!isJumping && !isSliding) {
      animationTime = 0.0;
      frameIndex = 0;
      currentState =
          isCrouching ? PenguinPlayerState.crouching : PenguinPlayerState.idle;
    }
  }

  // Acciones del jugador
  void slide() {
    if (!canSlide || isSliding || isJumping) return;

    isSliding = true;
    slideFrame = 0;
    _performSlide();
  }

  void _performSlide() {
    final distanciaTotal = 75.0;
    final distanciaMitad = distanciaTotal / 2;
    double distanciaRecorrida = 0;
    double posicionInicial = x;
    double posicionFinal =
        posicionInicial + (isFacingRight ? distanciaTotal : -distanciaTotal);
    currentState = PenguinPlayerState.sliding;
    _eventBus.emit(GameEvents.playerSlide);

    Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (!isSliding || distanciaRecorrida >= distanciaTotal) {
        x = posicionFinal; // Aseguramos que termine exactamente en la posición final
        lastMoveDirection = 0; // Reseteamos la dirección del movimiento
        _endSlide(timer);
        return;
      }

      distanciaRecorrida += distanciaTotal * 0.1;
      double progreso = distanciaRecorrida / distanciaTotal;
      x = posicionInicial + (posicionFinal - posicionInicial) * progreso;

      _updateSlideFrame(distanciaRecorrida, distanciaMitad);
    });
  }

  void _updateSlideFrame(double distanciaRecorrida, double distanciaMitad) {
    if (isCrouching) {
      _updateCrouchingSlideFrame(distanciaRecorrida, distanciaMitad);
    } else {
      _updateNormalSlideFrame(distanciaRecorrida, distanciaMitad);
    }
  }

  void _endSlide(Timer timer) {
    timer.cancel();
    isSliding = false;
    currentState =
        isCrouching ? PenguinPlayerState.crouching : PenguinPlayerState.idle;
    _eventBus.emit(GameEvents.playerEndSlide);
  }

  void _updateCrouchingSlideFrame(
    double distanciaRecorrida,
    double distanciaMitad,
  ) {
    if (distanciaRecorrida < distanciaMitad * 0.5) {
      slideFrame = 1; // Primer frame al inicio
    } else if (distanciaRecorrida < distanciaMitad) {
      slideFrame = 2; // Segundo frame en la primera mitad
    } else {
      slideFrame = 3; // Tercer frame en la segunda mitad
    }
  }

  void _updateNormalSlideFrame(
    double distanciaRecorrida,
    double distanciaMitad,
  ) {
    if (distanciaRecorrida < distanciaMitad * 0.3) {
      slideFrame = 0; // Primer frame al inicio
    } else if (distanciaRecorrida < distanciaMitad * 0.6) {
      slideFrame = 1; // Segundo frame
    } else if (distanciaRecorrida < distanciaMitad) {
      slideFrame = 2; // Tercer frame
    } else {
      slideFrame = 3; // Cuarto frame para la segunda mitad
    }
  }

  void jump() {
    if (!canJump || isJumping || isSliding) return;

    isJumping = true;
    frameIndex = 0;
    velocidadVertical = 0;
    gravedad =
        isCrouching ? AnimacionSaltoAgachado.gravedad : AnimacionSalto.gravedad;
    velocidadVertical =
        isCrouching
            ? -AnimacionSaltoAgachado.fuerzaSalto
            : -AnimacionSalto.fuerzaSalto;
    currentState = PenguinPlayerState.jumping;
    _eventBus.emit(GameEvents.playerJump);
  }

  void crouch() {
    if (isCrouching || isSliding || isJumping) return;

    isCrouching = true;
    isStandingUp = false;
    _initializeCrouch();
  }

  void _initializeCrouch() {
    crouchFrame = 0;
    size = defaultHeight * 0.7;
    currentState = PenguinPlayerState.crouching;
    _eventBus.emit(GameEvents.playerCrouch);

    _playCrouchAnimation();
  }

  void _playCrouchAnimation() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (isCrouching) {
        crouchFrame = 1;
        Future.delayed(Duration(milliseconds: 100), () {
          if (isCrouching) crouchFrame = 2;
        });
      }
    });
  }

  void standUp() {
    if (!isCrouching || isSliding || isJumping) return;

    isStandingUp = true;
    _playStandUpAnimation();
  }

  void _playStandUpAnimation() {
    crouchFrame = 2;
    Future.delayed(Duration(milliseconds: 100), () {
      if (isStandingUp) {
        crouchFrame = 1;
        Future.delayed(Duration(milliseconds: 100), () {
          if (isStandingUp) _completeStandUp();
        });
      }
    });
  }

  void _completeStandUp() {
    crouchFrame = 0;
    isCrouching = false;
    isStandingUp = false;
    size = defaultHeight;
    currentState = PenguinPlayerState.idle;
    _eventBus.emit(GameEvents.playerStandUp);
  }

  // Sistema de checkpoint
  void setCheckpoint(double x, double y, double worldOffset) {
    checkpointX = x;
    checkpointY = y;
    checkpointWorldOffset = worldOffset;
    _eventBus.emit(GameEvents.checkpointSet);
  }

  void respawnAtCheckpoint() {
    x = checkpointX;
    y = checkpointY;
    isJumping = false;
    isSliding = false;
    velocidadVertical = 0;
    currentState = PenguinPlayerState.idle;
    _eventBus.emit(GameEvents.playerRespawn);
  }

  void _emitMovementEvents(double dx) {
    _eventBus.emit(GameEvents.playerUpdatePosition, {
      'x': x,
      'y': y,
      'isFacingRight': isFacingRight,
    });

    if (!isJumping) {
      _eventBus.emit(GameEvents.playerMove, {
        'direction': dx > 0 ? 'right' : 'left',
      });
    }
  }
}
