import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class MenuEditarPerfil extends StatelessWidget {
  final int userId;
  final String username;
  final PlayerStats playerStats;
  final PageController pageController;  // Agregar pageController
  final PlayerService _playerService = PlayerService();

  MenuEditarPerfil({
    super.key,
    required this.userId,
    required this.username,
    required this.playerStats,
    required this.pageController,  // Agregar este parámetro
  });

  @override
  Widget build(BuildContext context) {
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
                username: username,
                playerStats: playerStats,
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
              SharedBottomNav(pageController: pageController),
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
        bool hasAccess = isFree || playerStats.hasPremiumAvatar(avatarPath);

        return GestureDetector(
          onTap: hasAccess
              ? () async {
                  await _playerService.updateProfilePicture(userId, avatarPath);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Foto de perfil actualizada')),
                    );
                  }
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: playerStats.currentAvatar == avatarPath
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
                  
                  // Actualizamos el email y la contraseña si se proporcionaron
                  if (emailController.text.isNotEmpty || passwordController.text.isNotEmpty) {
                      await adminService.updateUserInfo(
                          userId,
                          username,
                          emailController.text,  // Solo usamos el nuevo email si se proporciona
                      );
                      
                      // Si se proporcionó una nueva contraseña, la actualizamos
                      if (passwordController.text.isNotEmpty) {
                          await userService.updatePassword(userId, passwordController.text);
                      }
                      
                      if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Perfil actualizado correctamente')),
                          );
                          Navigator.pop(context);
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
      )],
      ),
    );
  }
}