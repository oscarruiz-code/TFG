import '../../../../../dependencias/imports.dart';

enum PenguinPlayerState {
  idle,
  walking,
  jumping,
  sliding
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
  
  void move(double dx, double dy, {required double groundLevel}) {
    if (isSliding) return;
    
    if (dx != 0) {
      x += dx * speed;
      isFacingRight = dx > 0;
      lastMoveDirection = dx;
      if (currentState != PenguinPlayerState.jumping) {
        currentState = PenguinPlayerState.walking;
        _eventBus.emit(GameEvents.playerMove, {'direction': dx > 0 ? 'right' : 'left'});
      }
    } else {
      lastMoveDirection = 0;
      if (currentState != PenguinPlayerState.jumping && !isSliding) {
        currentState = PenguinPlayerState.idle;
        _eventBus.emit(GameEvents.playerIdle);
      }
    }
  }
  
  void jump() {
    if (!isJumping && !isSliding && canJump) {
      isJumping = true;
      canJump = false;
      velocidadVertical = fuerzaSalto;
      currentState = PenguinPlayerState.jumping;
      _eventBus.emit(GameEvents.playerJump);
    
      if (lastMoveDirection != 0) {
        x += lastMoveDirection * speed * 0.8;
      }
    }
  }
  
  void slide() {
    if (!isSliding && !isJumping && canSlide) {
      isSliding = true;
      canSlide = false;
      currentState = PenguinPlayerState.sliding;
      _eventBus.emit(GameEvents.playerSlide);
      
      double slideDirection = lastMoveDirection != 0 ? lastMoveDirection : (isFacingRight ? 1 : -1);
      double slideDistance = AnimacionDeslizarse.distancia * slideDirection;
      
      x += slideDistance;
      
      Future.delayed(const Duration(milliseconds: 800), () {
        isSliding = false;
        currentState = lastMoveDirection != 0 ? 
          PenguinPlayerState.walking : PenguinPlayerState.idle;
        _eventBus.emit(GameEvents.playerEndSlide);
        
        Future.delayed(const Duration(milliseconds: 400), () {
          canSlide = true;
        });
      });
    }
  }
  
  void updateAnimation(double dt) {
    animationTime += dt;
    if (isJumping) {
      velocidadVertical += gravedad * dt;
      velocidadVertical = velocidadVertical.clamp(-800.0, 800.0);
      y += velocidadVertical * dt;
      
      if (y < 0) {
        y = 0;
        velocidadVertical = 0;
      }
      
      if (lastMoveDirection != 0) {
        x += lastMoveDirection * speed * 0.7;
      }
      
      _eventBus.emit(GameEvents.playerUpdatePosition, {
        'x': x,
        'y': y,
        'velocityY': velocidadVertical
      });
    }
  }
  
  void handleCollision(String collisionType) {
    _eventBus.emit(GameEvents.playerCollision, {'type': collisionType});
    
    if (collisionType == 'ground') {
      isJumping = false;
      canJump = true;
      velocidadVertical = 0;
      
      // Restaurar estado después de aterrizar
      if (currentState == PenguinPlayerState.jumping) {
        currentState = lastMoveDirection != 0 ? 
          PenguinPlayerState.walking : PenguinPlayerState.idle;
      }
    }
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
    }
  }

}