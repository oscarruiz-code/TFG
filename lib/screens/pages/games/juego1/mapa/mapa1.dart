import '../../../../../dependencias/imports.dart';

class Mapa1 {
  final List<dynamic> objetos;

  Mapa1()
      : objetos = [
         
          Suelo(x: 0, y: 200, width: 100, height: 50),
          
        ];

  List<dynamic> get suelos => objetos.where((obj) => obj is Suelo || obj is Suelo2).toList();
  List<dynamic> get rampas => objetos.where((obj) => obj is Rampa).toList();
}