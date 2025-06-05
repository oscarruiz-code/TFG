import '../../../../../dependencias/imports.dart';

class Mapa1 {
  final List<dynamic> objetos;

  Mapa1({List<Map<String, double>>? collectedCoinsPositions})
      : objetos = [

          //PLATAFORMA INICIAL
          Suelo(x: 0, y: 230, width: 100, height: 50),
          Suelo(x: 81, y: 230, width: 100, height: 50),
          Suelo(x: 162, y: 230, width: 100, height: 50),
          Suelo(x: 243, y: 230, width: 100, height: 50),
          Suelo(x: 324, y: 230, width: 100, height: 50),
          Suelo(x: 405, y: 230, width: 100, height: 50),
          Suelo(x: 486, y: 230, width: 100, height: 50),
          Suelo(x: 567, y: 230, width: 100, height: 50),
          Suelo(x: 648, y: 230, width: 100, height: 50),
          Suelo(x: 729, y: 230, width: 100, height: 50),
          Suelo(x: 810, y: 230, width: 100, height: 50),
          Suelo(x: 901, y: 300, width: 100, height: 50),
          Suelo(x: 982, y: 300, width: 100, height: 50),
          Suelo(x: 1063, y: 300, width: 100, height: 50),
          Suelo(x: 1144, y: 300, width: 100, height: 50),
          Suelo(x: 1225, y: 300, width: 100, height: 50),
          Suelo(x: 1306, y: 300, width: 100, height: 50),
          Suelo(x: 1387, y: 300, width: 100, height: 50),
          Suelo(x: 1468, y: 300, width: 100, height: 50),
          Suelo(x: 1549, y: 300, width: 100, height: 50),
          Suelo(x: 1630, y: 300, width: 100, height: 50),

          //PLATAFORMA 2
          Suelo(x: 1730, y: 240, width: 100, height: 50),
          Suelo(x: 1830, y: 200, width: 100, height: 50),
          Suelo2(x: 1940, y: 149, width: 50, height: 100),
          Suelo2(x: 2040, y: 149, width: 50, height: 100),
          Suelo2(x: 2140, y: 149, width: 50, height: 100),
          Suelo2(x: 2240, y: 149, width: 50, height: 100),
          Suelo(x: 2340, y: 165, width: 100, height: 50),
          Suelo(x: 2450, y: 200, width: 100, height: 50),
          Suelo(x: 2550, y: 230, width: 100, height: 50),
          Suelo2(x: 2647, y: 257, width: 50, height: 100),
          Suelo(x:2685, y: 271, width: 100, height: 50),

          //PLATAFORMA 3
          Suelo(x: 1900, y: 300, width: 100, height: 50),
          Suelo(x: 1968, y: 300, width: 100, height: 50),
          Suelo(x: 2036, y: 300, width: 100, height: 50),
          Suelo(x: 2096, y: 300, width: 100, height: 50),
          Suelo(x: 2156, y: 300, width: 100, height: 50),
          Suelo(x: 2216, y: 300, width: 100, height: 50),
          Suelo(x: 2276, y: 300, width: 100, height: 50),
        
          //PLATAFORMA 4
          Suelo2(x: 2850, y: 227, width: 50, height: 100),
          Suelo2(x: 2950, y: 207, width: 50, height: 100),
          Suelo2(x: 3050, y: 187, width: 50, height: 100),
          Suelo2(x: 3150, y: 167, width: 50, height: 100),
          Suelo2(x: 3250, y: 147, width: 50, height: 100),

          //PLATAFORMA 5
          Suelo(x: 3350, y: 300, width: 100, height: 50),
          Suelo(x: 3418, y: 300, width: 100, height: 50),
          Suelo(x: 3486, y: 300, width: 100, height: 50),
          Suelo(x: 3554, y: 300, width: 100, height: 50),
          Suelo(x: 3622, y: 300, width: 100, height: 50),
          Suelo(x: 3690, y: 300, width: 100, height: 50), 
          Suelo(x: 3758, y: 300, width: 100, height: 50),
          Suelo(x: 3907, y: 300, width: 100, height: 50),
          Suelo(x: 3988, y: 300, width: 100, height: 50),
          Suelo(x: 4069, y: 300, width: 100, height: 50),
          Suelo(x: 4140, y: 300, width: 100, height: 50),



          //PLATAFORMA 6
          Suelo(x: 3430, y: 230, width: 100, height: 50),
          Suelo(x: 3530, y: 200, width: 100, height: 50),
          Suelo(x: 3647, y: 184, width: 100, height: 50),
          Suelo(x: 3717, y: 184, width: 100, height: 50),
          Suelo(x: 3787, y: 184, width: 100, height: 50),
          Suelo(x: 3857, y: 184, width: 100, height: 50),
          Suelo(x: 3970, y: 200, width: 100, height: 50),
          Suelo(x: 4090, y: 230, width: 100, height: 50),
          Suelo(x: 4150, y: 133, width: 100, height: 50),
          Suelo(x: 4300, y: 133, width: 100, height: 50),
          Suelo(x: 4450, y: 133, width: 100, height: 50),
          Suelo(x: 4600, y: 133, width: 100, height: 50),

          //PLATAFORMA 7
          Suelo(x: 4221, y: 300, width: 100, height: 50),
          Suelo(x: 4289, y: 300, width: 100, height: 50),
          Suelo(x: 4357, y: 300, width: 100, height: 50),
          Suelo(x: 4425, y: 300, width: 100, height: 50),
          Suelo(x: 4493, y: 300, width: 100, height: 50),
          Suelo(x: 4561, y: 300, width: 100, height: 50),
          Suelo(x: 4629, y: 300, width: 100, height: 50),
          Suelo(x: 4707, y: 300, width: 100, height: 50),

          //PLATAFORMA 8
          Suelo(x: 5007, y: 300, width: 100, height: 50),
          Suelo(x: 5075, y: 300, width: 100, height: 50),
          Suelo(x: 5143, y: 300, width: 100, height: 50),
          
          //MONEDAS
          MonedaVelocidad(x: 990, y: 280, isCollected: _isCollected(990.0, 280.0, collectedCoinsPositions)),
          MonedaNormal(x: 1050, y: 280, isCollected: _isCollected(1050.0, 280.0, collectedCoinsPositions)),
          MonedaNormal(x: 1110, y: 280, isCollected: _isCollected(1110.0, 280.0, collectedCoinsPositions)),
          MonedaNormal(x: 1170, y: 280, isCollected: _isCollected(1170.0, 280.0, collectedCoinsPositions)),
          MonedaNormal(x: 1230, y: 280, isCollected: _isCollected(1230.0, 280.0, collectedCoinsPositions)),
          MonedaNormal(x: 1290, y: 280, isCollected: _isCollected(1290.0, 280.0, collectedCoinsPositions)),    
        
          //MONEDAS 2
          MonedaNormal(x: 1916, y: 280, isCollected: _isCollected(1916.0, 280.0, collectedCoinsPositions)),
          MonedaNormal(x: 1976, y: 280, isCollected: _isCollected(1976.0, 280.0, collectedCoinsPositions)), 
          MonedaNormal(x: 2036, y: 280, isCollected: _isCollected(2036.0, 280.0, collectedCoinsPositions)), 
          MonedaSalto(x: 2096, y: 280, isCollected: _isCollected(2096.0, 280.0, collectedCoinsPositions)),
          MonedaNormal(x: 2156, y: 280, isCollected: _isCollected(2156.0, 280.0, collectedCoinsPositions)), 
          MonedaNormal(x: 2216, y: 280, isCollected: _isCollected(2216.0, 280.0, collectedCoinsPositions)),
          MonedaNormal(x: 2276, y: 280, isCollected: _isCollected(2276.0, 280.0, collectedCoinsPositions)),  
          
          //MONEDAS 3
          MonedaNormal(x: 2850, y: 207, isCollected: _isCollected(2850.0, 207.0, collectedCoinsPositions)), 
          MonedaNormal(x: 2950, y: 187, isCollected: _isCollected(2950.0, 187.0, collectedCoinsPositions)), 
          MonedaNormal(x: 3050, y: 167, isCollected: _isCollected(3050.0, 167.0, collectedCoinsPositions)), 
          MonedaNormal(x: 3150, y: 147, isCollected: _isCollected(3150.0, 147.0, collectedCoinsPositions)), 
          MonedaNormal(x: 3250, y: 127, isCollected: _isCollected(3250.0, 127.0, collectedCoinsPositions)),  

          //MONEDAS 4
          MonedaNormal(x: 3642, y: 280, isCollected: _isCollected(3642.0, 280.0, collectedCoinsPositions)),
          MonedaNormal(x: 3702, y: 280, isCollected: _isCollected(3702.0, 280.0, collectedCoinsPositions)), 
          MonedaNormal(x: 3762, y: 280, isCollected: _isCollected(3762.0, 280.0, collectedCoinsPositions)), 
          MonedaNormal(x: 3822, y: 280, isCollected: _isCollected(3822.0, 280.0, collectedCoinsPositions)),
          MonedaNormal(x: 3642, y: 240, isCollected: _isCollected(3642.0, 240.0, collectedCoinsPositions)),
          MonedaNormal(x: 3702, y: 240, isCollected: _isCollected(3702.0, 240.0, collectedCoinsPositions)), 
          MonedaNormal(x: 3762, y: 240, isCollected: _isCollected(3762.0, 240.0, collectedCoinsPositions)), 
          MonedaNormal(x: 3822, y: 240, isCollected: _isCollected(3822.0, 240.0, collectedCoinsPositions)),

          //MONEDAS 5
          MonedaNormal(x: 3687, y: 164, isCollected: _isCollected(3687.0, 164.0, collectedCoinsPositions)),
          MonedaNormal(x: 3747, y: 164, isCollected: _isCollected(3747.0, 164.0, collectedCoinsPositions)),
          MonedaVelocidad(x: 3807, y: 164, isCollected: _isCollected(3807.0, 164.0, collectedCoinsPositions)),
          MonedaNormal(x: 3867, y: 164, isCollected: _isCollected(3867.0, 164.0, collectedCoinsPositions)),
          MonedaNormal(x: 3927, y: 164, isCollected: _isCollected(3927.0, 164.0, collectedCoinsPositions)),

          //MONEDAS 6
          MonedaSalto(x: 4353, y: 280, isCollected: _isCollected(4353.0, 280.0, collectedCoinsPositions)),
          MonedaSalto(x: 4557, y: 280, isCollected: _isCollected(4557.0, 280.0, collectedCoinsPositions)),

          //MONEDAS 7
          MonedaNormal(x: 4150, y: 113, isCollected: _isCollected(4150.0, 113.0, collectedCoinsPositions)),
          MonedaNormal(x: 4200, y: 113, isCollected: _isCollected(4200.0, 113.0, collectedCoinsPositions)),
          MonedaNormal(x: 4300, y: 113, isCollected: _isCollected(4300.0, 113.0, collectedCoinsPositions)),
          MonedaNormal(x: 4350, y: 113, isCollected: _isCollected(4350.0, 113.0, collectedCoinsPositions)),
          MonedaNormal(x: 4450, y: 113, isCollected: _isCollected(4450.0, 113.0, collectedCoinsPositions)),
          MonedaNormal(x: 4500, y: 113, isCollected: _isCollected(4500.0, 113.0, collectedCoinsPositions)),
          MonedaNormal(x: 4600, y: 113, isCollected: _isCollected(4600.0, 113.0, collectedCoinsPositions)),
          MonedaNormal(x: 4650, y: 113, isCollected: _isCollected(4650.0, 113.0, collectedCoinsPositions)),


          // Casa final
          Casa(x: 5075, y: 200, width: 100, height: 100),
        ];

  static bool _isCollected(double x, double y, List<Map<String, double>>? positions) {
    if (positions == null) {
        debugPrint('No saved positions available for coin at x:$x, y:$y');
        return false;
    }
    
    // Usar una pequeña tolerancia para la comparación
    const double epsilon = 0.1;  // Puedes ajustar este valor según sea necesario
    bool isCollected = positions.any((pos) => 
        (pos['x']! - x).abs() < epsilon && 
        (pos['y']! - y).abs() < epsilon
    );

    return isCollected;
}

  List<dynamic> get suelos => objetos.where((obj) => obj is Suelo || obj is Suelo2).toList();
  List<dynamic> get casas => objetos.whereType<Casa>().toList();
  List<MonedaBase> get monedas => objetos.whereType<MonedaBase>().toList();


  double get anchoMundo {
    if (objetos.isEmpty) return 0;
    final last = objetos.last;
    return last.x + (last.width ?? 0);
  }
}