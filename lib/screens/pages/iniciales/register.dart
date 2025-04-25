import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final UserService _userService = UserService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();    // Nuevo controller
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();    // Nuevo dispose
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseñas invalidas')),
      );
      return;
    }

    try {
      bool exists = await _userService.usernameExists(_usernameController.text);
      if (exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El Usuario ya existe')),
        );
        return;
      }

      await _userService.createUser(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );
      
      if (!mounted) return;
      // No detenemos el video, solo navegamos al login
      // In the successful registration navigation
      Navigator.pushReplacement(
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
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al Registrar Usuario')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text('REGISTRAR',
                    style: TextStyle(
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
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(
                    controller: _usernameController,
                    hintText: 'Usuario',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(                     // Nuevo campo email
                    controller: _emailController,
                    hintText: 'Correo Electrónico',
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Contraseña',
                    icon: Icons.lock,
                    isPassword: true,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirmar Contraseña',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _register,  // Cambiado aquí
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
                      'Registrar',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Color.fromRGBO(255, 255, 255, 0.3),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          hintText: hintText,
          hintStyle: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}