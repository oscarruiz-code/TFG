import 'package:oscarruizcode_pingu/widgets/video_background.dart';
import 'package:flutter/material.dart';

class MenuInicio extends StatefulWidget {
  const MenuInicio({super.key});

  @override
  State<MenuInicio> createState() => _MenuInicioState();
}

class _MenuInicioState extends State<MenuInicio> {
  @override
  void initState() {
    super.initState();
    // Aseguramos que el dispose se ejecute después de que el widget esté montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VideoBackground.disposeVideo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header with title
            Container(
              padding: const EdgeInsets.all(20),
              child: const Text(
                'ICEBERGS',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.blue,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
            // Main menu options
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(20),
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _buildMenuButton(
                    'Play',
                    Icons.play_arrow,
                    () {
                      // Navigate to game screen
                    },
                  ),
                  _buildMenuButton(
                    'Settings',
                    Icons.settings,
                    () {
                      // Navigate to settings screen
                    },
                  ),
                  _buildMenuButton(
                    'Profile',
                    Icons.person,
                    () {
                      // Navigate to profile screen
                    },
                  ),
                  _buildMenuButton(
                    'Exit',
                    Icons.exit_to_app,
                    () {
                      // Exit the app
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(String title, IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(0, 0, 255, 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color.fromRGBO(0, 0, 255, 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 255, 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}