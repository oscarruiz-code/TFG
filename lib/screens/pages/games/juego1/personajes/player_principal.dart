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
  static const double defaultHeight = 50.0; // Reducido de 60.0 a 45.0
  
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
  bool isCrouching = false;
  bool isStandingUp = false;
  int crouchFrame = 0;
  int slideFrame = 0;
  double slideDistance = 0;
  
  PenguinPlayerState currentState = PenguinPlayerState.idle;
  double animationTime = 0;
  final GameEventBus _eventBus = GameEventBus();
  
  Player({
    required this.x,
    required this.y,
  });
  
  Rect get hitbox => Rect.fromLTWH(
    x - (size * 0.46),
    y - (size * (isCrouching ? 0.25 : 0.45)), // Ajustado para cuando está agachado
    size * 0.85,
    size * (isSliding ? 0.4 : (isCrouching ? 0.5 : 0.94)), // Ajustado altura cuando está agachado
  );
  
  void move(double dx, double dy, {required double groundLevel}) {
    if (isSliding) return;
    
    if (dx != 0) {
      x += dx * (isCrouching ? AnimacionAndarAgachado.velocidad : speed) * 1.5; // Multiplicador añadido para movimiento más fluido
      isFacingRight = dx > 0;
      lastMoveDirection = dx;
      
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

  void slide() {
    if (canSlide && !isSliding && !isJumping) {
      isSliding = true;
      slideFrame = 0;
      slideDistance = 0;
      currentState = PenguinPlayerState.sliding;
      _eventBus.emit(GameEvents.playerSlide);
      
      // Primera fase del deslizamiento (frames 1-3)
      Future.delayed(Duration(milliseconds: 100), () {
        slideFrame = 1;
        x += isFacingRight ? 10 : -10;
        Future.delayed(Duration(milliseconds: 100), () {
          slideFrame = 2;
          x += isFacingRight ? 15 : -15;
          Future.delayed(Duration(milliseconds: 100), () {
            slideFrame = 3;
            x += isFacingRight ? 20 : -20;
            
            // Segunda fase del deslizamiento (frame 4)
            Future.delayed(Duration(milliseconds: 300), () {
              slideFrame = 4;
              x += isFacingRight ? 40 : -40;
              
              // Finalizar deslizamiento
              Future.delayed(Duration(milliseconds: 200), () {
                isSliding = false;
                slideFrame = 0;
                currentState = PenguinPlayerState.idle;
                _eventBus.emit(GameEvents.playerEndSlide);
              });
            });
          });
        });
      });
    }
  }

  void jump() {
    if (canJump && !isJumping && !isSliding) {
      isJumping = true;
      velocidadVertical = fuerzaSalto;
      currentState = PenguinPlayerState.jumping;
      _eventBus.emit(GameEvents.playerJump);
    }
  }

  void updateAnimation(double dt) {
    if (isJumping) {
      velocidadVertical += gravedad * dt;
      y += velocidadVertical * dt;
    }
    animationTime += dt;
  }

  String getCurrentSprite() {
    if (isSliding) {
      return AnimacionDeslizarse.sprites[slideFrame];
    }
    
    if (isCrouching || isStandingUp) {
      if (isJumping) {
        return AnimacionSaltoAgachado.sprites[0];
      } else if (isSliding) {
        return AnimacionDeslizarseAgachado.sprites[0];
      } else if (lastMoveDirection != 0) {
        return AnimacionAndarAgachado.sprites[(animationTime / AnimacionAndarAgachado.frameTime).floor() % AnimacionAndarAgachado.sprites.length];
      } else {
        // Animación de agacharse/levantarse
        return AnimacionAgacharse.sprites[crouchFrame];
      }
    }
    
    // Animaciones normales
    if (isJumping) {
      return AnimacionSalto.sprites[0];
    } else if (isSliding) {
      return AnimacionDeslizarse.sprites[0];
    } else if (lastMoveDirection != 0) {
      return AnimacionAndar.sprites[(animationTime / AnimacionAndar.frameTime).floor() % AnimacionAndar.sprites.length];
    }
    
    return AnimacionAndar.sprites[0];
  }

  void crouch() {
    if (!isCrouching && !isSliding && !isJumping) {
      isCrouching = true;
      isStandingUp = false;
      crouchFrame = 0;
      size = defaultHeight * 0.7; // Reducir el tamaño al agacharse
      currentState = PenguinPlayerState.crouching;
      _eventBus.emit(GameEvents.playerCrouch);
      
      // Animación de agacharse
      Future.delayed(Duration(milliseconds: 100), () {
        if (isCrouching) crouchFrame = 1;
        Future.delayed(Duration(milliseconds: 100), () {
          if (isCrouching) crouchFrame = 2;
        });
      });
    }
  }

  void standUp() {
    if (isCrouching && !isSliding && !isJumping) {
      isStandingUp = true;
      crouchFrame = 2;
      
      // Animación de levantarse (inversa a agacharse)
      Future.delayed(Duration(milliseconds: 100), () {
        if (isStandingUp) crouchFrame = 1;
        Future.delayed(Duration(milliseconds: 100), () {
          if (isStandingUp) {
            crouchFrame = 0;
            isCrouching = false;
            isStandingUp = false;
            size = defaultHeight;
            currentState = PenguinPlayerState.idle;
            _eventBus.emit(GameEvents.playerStandUp);
          }
        });
      });
    }
  }
}