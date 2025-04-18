import 'package:oscarruizcode_pingu/servicios/entity/player.dart';
import 'package:oscarruizcode_pingu/widgets/video_background.dart';
import 'package:flutter/material.dart';
import 'package:oscarruizcode_pingu/servicios/sevices/player_service.dart';
import 'package:oscarruizcode_pingu/widgets/shared_widgets.dart';
import 'menuopcion.dart';
import 'menutienda.dart';
import 'menuhistorial.dart';
import '../games/game1.dart';
import '../games/game2.dart';

class MenuInicio extends StatefulWidget {
  final int userId;
  final String username;  // Add this line
  const MenuInicio({
    super.key, 
    required this.userId,
    required this.username,  // Add this line
  });

  @override
  State<MenuInicio> createState() => _MenuInicioState();
}

class _MenuInicioState extends State<MenuInicio> {
  final PlayerService _playerService = PlayerService();
  final PageController _pageController = PageController(initialPage: 1);
  late Future<PlayerStats> _playerStatsFuture;

  @override
  void initState() {
    super.initState();
    VideoBackground.disposeVideo();
    _playerStatsFuture = _playerService.getPlayerStats(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlayerStats>(
      future: _playerStatsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final playerStats = snapshot.data!;
        return Scaffold(
          body: PageView(
            controller: _pageController,
            children: [
              MenuOpciones(
                userId: widget.userId,
                username: widget.username,
                pageController: _pageController,
              ),
              _buildMainPage(playerStats),
              MenuTienda(
                userId: widget.userId,
                username: widget.username,
                pageController: _pageController,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainPage(PlayerStats playerStats) {
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
              username: widget.username,  // Change this line
              playerStats: playerStats,
            ),
            const Spacer(),
            _buildGameButtons(playerStats),
            const SizedBox(height: 20),
            _buildHistoryButton(),
            const Spacer(),
            SharedBottomNav(pageController: _pageController),
          ],
        ),
      ),
    );
  }

  Widget _buildGameButtons(PlayerStats playerStats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildGameButton('Game 1', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Game1()),
          );
        }),
        _buildGameButton('Game 2', () {
          if (playerStats.ticketsGame2 > 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Game2()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Necesitas un ticket para jugar Game 2')),
            );
          }
        }),
      ],
    );
  }

  Widget _buildGameButton(String title, VoidCallback onPressed) {
    return Container(
      width: 150,
      height: 150,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuHistorial(userId: widget.userId),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history),
            SizedBox(width: 10),
            Text(
              'Historial de Partidas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}