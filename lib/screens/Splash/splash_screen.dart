import 'package:flutter/material.dart';
import 'package:oscarruizcode_pingu/screens/Inicio/inicio.dart';
import 'package:oscarruizcode_pingu/widgets/animacion_texto.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 10), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Inicio()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/imagenes/splash_fondo.png'), // Ruta a la imagen de fondo
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextoAnimado(
                text: 'ICEBERGS',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Ajusta el color según el fondo
                ),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/imagenes/logo.png', // Reemplaza con el archivo del logo
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 20),
              const LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                backgroundColor: Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}