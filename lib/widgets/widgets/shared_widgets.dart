import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class SharedTopBar extends StatelessWidget {
  final String username;
  final PlayerStats playerStats;
  final PlayerService _playerService = PlayerService();  // Add this line

  SharedTopBar({
    super.key,
    required this.username,
    required this.playerStats,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showProfilePictureDialog(context),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(playerStats.currentAvatar),
                ),
                const SizedBox(width: 10),
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 5),
              Text(
                '${playerStats.coins}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 15),
              const Text(
                '🎟️',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 5),
              Text(
                '${playerStats.ticketsGame2}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showProfilePictureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Avatar'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Avatares Gratuitos',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(5, (index) {
                  String avatarPath = 'assets/perfil/gratis/perfil${index + 1}.png';
                  return GestureDetector(
                    onTap: () async {
                      await _playerService.updateProfilePicture(
                        playerStats.userId,
                        avatarPath
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(
                          context,
                          '/menu',
                          arguments: {
                            'userId': playerStats.userId,
                            'username': username
                          }
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(avatarPath),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              const Text('Avatares Premium',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(3, (index) {
                  String avatarPath = 'assets/perfil/premium/perfil${index + 6}.png';
                  bool hasAccess = playerStats.unlockedPremiumAvatars.contains(avatarPath);
                  
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: hasAccess ? () async {
                          await _playerService.updateProfilePicture(
                            playerStats.userId,
                            avatarPath
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.pushReplacementNamed(
                              context,
                              '/menu',
                              arguments: {
                                'userId': playerStats.userId,
                                'username': username
                              }
                            );
                          }
                        } : null,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(avatarPath),
                          child: !hasAccess ? const Icon(
                            Icons.lock,
                            color: Colors.white,
                          ) : null,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SharedBottomNav extends StatelessWidget {
  final PageController pageController;

  const SharedBottomNav({
    super.key,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => pageController.animateToPage(0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut),
          ),
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => pageController.animateToPage(1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut),
          ),
          IconButton(
            icon: const Icon(Icons.store, color: Colors.white),
            onPressed: () => pageController.animateToPage(2,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }
}