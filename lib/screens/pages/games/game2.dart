import 'package:flutter/material.dart';

class Game2 extends StatelessWidget {
  const Game2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game 2'),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/imagenes/fondo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: Text(
            '¡Bienvenido al Juego 2!',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}