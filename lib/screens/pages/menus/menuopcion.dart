import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class MenuOpciones extends StatelessWidget {
  final int userId;
  final String username;
  final PageController pageController;
  final PlayerStats playerStats;
  final PlayerService _playerService = PlayerService();  // Add this line
  final MusicService _musicService = MusicService();

  MenuOpciones({
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
          _buildOptionButton(
            'Cambiar Nombre',
            Icons.edit,
            () async {
              if (playerStats.hasUsedFreeRename && playerStats.renameTickets <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Necesitas un ticket para cambiar tu nombre')),
                );
                return;
              }

              TextEditingController nameController = TextEditingController();
              
              // Mostrar diálogo diferente según sea primera vez o no
              final newName = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(playerStats.hasUsedFreeRename 
                    ? 'Cambiar Nombre (Requiere Ticket)' 
                    : 'Primer Cambio de Nombre (Gratis)'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (playerStats.hasUsedFreeRename) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🎟️', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 8),
                            Text(
                              'Tickets disponibles: ${playerStats.renameTickets}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Se usará 1 ticket para cambiar tu nombre'),
                        const SizedBox(height: 16),
                      ] else
                        const Text('¡Tu primer cambio de nombre es gratis!'),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: '¿Qué nombre deseas usar?',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, nameController.text),
                      child: Text(playerStats.hasUsedFreeRename 
                        ? 'Usar Ticket' 
                        : 'Confirmar'),
                    ),
                  ],
                ),
              );

              if (newName != null && newName.isNotEmpty) {
                try {
                  final success = await _playerService.updateUsername(userId, newName);
                  if (success) {
                    if (!playerStats.hasUsedFreeRename) {
                      await _playerService.setUsedFreeRename(userId);
                    } else {
                      await _playerService.updateRenameTickets(userId, playerStats.renameTickets - 1);
                    }
                    
                    if (context.mounted) {
                      // Actualizamos el estado local primero
                      final updatedStats = await _playerService.getPlayerStats(userId);
                      
                      if (!context.mounted) return;  // Check again after the async call
                      
                      // Store the BuildContext in a local variable
                      final currentContext = context;
                      
                      Navigator.pushReplacement(
                        currentContext,
                        MaterialPageRoute(
                          builder: (context) => MenuInicio(
                            userId: userId,
                            username: newName,
                            initialStats: updatedStats,
                          ),
                        ),
                      );
                      
                      ScaffoldMessenger.of(currentContext).showSnackBar(
                        const SnackBar(content: Text('Nombre actualizado correctamente')),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Este nombre de usuario ya está en uso')),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al actualizar el nombre')),
                    );
                  }
                }
              }
            },
          ),
          // Update the sound button logic
          _buildOptionButton(
            'Sonido',
            Icons.volume_up,
            () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Sonido'),
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Activar/Desactivar Sonido'),
                      Switch(
                        value: !_musicService.isMuted,
                        onChanged: (value) async {
                          await _musicService.toggleSound();
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          _buildOptionButton(
            'Editar Perfil',
            Icons.person,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuEditarPerfil(
                    userId: userId,
                    username: username,
                    playerStats: playerStats,
                    pageController: pageController,
                  ),
                ),
              );
            },
          ),
          _buildOptionButton(
            'Cerrar Sesión',
            Icons.exit_to_app,
            () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Estás seguro que deseas cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () async {
                        debugPrint('[Cerrar Sesión] Iniciando cierre de sesión...');
                        try {
                          await VideoBackground.preloadVideo();
                          debugPrint('[Cerrar Sesión] Video precargado');
                          if (!context.mounted) {
                            debugPrint('[Cerrar Sesión] Contexto desmontado, abortando');
                            return;
                          }
                          Navigator.pushAndRemoveUntil(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              transitionDuration: const Duration(milliseconds: 300),
                            ),
                            (route) => false,
                          );
                          debugPrint('[Cerrar Sesión] Navegación a LoginScreen completada');
                        } catch (e) {
                          debugPrint('[Cerrar Sesión] Error durante el cierre de sesión: \$e');
                        }
                      },
                      child: const Text('Cerrar Sesión'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Spacer(),
          SharedBottomNav(pageController: pageController),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Material(
        color: const Color.fromRGBO(0, 32, 96, 1),
        borderRadius: BorderRadius.circular(15),
        elevation: 4,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color.fromRGBO(0, 0, 255, 0.3)),
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
                    fontWeight: FontWeight.bold,
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