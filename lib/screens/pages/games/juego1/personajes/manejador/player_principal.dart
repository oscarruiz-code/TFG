import 'package:oscarruizcode_pingu/dependencias/imports.dart';

/// Enumeración de los posibles estados del jugador pingüino.
enum PenguinPlayerState {
  idle,
  walking,
  jumping,
  sliding,
  crouching,
  walkingCrouched,
}

/// Clase principal que integra todos los módulos del jugador y coordina su funcionamiento.
///
/// Actúa como fachada para los módulos especializados (movimiento, colisión, animación,
/// power-ups y checkpoints), delegando las funcionalidades específicas y manteniendo
/// la sincronización entre ellos mediante eventos.
class Player {
  // Constantes
  static const double defaultHeight = 50.0;
  static const double frameTime = 0.1;

  // Estado de disposición
  bool isDisposed = false;

  // Propiedades de posición y dimensiones
  double x;
  double y;
  double size = defaultHeight;

  // Agregar getters para width y height
  double get width => size;
  double get height => size;

  // Propiedades de movimiento
  double velocidadVertical = 0;
  double velocidadHorizontal = 0;
  double gravedad = AnimacionSalto.gravedad;
  double fuerzaSalto = -AnimacionSalto.fuerzaSalto;
  double fuerzaSaltoTemp = 0; // Fuerza de salto temporal para power-ups
  final double velocidadBase = AnimacionAndar.velocidad * 0.6;
  final double velocidadBaseAgachado = AnimacionAndarAgachado.velocidad * 0.6;
  double velocidadTemp = 0;
  double lastMoveDirection = 0;
  bool isFacingRight;
  double speed = 0;

  // Estados del jugador
  bool isJumping = false;
  bool isSliding = false;
  bool isCrouching = false;
  bool isStandingUp = false;
  bool isInvulnerable = false;
  bool canSlide = true;
  bool canJump = true;
  bool isOnGround = false;

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
  num monedas = 0;

  // Bus de eventos
  final GameEventBus _eventBus = GameEventBus();
  
  // Módulos
  late PlayerAnimation _animation;
  late PlayerMovement _movement;
  late PlayerCollision _collision;
  late PlayerPowerUp _powerUp;
  late PlayerCheckpoint _checkpoint;
  
  // Getters para acceder a los módulos desde fuera
  PlayerPowerUp get powerUp => _powerUp;

  // En el constructor de Player, añade este listener
  Player({
    required this.x,
    required this.y,
    required this.size,
    required this.isFacingRight,
  }) {
    // Inicializar los módulos
    _animation = PlayerAnimation(isFacingRight: isFacingRight);
    _movement = PlayerMovement(x: x, y: y, size: size, isFacingRight: isFacingRight);
    _collision = PlayerCollision(
      x: x, 
      y: y, 
      size: size, 
      isSliding: isSliding, 
      isJumping: isJumping, 
      isCrouching: isCrouching, 
      lastMoveDirection: lastMoveDirection
    );
    _powerUp = PlayerPowerUp(velocidadBase: velocidadBase, fuerzaSalto: fuerzaSalto);
    _checkpoint = PlayerCheckpoint();
    
    // Inicializar los listeners para eventos de colisión
    initializeCollisionListeners();
    
    // Suscribirse a eventos de los módulos
    _eventBus.on(GameEvents.playerStateChange, (data) {
      currentState = data['state'];
    });
    
    // Añadir listener para actualizar la posición durante el deslizamiento
    _eventBus.on(GameEvents.playerSlideProgress, (data) {
      if (data.containsKey('x')) {
        x = data['x'];
      }
      
      // Actualizar el frame de deslizamiento
      if (data.containsKey('distanciaRecorrida') && data.containsKey('distanciaMitad')) {
        updateSlideFrame(
          data['distanciaRecorrida'] as double,
          data['distanciaMitad'] as double
        );
      }
    });
    
    // Añadir listener para el fin del deslizamiento
    _eventBus.on(GameEvents.playerEndSlide, (data) {
      // Reiniciar el slideFrame
      slideFrame = 0;
      isSliding = false;
      
      // Reiniciar la animación de caminar
      resetWalkingAnimation();
      
      // Actualizar el estado actual
      currentState = isCrouching ? PenguinPlayerState.crouching : PenguinPlayerState.idle;
      
      // Actualizar los valores en el módulo de animación
      _animation.isSliding = false;
      _animation.slideFrame = 0;
      _animation.currentState = currentState;
    });
  }

  void initializeCollisionListeners() {
    _collision.initializeCollisionListeners(this);
  }

  void disposeCollisionListeners() {
    _collision.disposeCollisionListeners();
  }

  // Método para liberar recursos
  void dispose() {
    isDisposed = true;
    _powerUp.isDisposed = true;
    disposeCollisionListeners();
  }

  // Hitbox del jugador
  Rect get hitbox {
    // Actualizar los valores en el módulo de colisión
    _collision.x = x;
    _collision.y = y;
    _collision.size = size;
    _collision.isSliding = isSliding;
    _collision.isJumping = isJumping;
    _collision.isCrouching = isCrouching;
    _collision.lastMoveDirection = lastMoveDirection;
    
    return _collision.hitbox;
  }

  // Movimiento básico
  void move(double dx, double dy, {required double groundLevel}) {
    // Actualizar los valores en el módulo de movimiento
    _movement.x = x;
    _movement.y = y;
    _movement.size = size;
    _movement.isSliding = isSliding;
    _movement.isJumping = isJumping;
    _movement.isCrouching = isCrouching;
    _movement.lastMoveDirection = lastMoveDirection;
    _movement.velocidadTemp = _powerUp.velocidadTemp;
    
    _movement.move(dx, dy, groundLevel: groundLevel);
    
    // Actualizar los valores desde el módulo
    x = _movement.x;
    y = _movement.y;
    isJumping = _movement.isJumping;
    isSliding = _movement.isSliding;
    isCrouching = _movement.isCrouching;
    lastMoveDirection = _movement.lastMoveDirection;
    speed = _movement.speed;
    
    // Actualizar la dirección en el módulo de animación
    if (dx != 0) {
      isFacingRight = dx > 0;
      _animation.isFacingRight = isFacingRight;
    }
  }

  void updateWalkingAnimation(double dtSeconds) {
    // Actualizar los valores en el módulo de animación
    _animation.isJumping = isJumping;
    _animation.isSliding = isSliding;
    _animation.isCrouching = isCrouching;
    _animation.lastMoveDirection = lastMoveDirection;
    
    _animation.updateWalkingAnimation(dtSeconds);
    
    // Actualizar los valores desde el módulo
    frameIndex = _animation.frameIndex;
    animationTime = _animation.animationTime;
  }

  // Cuando recojas una moneda de velocidad, haz esto:
  void activarPowerUpVelocidad(double nuevaVelocidad, Duration duracion) {
    _powerUp.activarPowerUpVelocidad(nuevaVelocidad, duracion);
    velocidadTemp = _powerUp.velocidadTemp;
  }

  void activarPowerUpSalto(double nuevaFuerza, Duration duracion) {
    _powerUp.activarPowerUpSalto(nuevaFuerza, duracion);
    fuerzaSaltoTemp = _powerUp.fuerzaSaltoTemp;
  }

  // Obtener sprite actual
  String getCurrentSprite() {
    // Actualizar los valores en el módulo de animación
    _animation.isJumping = isJumping;
    _animation.isSliding = isSliding;
    _animation.isCrouching = isCrouching;
    _animation.isStandingUp = isStandingUp;
    _animation.velocidadVertical = velocidadVertical;
    _animation.slideFrame = slideFrame;
    _animation.crouchFrame = crouchFrame;
    _animation.frameIndex = frameIndex;
    
    return _animation.getCurrentSprite();
  }

  void resetWalkingAnimation() {
    // Actualizar los valores en el módulo de animación
    _animation.isJumping = isJumping;
    _animation.isSliding = isSliding;
    _animation.isCrouching = isCrouching;
    
    _animation.resetWalkingAnimation();
    
    // Actualizar los valores desde el módulo
    animationTime = _animation.animationTime;
    frameIndex = _animation.frameIndex;
    currentState = _animation.currentState;
  }

  // Acciones del jugador
  void slide() {
    // Actualizar los valores en el módulo de movimiento
    _movement.canSlide = canSlide;
    _movement.isSliding = isSliding;
    _movement.isJumping = isJumping;
    _movement.isCrouching = isCrouching;
    
    _movement.slide();
    
    // Actualizar los valores desde el módulo
    isSliding = _movement.isSliding;
    slideFrame = 0;
  }

  void updateSlideFrame(double distanciaRecorrida, double distanciaMitad) {
    _animation.updateSlideFrame(distanciaRecorrida, distanciaMitad);
    slideFrame = _animation.slideFrame;  
  }

  // Método para iniciar el salto
  void jump() {
    // Actualizar los valores en el módulo de movimiento
    _movement.canJump = canJump;
    _movement.isSliding = isSliding;
    _movement.fuerzaSaltoTemp = fuerzaSaltoTemp;
    
    _movement.jump();
    
    // Actualizar los valores desde el módulo
    isJumping = _movement.isJumping;
    isOnGround = _movement.isOnGround;
    velocidadVertical = _movement.velocidadVertical;
  }

  void crouch() {
    if (isCrouching) {
      standUp();
      return;
    }
    
    // Actualizar los valores en el módulo de movimiento
    _movement.isSliding = isSliding;
    _movement.isJumping = isJumping;

    
    _movement.crouch();
    
    // Actualizar los valores desde el módulo
    isCrouching = _movement.isCrouching;
    size = _movement.size;
    y = _movement.y;
    
    // Actualizar también el módulo de animación
    _animation.isCrouching = isCrouching;
    
    // Iniciar la animación de agacharse
    crouchFrame = 0;
    isStandingUp = false;
    _animation.playCrouchAnimation();
  }

  void standUp() {
    if (!isCrouching || isSliding || isJumping) return;

    // Actualizar el estado en el módulo de animación
    _animation.isCrouching = isCrouching;
    _animation.isStandingUp = true;
    
    isStandingUp = true;
    _animation.playStandUpAnimation();
    
    // Programar la llamada a completeStandUp después de la animación
    Future.delayed(Duration(milliseconds: 250), () {
      if (isStandingUp) {
        completeStandUp();
      }
    });
  }

  void completeStandUp() {
    _movement.completeStandUp(defaultHeight);
    
    // Actualizar los valores desde el módulo
    size = _movement.size;
    y = _movement.y;
    isCrouching = _movement.isCrouching;
    
    // Actualizar también el módulo de animación antes de llamar a completeStandUp
    _animation.isCrouching = isCrouching;
    _animation.isStandingUp = isStandingUp;
    
    _animation.completeStandUp();
    isStandingUp = false;
    currentState = _animation.currentState;
    _eventBus.emit(GameEvents.playerStandUp);
  }

  // Sistema de checkpoint
  void setCheckpoint(double x, double y, double worldOffset) {
    _checkpoint.setCheckpoint(x, y, worldOffset);
    checkpointX = _checkpoint.checkpointX;
    checkpointY = _checkpoint.checkpointY;
    checkpointWorldOffset = _checkpoint.checkpointWorldOffset;
  }

  void respawnAtCheckpoint() {
    _checkpoint.respawnAtCheckpoint(this);
  }

  void morir() {
    _checkpoint.morir(this);
  }

  // Ajuste de posición vertical considerando múltiples suelos
  void updateGravityAndPosition({
    required List<dynamic> objetos,
    required double deltaTime,
    required double worldOffset,
    required ColisionSuelo detectorSuelo,
  }) {
    // Actualizar los valores en el módulo de movimiento
    _movement.x = x;
    _movement.y = y;
    _movement.velocidadVertical = velocidadVertical;
    
    // Aplica gravedad
    velocidadVertical += gravedad * deltaTime;
    y += velocidadVertical;

    // Altura del suelo más cercano
    final alturaSuelo = detectorSuelo.obtenerAltura(this, objetos, worldOffset);

    if (alturaSuelo != double.infinity) {
      // Usar el hitbox.bottom para obtener la posición correcta de los pies
      final double playerFeet = hitbox.bottom;

      if (velocidadVertical >= 0 && playerFeet >= alturaSuelo - 10) {
        // Aterriza sobre el suelo
        y = alturaSuelo - size * 0.5;
        velocidadVertical = 0;
        isJumping = false;
        canJump = true;
        isOnGround = true;
      }
    } else {
      isOnGround = false;
    }
  }
}