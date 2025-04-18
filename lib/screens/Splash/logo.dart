import 'package:flutter/material.dart';
import '../../widgets/video_background.dart';
import '../../widgets/animacion_texto.dart';
import 'package:oscarruizcode_pingu/screens/pages/iniciales/login.dart';

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.forward();  // Fades in the logo
    _preloadVideo();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _preloadVideo() async {
    try {
      bool isLoaded = await VideoBackground.preloadVideo();
      
      if (!isLoaded) {
        await Future.delayed(const Duration(seconds: 1));
        isLoaded = await VideoBackground.preloadVideo();
      }

      if (!mounted) return;

      while (mounted && 
             (VideoBackground.getController()?.value.isPlaying != true || 
              VideoBackground.getController()?.value.isBuffering == true)) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      await Future.delayed(const Duration(seconds: 6));
      
      if (mounted && isLoaded) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return FadeTransition(
                opacity: _fadeController,  // Use the same controller for both transitions
                child: const LoginScreen(),
              );
            },
            transitionDuration: const Duration(milliseconds: 1000),  // Match logo fade duration
          ),
        );
        await _fadeController.reverse();  // Reverse after pushing the new screen
      }
    } catch (e) {
      debugPrint('Error en _preloadVideo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar el video')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const VideoBackground(),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              color: Colors.white.withOpacity(0.9),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/imagenes/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextoAnimado(
                      text: 'ICEBERGS',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 15,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}