import '../../../../../dependencias/imports.dart';

class Mapa1 {
  final List<dynamic> objetos;

  Mapa1()
      : objetos = [
          // Plataforma inicial
          Suelo(x: 0, y: 300, width: 100, height: 50),
          Suelo(x: 81, y: 300, width: 100, height: 50),
          Suelo(x: 162, y: 300, width: 100, height: 50),
          Suelo(x: 243, y: 300, width: 100, height: 50),
          Suelo(x:324, y: 300, width: 100, height: 50),
          Suelo(x:405, y: 300, width: 100, height: 50),
          Suelo(x:486, y: 300, width: 100, height: 50),
          Suelo(x:567, y: 300, width: 100, height: 50),
          Suelo(x:648, y: 300, width: 100, height: 50),
          Suelo(x:729, y: 300, width: 100, height: 50),
          Suelo(x:810, y: 300, width: 100, height: 50),
          Suelo(x:891, y: 300, width: 100, height: 50),
          

          //PLATAFORMA FLOTANTES
          Suelo(x: 729, y: 190, width: 100, height: 50),
          Suelo(x: 810, y: 190, width: 100, height: 50),
          Suelo2(x: 795, y: 70, width: 50, height: 100),
          

          //SIGUIENTE PLATAFORMA
          Suelo(x: 972, y: 300, width: 100, height: 50),
          Suelo(x: 1053, y: 300, width: 100, height: 50),
          Rampa(x: 1136, y: 277, width: 100, height: 60),
          Rampa(x: 1202, y: 243, width: 100, height: 60),
          Rampa(x: 1270, y: 209, width: 100, height: 60),
          Rampa(x: 1338, y: 175, width: 100, height: 60),
          Suelo(x: 1415, y: 163, width: 100, height: 50),
          Suelo(x: 1496, y: 163, width: 100, height: 50),
          Suelo(x: 1577, y: 163, width: 100, height: 50),
          Suelo(x: 1658, y: 163, width: 100, height: 50),
          Suelo(x: 1739, y: 163, width: 100, height: 50),


        ];

  List<dynamic> get suelos => objetos.where((obj) => obj is Suelo || obj is Suelo2).toList();
  List<dynamic> get rampas => objetos.where((obj) => obj is Rampa).toList();
}