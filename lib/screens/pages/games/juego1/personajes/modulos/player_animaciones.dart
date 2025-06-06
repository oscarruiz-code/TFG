import 'package:oscarruizcode_pingu/dependencias/imports.dart';

/// Controla las animaciones del personaje jugador según su estado actual.
///
/// Gestiona los sprites a mostrar basándose en el estado del jugador (caminando,
/// saltando, agachado, deslizándose) y la dirección en la que mira.
class PlayerAnimation {
  // Propiedades de animación
  int crouchFrame = 0;
  int slideFrame = 0;
  int frameIndex = 0;
  double animationTime = 0;
  PenguinPlayerState currentState = PenguinPlayerState.idle;
  bool isFacingRight;
  bool isJumping = false;
  bool isSliding = false;
  bool isCrouching = false;
  bool isStandingUp = false;
  double velocidadVertical = 0;
  double lastMoveDirection = 0;
  
  PlayerAnimation({required this.isFacingRight});
  
  void updateWalkingAnimation(double dtSeconds) {
    // No actualizar la animación si estamos saltando
    if (isJumping) return;

    if (!isSliding && lastMoveDirection != 0) {
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
    if (velocidadVertical < 0) return sprites[0];
    if (velocidadVertical > 0) {
      return isCrouching ? sprites[1] : sprites[2];
    }
    return isCrouching ? sprites[0] : sprites[1];
  }

  String _getSlidingSprite() {
    if (isCrouching) {
      // Verificar que slideFrame esté dentro del rango válido
      int frameIndex = slideFrame.clamp(0, AnimacionDeslizarseAgachado.sprites.length - 1);
      return AnimacionDeslizarseAgachado.sprites[frameIndex];
    } else {
      // Verificar que slideFrame esté dentro del rango válido
      int frameIndex = slideFrame.clamp(0, AnimacionDeslizarse.sprites.length - 1);
      return AnimacionDeslizarse.sprites[frameIndex];
    }
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
      slideFrame = 0; 
      currentState =
          isCrouching ? PenguinPlayerState.crouching : PenguinPlayerState.idle;
    }
  }
  
  void updateSlideFrame(double distanciaRecorrida, double distanciaMitad) {
    if (isCrouching) {
      _updateCrouchingSlideFrame(distanciaRecorrida, distanciaMitad);
    } else {
      _updateNormalSlideFrame(distanciaRecorrida, distanciaMitad);
    }
  }

  void _updateCrouchingSlideFrame(
    double distanciaRecorrida,
    double distanciaMitad,
  ) {
    if (distanciaRecorrida < distanciaMitad * 0.5) {
      slideFrame = 1; 
    } else if (distanciaRecorrida < distanciaMitad) {
      slideFrame = 2; 
    } else {
      slideFrame = 3;
    }
  }

  void _updateNormalSlideFrame(
    double distanciaRecorrida,
    double distanciaMitad,
  ) {
    if (distanciaRecorrida < distanciaMitad * 0.3) {
      slideFrame = 0; 
    } else if (distanciaRecorrida < distanciaMitad * 0.6) {
      slideFrame = 1; 
    } else if (distanciaRecorrida < distanciaMitad) {
      slideFrame = 2;
    } else {
      slideFrame = 3;
    }
  }
  
  void playCrouchAnimation() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (isCrouching) {
        crouchFrame = 1;
        Future.delayed(Duration(milliseconds: 100), () {
          if (isCrouching) crouchFrame = 2;  
        });
      }
    });
  }
  
  void playStandUpAnimation() {
    crouchFrame = 2;
    Future.delayed(Duration(milliseconds: 100), () {
      if (isStandingUp) {
        crouchFrame = 1;
        Future.delayed(Duration(milliseconds: 100), () {
          if (isStandingUp) {
            crouchFrame = 0;  
            isCrouching = false;
            isStandingUp = false;
            currentState = PenguinPlayerState.idle;
          }
        });
      }
    });
  }

  // Modificar o eliminar este método ya que su funcionalidad se ha movido a playStandUpAnimation
  void completeStandUp() {
  // Este método ahora solo debería actualizar el estado si es necesario
  if (isStandingUp) {
    crouchFrame = 0;
    isCrouching = false;
    isStandingUp = false;
    currentState = PenguinPlayerState.idle;
  }
  }
}