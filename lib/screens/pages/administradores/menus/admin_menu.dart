import 'package:oscarruizcode_pingu/dependencias/imports.dart';
import 'package:flutter/services.dart';

/// Pantalla de menú para administradores y subadministradores.
class AdminMenuScreen extends StatefulWidget {
  /// Indica si el usuario es administrador.
  final bool isAdmin;
  /// Nombre de usuario.
  final String username;
  /// ID del usuario.
  final int userId;
  /// Rol del usuario ('admin', 'subadmin', 'user').
  final String? role;

  const AdminMenuScreen({
    super.key,
    required this.isAdmin,
    required this.username,
    required this.userId,
    this.role,
  });

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  @override
  Widget build(BuildContext context) {
    // Verificar si el usuario es un admin real, no un subadmin
    final bool isRealAdmin = widget.role == 'admin';
    
    return Scaffold(
      body: Stack(
        children: [
          const VideoBackground(),
          Center(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Color.fromRGBO(255, 255, 255, 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 255, 0.2),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '¡Bienvenido, ${widget.username}!',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.blue,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      // Usar el campo role para decidir qué stats cargar
                      PlayerStats playerStats;
                      final role = widget.role ?? (widget.isAdmin ? 'admin' : 'user');
                      if (role == 'admin' || role == 'subadmin') {
                        final adminService = AdminService();
                        playerStats = await adminService.getAdminStats(widget.userId);
                      } else {
                        final playerService = PlayerService();
                        playerStats = await playerService.getPlayerStats(widget.userId);
                      }

                      if (!mounted) return;

                      // Permitir todas las orientaciones antes de navegar al juego
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                        DeviceOrientation.portraitDown,
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.landscapeRight,
                      ]);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuInicio(
                            userId: widget.userId,
                            username: widget.username,
                            initialStats: playerStats,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(0, 0, 255, 0.7),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Ir al Juego',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final adminService = AdminService();
                      adminService.getAllUsers().then((users) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserListScreen(
                              isAdmin: isRealAdmin,
                              loggedUserId: widget.userId,
                              initialUsers: users,
                            ),
                          ),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(0, 128, 255, 0.7),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Lista de Usuarios',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await VideoBackground.preloadVideo();
                      
                      if (!mounted) return;
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
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(255, 0, 0, 0.7),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}