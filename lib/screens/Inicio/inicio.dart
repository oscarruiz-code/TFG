import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; // Importar la librería de video

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/videos/fondo_inicio.mp4') // Ruta al video animado
      ..initialize().then((_) {
        setState(() {}); // Actualiza el estado cuando el video está listo
      })
      ..play(); // Reproducir automáticamente
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bienvenido a la página de inicio"),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          _controller.value.isInitialized
              ? VideoPlayer(_controller)
              : Container(color: Colors.black), // Fondo negro mientras se carga el video
          Center(
            child: const Text(
              "JEJEJEJE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}