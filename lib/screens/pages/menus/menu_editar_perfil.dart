import 'package:oscarruizcode_pingu/dependencias/imports.dart';
import 'package:flutter/services.dart';

/// Widget que permite al usuario editar su perfil, incluyendo su foto de perfil,
/// correo electrónico y contraseña.
///
/// Proporciona una interfaz para seleccionar avatares gratuitos o premium
/// y actualizar la información de la cuenta del usuario.
class MenuEditarPerfil extends StatefulWidget {
  /// ID único del usuario.
  final int userId;
  
  /// Nombre de usuario actual.
  final String username;
  
  /// Estadísticas del jugador que incluyen información sobre avatares y tickets.
  final PlayerStats playerStats;
  
  /// Controlador de página para la navegación entre pantallas.
  final PageController pageController;

  const MenuEditarPerfil({
    super.key,
    required this.userId,
    required this.username,
    required this.playerStats,
    required this.pageController,
  });

  @override
  State<MenuEditarPerfil> createState() => _MenuEditarPerfilState();
}

class _MenuEditarPerfilState extends State<MenuEditarPerfil> {
  final PlayerService _playerService = PlayerService();
  String? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _selectedAvatar = widget.playerStats.currentAvatar;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/imagenes/fondo.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              SharedTopBar(
                username: widget.username,
                playerStats: widget.playerStats,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildProfileSection(),
                      const SizedBox(height: 20),
                      _buildNameSection(context),
                    ],
                  ),
                ),
              ),
              SharedBottomNav(pageController: widget.pageController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 32, 96, 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto de Perfil',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Avatares Gratuitos',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildAvatarGrid(true),
          const SizedBox(height: 20),
          const Text(
            'Avatares Premium',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildAvatarGrid(false),
        ],
      ),
    );
  }

  Widget _buildAvatarGrid(bool isFree) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: isFree ? 5 : 3,
      itemBuilder: (context, index) {
        String avatarPath = isFree
            ? 'assets/perfil/gratis/perfil${index + 1}.png'
            : 'assets/perfil/premium/perfil${index + 6}.png';
        bool hasAccess = isFree || widget.playerStats.hasPremiumAvatar(avatarPath);

        return GestureDetector(
          onTap: hasAccess
              ? () {
                  setState(() {
                    _selectedAvatar = avatarPath;
                  });
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _selectedAvatar == avatarPath
                    ? Colors.blue
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              backgroundImage: AssetImage(avatarPath),
              child: !hasAccess
                  ? const Icon(Icons.lock, color: Colors.white)
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNameSection(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 32, 96, 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: emailController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Correo Electrónico',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                try {
                  final adminService = AdminService();
                  final userService = UserService();
                  
                  // Actualizar la foto de perfil si se seleccionó una nueva
                  if (_selectedAvatar != null && _selectedAvatar != widget.playerStats.currentAvatar) {
                    await _playerService.updateProfilePicture(widget.userId, _selectedAvatar!);
                  }
                  
                  // Actualizamos el email y la contraseña si se proporcionaron
                  if (emailController.text.isNotEmpty || passwordController.text.isNotEmpty) {
                      await adminService.updateUserInfo(
                          widget.userId,
                          widget.username,
                          emailController.text,  // Solo usamos el nuevo email si se proporciona
                      );
                      
                      // Si se proporcionó una nueva contraseña, la actualizamos
                      if (passwordController.text.isNotEmpty) {
                          await userService.updatePassword(widget.userId, passwordController.text);
                      }
                  }
                  
                  if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Perfil actualizado correctamente')),
                      );
                      
                      // Obtener los stats actualizados
                      final updatedStats = await _playerService.getPlayerStats(widget.userId);
                      
                      // Recargar el MenuInicio con los datos actualizados
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuInicio(
                              userId: widget.userId,
                              username: widget.username,
                              initialStats: updatedStats,
                            ),
                          ),
                        );
                      }
                  }
                } catch (e) {
                  if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al actualizar: $e')),
                      );
                  }
                }
              },
              child: const Text('Guardar Cambios'),
            ),
          ),
      ],
      ),
    );
  }
}