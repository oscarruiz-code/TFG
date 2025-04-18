import 'package:flutter/material.dart';
import 'package:oscarruizcode_pingu/servicios/entity/player.dart';
import '../../../servicios/sevices/player_service.dart';
import 'package:oscarruizcode_pingu/widgets/shared_widgets.dart';

class MenuTienda extends StatelessWidget {
  final int userId;
  final String username;  // Add this line
  final PageController pageController;
  final PlayerService _playerService = PlayerService();

  MenuTienda({
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
                  'TIENDA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.blue, blurRadius: 10)],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildStoreItem(
                        'Ticket Game 2',
                        'assets/imagenes/ticket.png',
                        '500 ⭐',
                        () => _showPurchaseDialog(context, 'ticket', 500),
                      ),
                      _buildStoreItem(
                        'Renombrar',
                        'assets/imagenes/rename.png',
                        '200 ⭐',
                        () => _showPurchaseDialog(context, 'rename', 200),
                      ),
                    ],
                  ),
                ),
                SharedBottomNav(pageController: pageController),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoreItem(String title, String imagePath, String price, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white30),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imagePath, width: 64, height: 64),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  price,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPurchaseDialog(BuildContext context, String item, int price) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Comprar ${item == "ticket" ? "Ticket Game 2" : "Renombrar"}'),
        content: Text('¿Quieres comprar este item por $price estrellas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final playerStats = await _playerService.getPlayerStats(userId);
              if (playerStats.coins >= price) {
                if (item == 'ticket') {
                  await _playerService.updateTicketsGame2(userId, playerStats.ticketsGame2 + 1);
                } else {
                  await _playerService.updateRenameTickets(userId, playerStats.renameTickets + 1);
                }
                await _playerService.updateCoins(userId, playerStats.coins - price);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Compra exitosa!')),
                );
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No tienes suficientes estrellas')),
                );
              }
            },
            child: const Text('Comprar'),
          ),
        ],
      ),
    );
  }
}