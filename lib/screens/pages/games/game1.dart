import 'package:flutter/material.dart';

class Game1 extends StatelessWidget {
  const Game1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game 1'),
        backgroundColor: Colors.blue,
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
            '¡Bienvenido al Juego 1!',
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