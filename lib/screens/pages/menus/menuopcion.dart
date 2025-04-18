import 'package:flutter/material.dart';
import 'package:oscarruizcode_pingu/servicios/entity/player.dart';
import '../../../servicios/sevices/player_service.dart';
import 'package:oscarruizcode_pingu/widgets/shared_widgets.dart';

class MenuOpciones extends StatelessWidget {
  final int userId;
  final String username;  // Add this line
  final PageController pageController;
  final PlayerService _playerService = PlayerService();

  MenuOpciones({
    super.key, 
    required this.userId,
    required this.username,  // Add this line
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlayerStats>(
      future: _playerService.getPlayerStats(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final playerStats = snapshot.data!;
        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/imagenes/fondo.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                SharedTopBar(
                  username: username,  // Change this line
                  playerStats: playerStats,
                ),
                const Text(
                  'OPCIONES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.blue, blurRadius: 10)],
                  ),
                ),
                const SizedBox(height: 20),
                _buildOptionButton(
                  'Cambiar Nombre',
                  Icons.edit,
                  () async {
                    // Lógica para cambiar nombre
                  },
                ),
                _buildOptionButton(
                  'Música',
                  Icons.music_note,
                  () {
                    // Lógica para música
                  },
                ),
                _buildOptionButton(
                  'Efectos de Sonido',
                  Icons.volume_up,
                  () {
                    // Lógica para efectos
                  },
                ),
                _buildOptionButton(
                  'Cerrar Sesión',
                  Icons.exit_to_app,
                  () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                ),
                const Spacer(),
                SharedBottomNav(pageController: pageController),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white30),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 15),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}