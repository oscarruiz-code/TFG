import '../../../../../dependencias/imports.dart';

class Mapa1 {
  final List<dynamic> objetos;

  Mapa1()
      : objetos = [

          //PLATAFORMA INICIAL
          Suelo(x: 0, y: 300, width: 100, height: 50),
          Suelo(x: 81, y: 300, width: 100, height: 50),
          Suelo(x: 162, y: 300, width: 100, height: 50),
          Suelo(x: 243, y: 300, width: 100, height: 50),
          Suelo(x: 324, y: 300, width: 100, height: 50),
          Suelo(x: 405, y: 300, width: 100, height: 50),
          Suelo(x: 486, y: 300, width: 100, height: 50),
          Suelo(x: 567, y: 300, width: 100, height: 50),
          Suelo(x: 648, y: 300, width: 100, height: 50),
          Suelo(x: 729, y: 300, width: 100, height: 50),
          Suelo(x: 810, y: 300, width: 100, height: 50),
          Suelo(x: 891, y: 300, width: 100, height: 50),
          Suelo(x: 972, y: 300, width: 100, height: 50),
          Suelo(x: 1053, y: 300, width: 100, height: 50),
          Suelo(x: 1134, y: 300, width: 100, height: 50),
          Suelo(x: 1215, y: 300, width: 100, height: 50),
          Suelo(x: 1296, y: 300, width: 100, height: 50),
          Suelo(x: 1377, y: 300, width: 100, height: 50),
          Suelo(x: 1458, y: 300, width: 100, height: 50),
          Suelo(x: 1539, y: 300, width: 100, height: 50),
          Suelo(x: 1620, y: 300, width: 100, height: 50),

          //PLATAFORMA 2
          Rampa(x: 1703, y: 277, width: 100, height: 60),
          Rampa(x: 1771, y: 243, width: 100, height: 60),
          Rampa(x: 1840, y: 209, width: 100, height: 60),
          Rampa(x: 1908, y: 175, width: 100, height: 60),
          Suelo2(x: 2040, y: 149, width: 50, height: 100),
          Suelo2(x: 2140, y: 149, width: 50, height: 100),
          Suelo2(x: 2240, y: 149, width: 50, height: 100),
          Suelo(x: 2340, y: 165, width: 100, height: 50),
          RampaInvertida(x: 2415, y: 177, width: 100, height: 60),
          RampaInvertida(x:2486 , y: 213, width: 100, height: 60),
          RampaInvertida(x: 2557, y: 249, width: 100, height: 60),
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
          Rampa(x: 3500, y: 215, width: 100, height: 60),
          Rampa(x: 3570, y: 181, width: 100, height: 60),
          Suelo(x: 3647, y: 169, width: 100, height: 50),
          Suelo(x: 3717, y: 169, width: 100, height: 50),
          Suelo(x: 3787, y: 169, width: 100, height: 50),
          Suelo(x: 3857, y: 169, width: 100, height: 50),
          RampaInvertida(x: 3932, y: 181, width: 100, height: 60),
          RampaInvertida(x: 4002, y: 215, width: 100, height: 60),
          Suelo(x: 4150, y: 113, width: 100, height: 50),
          Suelo(x: 4300, y: 113, width: 100, height: 50),
          Suelo(x: 4450, y: 113, width: 100, height: 50),
          Suelo(x: 4600, y: 113, width: 100, height: 50),

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
          MonedaVelocidad(x: 810, y: 290),
          MonedaNormal(x: 840, y: 290),
          MonedaNormal(x: 870, y: 290),
          MonedaNormal(x: 900, y: 290),
          MonedaNormal(x: 930, y: 290),  


          // Casa final
          Casa(x: 5075, y: 200, width: 100, height: 100),
        ];

  List<dynamic> get suelos => objetos.where((obj) => obj is Suelo || obj is Suelo2).toList();
  List<dynamic> get rampas => objetos.where((obj) => obj is Rampa || obj is RampaInvertida).toList();
  List<dynamic> get casas => objetos.where((obj) => obj is Casa).toList();
  List<dynamic> get monedas => objetos.where((obj) => obj is MonedaNormal || obj is MonedaSalto || obj is MonedaVelocidad).toList();
}