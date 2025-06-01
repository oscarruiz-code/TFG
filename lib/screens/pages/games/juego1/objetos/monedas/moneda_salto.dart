import '../../../../../../dependencias/imports.dart';


class MonedaSalto extends MonedaBase {
  MonedaSalto({
    required super.x,
    required super.y,
    super.isCollected,
  }) : super(
    spritePath: 'assets/personajes/items/monedas/monedasalto.png',
  );

  @override
  void aplicarEfecto(dynamic player) {
    if (player == null) return;
    
    print('Aplicando efecto de salto');
    print('Fuerza de salto anterior: ${player.fuerzaSaltoTemp}');
    
    // Calcular la fuerza de salto base según el estado
    double fuerzaSaltoBase = player.isCrouching 
        ? -AnimacionSaltoAgachado.fuerzaSalto 
        : -AnimacionSalto.fuerzaSalto;
    
    // Usar el método específico para power-ups de salto
    player.activarPowerUpSalto(
      fuerzaSaltoBase * 2.5,
      const Duration(milliseconds: 5000)
    );
    
    print('Nueva fuerza de salto: ${player.fuerzaSaltoTemp}');
  }
}