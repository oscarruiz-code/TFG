import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class MenuTienda extends StatefulWidget {
  final int userId;
  final String username;
  final PageController pageController;
  final PlayerStats playerStats;

  const MenuTienda({
    super.key, 
    required this.userId,
    required this.username,
    required this.pageController,
    required this.playerStats,
  });

  @override
  State<MenuTienda> createState() => _MenuTiendaState();
}

class _MenuTiendaState extends State<MenuTienda> {
  final PlayerService _playerService = PlayerService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SharedTopBar(
            username: widget.username,
            playerStats: widget.playerStats,
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
                  'Avatar Premium 3',
                  'assets/perfil/premium/perfil8.png',
                  '1000 ⭐',
                  () => _showPurchaseDialog(context, 'premium_avatar3', 1000),
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
          SharedBottomNav(pageController: widget.pageController),
        ],
      ),
    );
  }

  Widget _buildStoreItem(String title, String imagePath, String price, VoidCallback onTap) {
    bool isAvatarUnlocked = false;
    if (imagePath.contains('premium')) {
      isAvatarUnlocked = widget.playerStats.unlockedPremiumAvatars.contains(imagePath);
    }

    return Container(
      margin: const EdgeInsets.all(10),
      child: GlassContainer(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isAvatarUnlocked ? null : onTap,
            borderRadius: BorderRadius.circular(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(imagePath, width: 64, height: 64),
                    if (isAvatarUnlocked)
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.withOpacity(0.3),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                  ],
                ),
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
                    color: isAvatarUnlocked 
                      ? Colors.green.withOpacity(0.2) 
                      : Colors.white.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isAvatarUnlocked ? '¡YA LO TIENES!' : price,
                    style: TextStyle(
                      color: isAvatarUnlocked ? Colors.green : Colors.white,
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

  Future<void> _showPurchaseDialog(BuildContext context, String itemType, int cost) async {
    if (itemType.startsWith('premium_avatar')) {
      String avatarPath = 'assets/perfil/premium/perfil${itemType.substring(13)}.png';
      if (widget.playerStats.unlockedPremiumAvatars.contains(avatarPath)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Ya tienes este avatar!'),
            backgroundColor: Colors.green,
          ),
        );
        return;
      }
    }
    
    if (widget.playerStats.coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes suficientes monedas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Compra'),
        content: Text('¿Quieres gastar $cost ⭐ en este artículo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Comprar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        if (itemType.startsWith('premium_avatar')) {
          String avatarPath = 'assets/perfil/premium/perfil${itemType.substring(13)}.png';
          List<String> updatedAvatars = [...widget.playerStats.unlockedPremiumAvatars, avatarPath];
          await _playerService.updateUnlockedPremiumAvatars(widget.userId, updatedAvatars);
          await _playerService.updateCoins(widget.userId, widget.playerStats.coins - cost);
          
          setState(() {
            widget.playerStats.unlockedPremiumAvatars.add(avatarPath);
            widget.playerStats.coins -= cost;
          });
          
          // Forzar actualización de la UI
          if (mounted) {
            setState(() {});
          }
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Avatar premium desbloqueado!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else if (itemType == 'ticket') {
          await _playerService.updateTicketsGame2(widget.userId, widget.playerStats.ticketsGame2 + 1);
          await _playerService.updateCoins(widget.userId, widget.playerStats.coins - cost);
          
          setState(() {
            widget.playerStats.ticketsGame2 += 1;
            widget.playerStats.coins -= cost;
          });
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Ticket comprado con éxito!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else if (itemType == 'rename') {
          await _playerService.updateRenameTickets(widget.userId, widget.playerStats.renameTickets + 1);
          await _playerService.updateCoins(widget.userId, widget.playerStats.coins - cost);
          
          setState(() {
            widget.playerStats.renameTickets += 1;
            widget.playerStats.coins -= cost;
          });
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Ticket de renombre comprado con éxito!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al realizar la compra'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}