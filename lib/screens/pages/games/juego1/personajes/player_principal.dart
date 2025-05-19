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
  static const double defaultHeight = 50.0;
  
  double x;
  double y;
  double velocidadVertical = 0;
  double gravedad = AnimacionSalto.gravedad;
  double fuerzaSalto = -AnimacionSalto.fuerzaSalto;
  double size = defaultHeight;
  bool isJumping = false;
  bool isSliding = false;
  bool isFacingRight = true;
  bool isInvulnerable = false;  // Nueva propiedad añadida
  double speed = AnimacionAndar.velocidad;
  double lastMoveDirection = 0;
  bool canSlide = true;
  bool canJump = true;
  bool isCrouching = false;
  bool isStandingUp = false;
  int crouchFrame = 0;
  int slideFrame = 0;
  int frameIndex = 0; 
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
        x += dx * (isCrouching ? AnimacionAndarAgachado.velocidad : speed) * 3.0;
        isFacingRight = dx > 0;
        lastMoveDirection = dx;
        
        _eventBus.emit(GameEvents.playerUpdatePosition, {
            'x': x,
            'y': y,
            'isFacingRight': isFacingRight
        });
        
        if (currentState != PenguinPlayerState.jumping) {
            currentState = isCrouching ? PenguinPlayerState.walkingCrouched : PenguinPlayerState.walking;
            animationTime += 0.016;
            if (animationTime >= 1.0) animationTime = 0.0;
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

String getCurrentSprite() {
    if (isJumping) {
        final sprites = isCrouching ? 
          AnimacionSaltoAgachado.sprites : 
          AnimacionSalto.sprites;
        
        if (velocidadVertical > 0) { // Subiendo
            return sprites[frameIndex];
        } else { // Cayendo
            return isCrouching ? 
                AnimacionAgacharse.sprites[2] : // Vuelve a agacharse3.png
                AnimacionAndar.sprites[0];      // Vuelve a andar1.png
        }
      }
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

void slide() {
    if (canSlide && !isSliding && !isJumping) {
        isSliding = true;
        slideFrame = 0;
        final distanciaTotal = 25.0; // Aumentamos ligeramente la distancia
        final distanciaMitad = distanciaTotal / 2;
        double distanciaRecorrida = 0;
        
        currentState = PenguinPlayerState.sliding;
        _eventBus.emit(GameEvents.playerSlide);
        
        final velocidad = isCrouching ? 
            AnimacionDeslizarseAgachado.velocidad * 1.2 : // Aumentamos velocidad agachado
            AnimacionDeslizarse.velocidad * 1.1; // Aumentamos velocidad normal
        
        Timer.periodic(Duration(milliseconds: 50), (timer) {
            if (!isSliding || distanciaRecorrida >= distanciaTotal) {
                timer.cancel();
                isSliding = false;
                // Volver a la posición natural según el estado
                currentState = isCrouching ? 
                    PenguinPlayerState.crouching : 
                    PenguinPlayerState.idle;
                _eventBus.emit(GameEvents.playerEndSlide);
                return;
            }
            
            // Velocidad de movimiento ajustada según el estado
            double movimiento = velocidad * 0.05;
            x += isFacingRight ? movimiento : -movimiento;
            distanciaRecorrida += movimiento;
            
            // Actualizar frame según la distancia recorrida y el estado
            if (isCrouching) {
                // Lógica para deslizamiento agachado (3 frames)
                if (distanciaRecorrida <= distanciaMitad) {
                    slideFrame = (distanciaRecorrida / distanciaMitad * 2).floor();
                    slideFrame = slideFrame.clamp(0, 1); // Frames 1 y 2
                } else {
                    slideFrame = 2; // Mantener el frame 3 hasta el final
                }
            } else {
                // Lógica para deslizamiento normal (4 frames)
                if (distanciaRecorrida <= distanciaMitad) {
                    slideFrame = (distanciaRecorrida / distanciaMitad * 3).floor();
                    slideFrame = slideFrame.clamp(0, 2); // Frames 1, 2 y 3
                } else {
                    slideFrame = 3; // Mantener el frame 4 hasta el final
                }
            }
        });
    }
}

  void jump() {
      if (canJump && !isJumping && !isSliding) {
        isJumping = true;
        // Ajustar la velocidad vertical según si está agachado o no
        velocidadVertical = isCrouching ? 
            -AnimacionSaltoAgachado.fuerzaSalto * 1.2 : 
            -AnimacionSalto.fuerzaSalto * 1.2;
        
        // Ajustar la gravedad según el estado
        gravedad = isCrouching ? 
            AnimacionSaltoAgachado.gravedad : 
            AnimacionSalto.gravedad;
            
        currentState = PenguinPlayerState.jumping;
        _eventBus.emit(GameEvents.playerJump);
        
        frameIndex = 0;
        Timer.periodic(Duration(milliseconds: 100), (timer) {
          if (!isJumping) {
            timer.cancel();
            frameIndex = 0;
            return;
          }
          
          if (velocidadVertical < 0) {
            final sprites = isCrouching ? 
              AnimacionSaltoAgachado.sprites : 
              AnimacionSalto.sprites;
            
            frameIndex = (frameIndex + 1) % sprites.length;
            _eventBus.emit(GameEvents.playerUpdateAnimation, {
              'frameIndex': frameIndex,
              'state': 'jumping'
            });
          }
        });
      }
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
  
  // Añadir variables para el checkpoint
  double checkpointX = 0;
  double checkpointY = 0;
  double checkpointWorldOffset = 0;
  
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
  
  // Variables para monedas y efectos
  int monedas = 0;
  double velocidadTemp = AnimacionAndar.velocidad;
  double fuerzaSaltoTemp = -AnimacionSalto.fuerzaSalto;
}