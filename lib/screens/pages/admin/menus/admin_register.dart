import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class AdminRegisterScreen extends StatefulWidget {
  final bool isAdmin; // Agregar la propiedad isAdmin

  const AdminRegisterScreen({
    super.key,
    required this.isAdmin, // Requerir isAdmin en el constructor
  });

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'user';
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Nuevo Usuario')),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                    labelStyle: TextStyle(color: Colors.black87),
                  ),
                  style: const TextStyle(color: Colors.black87),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un nombre de usuario';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    labelStyle: TextStyle(color: Colors.black87),
                  ),
                  style: const TextStyle(color: Colors.black87),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un correo electrónico';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: Colors.black87),
                  ),
                  style: const TextStyle(color: Colors.black87),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una contraseña';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Rol',
                    labelStyle: TextStyle(color: Colors.black87),
                  ),
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: Colors.black87),
                  items: [
                    const DropdownMenuItem(value: 'user', child: Text('Usuario')),
                    const DropdownMenuItem(
                      value: 'subadmin',
                      child: Text('Subadministrador'),
                    ),
                    if (widget.isAdmin) // Solo mostrar opción de admin si el usuario es admin
                      const DropdownMenuItem(
                        value: 'admin',
                        child: Text('Administrador'),
                      ),
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      _selectedRole = value ?? 'user';
                    });
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        int userId;
                        // Si es subadmin o admin, registrar en la tabla admins
                        if (_selectedRole == 'subadmin' || _selectedRole == 'admin') {
                          userId = await _adminService.registerAdmin(
                            username: _usernameController.text,
                            email: _emailController.text,
                            password: _passwordController.text,
                            role: _selectedRole,
                          );
                          
                          // Crear registro en admin_stats
                          await _adminService.createAdminStats(userId);
                        } else {
                          // Si es usuario normal, registrar en la tabla users
                          userId = await _adminService.registerUser(
                            username: _usernameController.text,
                            email: _emailController.text,
                            password: _passwordController.text,
                            role: _selectedRole,
                          );
                          
                          // Crear registro en player_stats
                          final playerService = PlayerService();
                          await playerService.updateProfilePicture(
                            userId,
                            'assets/avatar/defecto.png',
                          );
                        }

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Usuario registrado exitosamente'),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al registrar: $e'),
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 0, 255, 0.7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Registrar Usuario',
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
      ),
    );
  }
}