import '../objetos/suelo.dart';
import '../objetos/suelo2.dart';
import '../objetos/rampa.dart';

class Mapa1 {
  final List<dynamic> objetos;

  Mapa1()
      : objetos = [
          Suelo(x: 0, y: 300, width: 300, height: 50),
          Suelo2(x: 300, y: 300, width: 200, height: 50),
          Rampa(x: 500, y: 300, width: 120, height: 50),
          Suelo(x: 620, y: 470, width: 200, height: 50),
          Suelo2(x: 820, y: 470, width: 180, height: 50),
          Rampa(x: 1000, y: 470, width: 120, height: 50),
          Suelo(x: 1120, y: 440, width: 250, height: 50),
        ];

  List<dynamic> get suelos => objetos.where((obj) => obj is Suelo || obj is Suelo2).toList();
  List<dynamic> get rampas => objetos.where((obj) => obj is Rampa).toList();
}