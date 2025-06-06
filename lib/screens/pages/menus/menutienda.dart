import 'package:oscarruizcode_pingu/dependencias/imports.dart';
import 'package:flutter/services.dart';

/// Widget que muestra la tienda del juego donde los usuarios pueden comprar
/// avatares premium, tickets para Game 2 y tickets para cambiar su nombre.
///
/// Permite a los usuarios gastar monedas para adquirir diferentes elementos
/// y muestra confirmaciones de compra.
class MenuTienda extends StatefulWidget {
  /// ID único del usuario.
  final int userId;
  
  /// Nombre de usuario actual.
  final String username;
  
  /// Controlador de página para la navegación entre pantallas.
  final PageController pageController;
  
  /// Estadísticas del jugador que incluyen monedas y avatares desbloqueados.
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
    bool isAvatarUnlocked = widget.playerStats.unlockedPremiumAvatars.contains(imagePath);

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
                          color: Colors.blue.withOpacity(0.3),
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
                      ? Colors.blue.withOpacity(0.2) 
                      : Colors.white.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isAvatarUnlocked ? '¡YA LO TIENES!' : price,
                    style: TextStyle(
                      color: isAvatarUnlocked ? const Color.fromARGB(255, 1, 33, 175) : Colors.white,
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
    String? avatarPath;
    if (itemType.startsWith('premium_avatar')) {
      // Ajusta el mapeo aquí:
      int avatarNumber = int.parse(itemType.substring(14)); // premium_avatar1 -> 1
      int realAvatar = avatarNumber + 5; // 1->6, 2->7, 3->8
      avatarPath = 'assets/perfil/premium/perfil$realAvatar.png';
      if (widget.playerStats.unlockedPremiumAvatars.contains(avatarPath)) {
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
        if (itemType.startsWith('premium_avatar') && avatarPath != null) {
          await _playerService.unlockPremiumAvatar(widget.userId, avatarPath);
          await _playerService.updateCoins(widget.userId, widget.playerStats.coins - cost);
          setState(() {
            widget.playerStats.unlockedPremiumAvatars.add(avatarPath!);
            widget.playerStats.coins -= cost;
          });
        } else if (itemType == 'ticket') {
          await _playerService.updateTicketsGame2(widget.userId, widget.playerStats.ticketsGame2 + 1);
          await _playerService.updateCoins(widget.userId, widget.playerStats.coins - cost);
          
          setState(() {
            widget.playerStats.ticketsGame2 += 1;
            widget.playerStats.coins -= cost;
          });
        } else if (itemType == 'rename') {
          await _playerService.updateRenameTickets(widget.userId, widget.playerStats.renameTickets + 1);
          await _playerService.updateCoins(widget.userId, widget.playerStats.coins - cost);
          
          setState(() {
            widget.playerStats.renameTickets += 1;
            widget.playerStats.coins -= cost;
          });
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