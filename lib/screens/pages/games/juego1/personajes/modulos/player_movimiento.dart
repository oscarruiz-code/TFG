import 'package:oscarruizcode_pingu/dependencias/imports.dart';
import 'dart:developer' as developer;

/// Controla el movimiento del personaje jugador, incluyendo desplazamiento horizontal,
/// saltos, agacharse y deslizamientos.
///
/// Gestiona la física del movimiento, la detección de colisiones con el suelo,
/// y emite eventos para sincronizar el estado del jugador con otros componentes.
class PlayerMovement {
  // Propiedades de movimiento
  double x;
  double y;
  double size;
  double velocidadVertical = 0;
  double velocidadHorizontal = 0;
  double gravedad = AnimacionSalto.gravedad;
  double fuerzaSalto = -AnimacionSalto.fuerzaSalto;
  double fuerzaSaltoTemp = 0;
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
  bool isOnGround = false;
  bool canJump = true;
  bool canSlide = true;
  
  // Bus de eventos
  final GameEventBus _eventBus = GameEventBus();
  
  PlayerMovement({
    required this.x,
    required this.y,
    required this.size,
    required this.isFacingRight,
  });
  
  // Movimiento básico
  void move(double dx, double dy, {required double groundLevel}) {
    if (isSliding) return;

    if (dx != 0) {
      _handleMovement(dx, groundLevel);
    } else {
      _handleIdle();
    }
    developer.log('Player moved to: x=$x, y=$y, dx=$dx, dy=$dy');
  }

  void _handleMovement(double dx, double groundLevel) {
    double baseSpeed = isCrouching ? velocidadBaseAgachado : velocidadBase;
    double currentSpeed = velocidadTemp > 0 ? velocidadTemp : baseSpeed;

    speed = currentSpeed;
    isFacingRight = dx > 0;
    lastMoveDirection = dx;

    if (!isSliding) {
      // No cambiar el estado si estamos saltando
      if (!isJumping) {
        _eventBus.emit(GameEvents.playerStateChange, {
          'state': isCrouching
              ? PenguinPlayerState.walkingCrouched
              : PenguinPlayerState.walking
        });
      }

      double newX = x + dx * currentSpeed;
      x = newX;
    }

    _adjustGroundPosition(groundLevel);
    _updateMovementState();
    _emitMovementEvents(dx);
  }

  void _handleIdle() {
    lastMoveDirection = 0;
    // No cambiar el estado si estamos saltando
    if (!isJumping && !isSliding) {
      _eventBus.emit(GameEvents.playerStateChange, {
        'state': isCrouching ? PenguinPlayerState.crouching : PenguinPlayerState.idle
      });
      _eventBus.emit(GameEvents.playerIdle);
    }
  }

  void _updateMovementState() {
    // No actualizar el estado si estamos saltando
    if (!isJumping) {
      _eventBus.emit(GameEvents.playerStateChange, {
        'state': isCrouching
            ? PenguinPlayerState.walkingCrouched
            : PenguinPlayerState.walking
      });
    }
  }
  
  void _adjustGroundPosition(double groundLevel) {
    if (groundLevel == double.infinity) {
      // Si no hay suelo, no hacer ajuste
      return;
    }

    // Ajustar posición solo si estamos cerca del suelo
    if (y + size * 0.5 >= groundLevel - 10 &&
        y + size * 0.5 <= groundLevel + 15) {
      y = groundLevel - size * 0.5;
      isJumping = false;
      velocidadVertical = 0;
    }
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
  
  // Ajuste de posición vertical considerando múltiples suelos
  void updateGravityAndPosition({
    required List<dynamic> objetos,
    required double deltaTime,
    required double worldOffset,
    required ColisionSuelo detectorSuelo,
    required Player player,
  }) {
    // Aplica gravedad
    velocidadVertical += gravedad * deltaTime;
    y += velocidadVertical;
  
    // Altura del suelo más cercano
    final alturaSuelo = detectorSuelo.obtenerAltura(player, objetos, worldOffset);

    if (alturaSuelo != double.infinity) {
      // Usar el hitbox.bottom para obtener la posición correcta de los pies
      final double playerFeet = y + size * 0.5;

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
  
  // Método para iniciar el salto
  void jump() {
    if (!canJump || isSliding) return;

    isJumping = true;
    isOnGround = false;

    // Calcular la fuerza de salto basada en el estado actual
    double fuerzaActual;
    if (isCrouching) {
      fuerzaActual = fuerzaSaltoTemp < 0 ? fuerzaSaltoTemp : -AnimacionSaltoAgachado.fuerzaSalto;
    } else {
      fuerzaActual = fuerzaSaltoTemp < 0 ? fuerzaSaltoTemp : -AnimacionSalto.fuerzaSalto;
    }
    
    // Aplicar la fuerza de salto con un pequeño impulso adicional para garantizar que el salto ocurra
    velocidadVertical = fuerzaActual * 1.05;
    
    _eventBus.emit(GameEvents.playerStateChange, {'state': PenguinPlayerState.jumping});
    _eventBus.emit(GameEvents.playerJump);
  }
  
  void slide() {
    if (!canSlide || isSliding || isJumping) return;

    isSliding = true;
    _performSlide();
  }

  void _performSlide() {
    final distanciaTotal = isCrouching ? 
        AnimacionDeslizarseAgachado.distancia : 
        AnimacionDeslizarse.distancia;
    final distanciaMitad = distanciaTotal / 2;
    double distanciaRecorrida = 0;
  
    _eventBus.emit(GameEvents.playerStateChange, {'state': PenguinPlayerState.sliding});
    _eventBus.emit(GameEvents.playerSlide);

    Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (!isSliding || distanciaRecorrida >= distanciaTotal) {
        _endSlide(timer);
        return;
      }
  
      // Calcular el incremento de distancia basado en la velocidad de la animación
      double incremento = distanciaTotal * 0.1;
      distanciaRecorrida += incremento;
      
      // Actualizar la posición X del jugador basado en la dirección
      double direccion = isFacingRight ? 1.0 : -1.0;
      x += incremento * direccion;
      
      // Emitir evento con la información de progreso
      _eventBus.emit(GameEvents.playerSlideProgress, {
        'direccion': direccion,
        'incremento': incremento,
        'distanciaRecorrida': distanciaRecorrida,
        'distanciaMitad': distanciaMitad,
        'x': x  // Añadir la posición X actualizada
      });
    });
  }
  
  void _endSlide(Timer timer) {
    timer.cancel();
    isSliding = false;
    
    // Asegurarse de que el estado se actualice correctamente
    _eventBus.emit(GameEvents.playerStateChange, {
      'state': isCrouching ? PenguinPlayerState.crouching : PenguinPlayerState.idle
    });
    
    // Emitir evento de fin de deslizamiento
    _eventBus.emit(GameEvents.playerEndSlide, {
      'resetAnimation': true  
    });
    
    // Aumentar el retraso para asegurar que la transición de estados sea correcta
    Future.delayed(Duration(milliseconds: 100), () {
      // Verificar que el jugador ya no esté deslizándose
      if (!isSliding) {
        // Reforzar el estado correcto
        _eventBus.emit(GameEvents.playerStateChange, {
          'state': isCrouching ? PenguinPlayerState.crouching : PenguinPlayerState.idle
        });
      }
    });
  }
  
  void crouch() {
    if (isCrouching || isSliding || isJumping) return;

    isCrouching = true;
    _initializeCrouch();
  }

  void _initializeCrouch() {
    double previousHeight = size;
    size = size * 0.7;
    // Ajustar la posición Y para mantener los pies en el mismo lugar
    y += (previousHeight - size) * 0.5;
    _eventBus.emit(GameEvents.playerStateChange, {'state': PenguinPlayerState.crouching});
    _eventBus.emit(GameEvents.playerCrouch);
  }
  
  void standUp() {
    if (!isCrouching || isSliding || isJumping) return;
    
    _eventBus.emit(GameEvents.playerStandUp);
  }
  
  void completeStandUp(double defaultHeight) {
    double previousHeight = size;
    size = defaultHeight;
    // Ajustar la posición Y al pararse
    y -= (size - previousHeight) * 0.5;
    isCrouching = false;
  }
}