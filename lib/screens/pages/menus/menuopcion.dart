import 'package:flutter/material.dart';
import 'package:oscarruizcode_pingu/servicios/entity/player.dart';
import '../../../servicios/sevices/player_service.dart';
import 'package:oscarruizcode_pingu/widgets/shared_widgets.dart';
import 'package:oscarruizcode_pingu/widgets/music_service.dart';

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
              final newName = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(playerStats.hasUsedFreeRename 
                    ? 'Cambiar Nombre (Ticket)' 
                    : 'Cambiar Nombre (Gratis)'),
                  content: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: '¿Qué nombre deseas usar?',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, nameController.text),
                      child: const Text('Guardar'),
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
                      Navigator.pushReplacementNamed(
                        context, 
                        '/menu',
                        arguments: {'userId': userId, 'username': newName}
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
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
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushReplacementNamed('/login');
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