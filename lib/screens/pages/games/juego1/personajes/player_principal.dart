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
  double gravedad = 800;
  double fuerzaSalto = -400;
  double size = defaultHeight;
  bool isJumping = false;
  bool isSliding = false;
  bool isFacingRight = true;
  double speed = 5.0;
  double lastMoveDirection = 0;
  
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
    if (!isJumping && !isSliding) {
      isJumping = true;
      velocidadVertical = fuerzaSalto;
      currentState = PenguinPlayerState.jumping;
      _eventBus.emit(GameEvents.playerJump);
    }
  }
  
  void slide() {
    if (!isSliding && !isJumping) {
      isSliding = true;
      currentState = PenguinPlayerState.sliding;
      _eventBus.emit(GameEvents.playerSlide);
      
      Future.delayed(const Duration(milliseconds: 1000), () {
        isSliding = false;
        currentState = lastMoveDirection != 0 ? 
          PenguinPlayerState.walking : PenguinPlayerState.idle;
        _eventBus.emit(GameEvents.playerEndSlide);
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
        'velocityY': velocidadVertical
      });
    }
  }
  
  void handleCollision(String collisionType) {
    _eventBus.emit(GameEvents.playerCollision, {'type': collisionType});
  }
  
  String getCurrentSprite() {
    switch (currentState) {
      case PenguinPlayerState.idle:
        return 'assets/personajes/principal/idle/idle1.png';
      case PenguinPlayerState.walking:
        int frame = (animationTime * 10).floor() % 3 + 1;
        return 'assets/personajes/principal/andar/andar$frame.png';
      case PenguinPlayerState.jumping:
        int frame = velocidadVertical <= 0 ? 1 : 
                   velocidadVertical < 200 ? 2 : 3;
        return 'assets/personajes/principal/saltar/saltar$frame.png';
      case PenguinPlayerState.sliding:
        return 'assets/personajes/principal/deslizar/deslizar1.png';
    }
  }
}