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
      y += velocidadVertical * dt;
      
      // Limitar la velocidad de caída
      if (velocidadVertical > 600) {
        velocidadVertical = 600;
      }
      
      if (y < 0) y = 0;
      
      
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
    }
  }
  
  String getCurrentSprite() {
    switch (currentState) {
      case PenguinPlayerState.idle:
        return AnimacionAndar.sprites[0];
      case PenguinPlayerState.walking:
        int frame = (animationTime ~/ AnimacionAndar.frameTime) % AnimacionAndar.sprites.length;
        return AnimacionAndar.sprites[frame];
      case PenguinPlayerState.jumping:
        int frame;
        if (velocidadVertical <= 0) {
          frame = 0;
        } else if (velocidadVertical < 200) {
          frame = 1; 
        } else {
          frame = 2; 
        }
        return AnimacionSalto.sprites[frame];
      case PenguinPlayerState.sliding:
        int frame = (animationTime ~/ AnimacionDeslizarse.frameTime) % AnimacionDeslizarse.sprites.length;
        return AnimacionDeslizarse.sprites[frame];
    }
  }
}