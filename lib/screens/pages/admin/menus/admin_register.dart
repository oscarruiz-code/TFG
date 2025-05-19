import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class AdminRegisterScreen extends StatefulWidget {
  final bool isAdmin;

  const AdminRegisterScreen({
    super.key,
    required this.isAdmin,
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
      appBar: AppBar(
        title: const Text('Registrar Nuevo Usuario'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Crear Nueva Cuenta',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de usuario',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
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
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
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
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
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
                    decoration: InputDecoration(
                      labelText: 'Rol',
                      prefixIcon: const Icon(Icons.admin_panel_settings),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
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
                    },  // Faltaba esta coma
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Registrar Usuario',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}