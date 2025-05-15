import '../../../../../dependencias/imports.dart';

class Mapa1 {
  final List<dynamic> objetos;

  Mapa1()
      : objetos = [
          // Plataforma inicial
          Suelo(x: 0, y: 230, width: 100, height: 50),
          Suelo(x: 81, y: 230, width: 100, height: 50),
          Suelo(x: 162, y: 230, width: 100, height: 50),
          Suelo(x: 243, y: 230, width: 100, height: 50),
          
          // Primera sección - Rampa ascendente
          Rampa(x: 324, y: 207, width: 100, height: 60),
          Rampa(x: 392, y: 173, width: 100, height: 60),
          
          // Plataforma elevada
          Suelo(x: 473, y: 173, width: 100, height: 50),
          Suelo(x: 554, y: 173, width: 100, height: 50),
          
          // Descenso con rampa invertida
          Rampa(x: 629, y: 185, width: 100, height: 60, invertida: true),
          Rampa(x: 704, y: 221, width: 100, height: 60, invertida: true),
          
          // Sección de plataformas alternadas
          Suelo2(x: 785, y: 180, width: 50, height: 100),
          Suelo2(x: 830, y: 180, width: 50, height: 100),
          
          // Plataforma baja con rampa
          Suelo(x: 875, y: 230, width: 100, height: 50),
          Rampa(x: 958, y: 207, width: 100, height: 60),
          
          // Sección elevada con plataformas
          Suelo(x: 1041, y: 173, width: 100, height: 50),
          Suelo(x: 1122, y: 173, width: 100, height: 50),
          
          // Descenso gradual
          Rampa(x: 1197, y: 185, width: 100, height: 60, invertida: true),
          Suelo(x: 1272, y: 230, width: 100, height: 50),
          
          // Final del nivel
          Suelo(x: 1353, y: 230, width: 100, height: 50),
          Suelo(x: 1434, y: 230, width: 100, height: 50),
        ];

  List<dynamic> get suelos => objetos.where((obj) => obj is Suelo || obj is Suelo2).toList();
  List<dynamic> get rampas => objetos.where((obj) => obj is Rampa).toList();
}