import 'package:flutter/material.dart';
import 'package:oscarruizcode_pingu/servicios/entity/player.dart';
import '../../../servicios/sevices/player_service.dart';
import 'package:oscarruizcode_pingu/widgets/shared_widgets.dart';

class MenuTienda extends StatelessWidget {
  final int userId;
  final String username;
  final PageController pageController;
  final PlayerStats playerStats;
  final PlayerService _playerService = PlayerService();  // Add this line

  MenuTienda({
    super.key, 
    required this.userId,
    required this.username,
    required this.pageController,
    required this.playerStats,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SharedTopBar(
            username: username,
            playerStats: playerStats,
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
    );
  }

  Widget _buildStoreItem(String title, String imagePath, String price, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Material(
        color: const Color.fromRGBO(0, 32, 96, 1),
        elevation: 4,
        borderRadius: BorderRadius.circular(15),
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
                  color: const Color.fromRGBO(255, 255, 255, 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text('Comprar ${item == "ticket" ? "Ticket Game 2" : "Renombrar"}'),
        content: Text('¿Quieres comprar este item por $price estrellas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (playerStats.coins >= price) {
                if (item == 'ticket') {
                  await _playerService.updateTicketsGame2(userId, playerStats.ticketsGame2 + 1);
                } else {
                  await _playerService.updateRenameTickets(userId, playerStats.renameTickets + 1);
                }
                await _playerService.updateCoins(userId, playerStats.coins - price);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('¡Compra exitosa!')),
                );
              } else {
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(dialogContext).showSnackBar(
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