import 'package:oscarruizcode_pingu/dependencias/imports.dart';

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
                  'Avatar Premium 1',
                  'assets/perfil/premium/perfil6.png',
                  '1000 ⭐',
                  () => _showPurchaseDialog(context, 'premium_avatar1', 1000),
                ),
                _buildStoreItem(
                  'Avatar Premium 2',
                  'assets/perfil/premium/perfil7.png',
                  '1000 ⭐',
                  () => _showPurchaseDialog(context, 'premium_avatar2', 1000),
                ),
                _buildStoreItem(
                  'Avatar Premium 2',
                  'assets/perfil/premium/perfil8.png',
                  '1000 ⭐',
                  () => _showPurchaseDialog(context, 'premium_avatar2', 1000),
                ),
                _buildStoreItem(
                  'Ticket Game 2',
                  'assets/etiquetas/game.png',
                  '500 ⭐',
                  () => _showPurchaseDialog(context, 'ticket', 500),
                ),
                _buildStoreItem(
                  'Renombrar',
                  'assets/etiquetas/rename.png',
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
      child: GlassContainer(
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
                    color: Colors.white.withOpacity(0.1),
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
      ),
    );
  }

  Future<void> _showPurchaseDialog(BuildContext context, String item, int price) async {
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text('Comprar ${item.startsWith('premium_avatar') ? "Avatar Premium" : item == "ticket" ? "Ticket Game 2" : "Renombrar"}'),
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
                } else if (item == 'rename') {
                  await _playerService.updateRenameTickets(userId, playerStats.renameTickets + 1);
                } else if (item.startsWith('premium_avatar')) {
                  // Obtener los avatares desbloqueados actuales y convertirlos a Object
                  dynamic currentUnlockedAvatars = playerStats.unlockedPremiumAvatars;
                  String avatarsString = currentUnlockedAvatars?.toString() ?? '';
                  
                  // Agregar el nuevo avatar a la lista de desbloqueados
                  String avatarPath = '';
                  switch (item) {
                    case 'premium_avatar1':
                      avatarPath = 'assets/perfil/premium/perfil6.png';
                      break;
                    case 'premium_avatar2':
                      avatarPath = 'assets/perfil/premium/perfil7.png';
                      break;
                    case 'premium_avatar3':
                      avatarPath = 'assets/perfil/premium/perfil8.png';
                      break;
                  }
                  
                  if (avatarPath.isNotEmpty) {
                    List<String> unlockedAvatars = avatarsString.split(',')
                      ..removeWhere((element) => element.isEmpty);
                    if (!unlockedAvatars.contains(avatarPath)) {
                      unlockedAvatars.add(avatarPath);
                      await _playerService.updateUnlockedAvatars(userId, unlockedAvatars.join(','));
                    }
                  }
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