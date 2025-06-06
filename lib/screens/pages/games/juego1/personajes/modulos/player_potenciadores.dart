import 'package:oscarruizcode_pingu/dependencias/imports.dart';

/// Gestiona los power-ups temporales del jugador, como velocidad y salto mejorados.
///
/// Esta clase controla la activación, duración y desactivación de los power-ups,
/// utilizando temporizadores para revertir los efectos después de un tiempo determinado.
class PlayerPowerUp {
  double velocidadBase;
  double fuerzaSalto;
  double velocidadTemp = 0;
  double fuerzaSaltoTemp = 0;
  bool isDisposed = false;
  
  // Temporizadores para controlar la duración de los power-ups
  Timer? _velocidadTimer;
  Timer? _saltoTimer;
  
  PlayerPowerUp({
    required this.velocidadBase,
    required this.fuerzaSalto,
  });
  
  // Método específico para la moneda de velocidad
  void activarMonedaVelocidad() {
    // Calcular el factor de velocidad para la moneda de velocidad
    double factorVelocidad = AnimacionAndar.velocidad * 1.5;
    
    // Activar el power-up con la duración específica para monedas de velocidad
    activarPowerUpVelocidad(
      factorVelocidad,
      const Duration(milliseconds: 3000)
    );
  }
  
  // Método específico para la moneda de salto
  void activarMonedaSalto(bool isCrouching) {
    // Calcular la fuerza de salto base según el estado
    double fuerzaSaltoBase = isCrouching 
        ? -AnimacionSaltoAgachado.fuerzaSalto
        : -AnimacionSalto.fuerzaSalto;
    
    // Aplicar el factor correspondiente según el estado
    double nuevaFuerza = isCrouching ? fuerzaSaltoBase : fuerzaSaltoBase * 1.5;
    
    // Activar el power-up con la duración específica para monedas de salto
    activarPowerUpSalto(
      nuevaFuerza,
      const Duration(milliseconds: 5000)
    );
  }
  
  void activarPowerUpVelocidad(double nuevaVelocidad, Duration duracion) {
    // Cancelar el temporizador anterior si existe
    _velocidadTimer?.cancel();
    
    // Aplicar el nuevo valor de velocidad
    velocidadTemp = nuevaVelocidad;
    
    // Crear un nuevo temporizador
    _velocidadTimer = Timer(duracion, () {
      if (!isDisposed) {
        velocidadTemp = 0; // Volver a 0 para que use velocidadBase
      }
    });
  }

  void activarPowerUpSalto(double nuevaFuerza, Duration duracion) {
    // Cancelar el temporizador anterior si existe
    _saltoTimer?.cancel();
    
    // Aplicar el nuevo valor de fuerza de salto
    fuerzaSaltoTemp = nuevaFuerza;
    
    // Crear un nuevo temporizador
    _saltoTimer = Timer(duracion, () {
      if (!isDisposed) {
        fuerzaSaltoTemp = 0; // Volver a 0 para que use fuerzaSalto base
      }
    });
  }
  
  // Asegurarse de cancelar los temporizadores cuando se dispone la clase
  void dispose() {
    isDisposed = true;
    _velocidadTimer?.cancel();
    _saltoTimer?.cancel();
  }
}