import '../../../../../../dependencias/imports.dart';


class MonedaSalto extends MonedaBase {
  MonedaSalto({
    required super.x,
    required super.y,
    super.isCollected,
  }) : super(
    spritePath: 'assets/personajes/items/monedas/monedasalto.png',
    valor: 0, // Establecer valor a 0 para que no sume al contador
  );

  @override
  void aplicarEfecto(dynamic player) {
    if (player == null) return;
    
    // Calcular la fuerza de salto base según el estado
    double fuerzaSaltoBase = player.isCrouching 
        ? -AnimacionSaltoAgachado.fuerzaSalto  // Quitamos el signo negativo
        : -AnimacionSalto.fuerzaSalto;  // Quitamos el signo negativo
    
    // Usar el método específico para power-ups de salto
    player.activarPowerUpSalto(
      player.isCrouching ? fuerzaSaltoBase : fuerzaSaltoBase * 1.5,
      const Duration(milliseconds: 5000)
    );
  }
}