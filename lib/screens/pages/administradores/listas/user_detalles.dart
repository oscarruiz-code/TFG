import 'package:oscarruizcode_pingu/dependencias/imports.dart';
import 'dart:developer' as developer;

/// Pantalla que muestra y permite editar los detalles de un usuario.
///
/// Permite a administradores y subadministradores modificar información
/// de usuarios como nombre, email, rol, monedas y tickets.
class UserDetailScreen extends StatefulWidget {
  /// ID del usuario a mostrar
  final int userId;
  /// Indica si quien accede es administrador
  final bool isAdmin;
  /// ID del usuario que ha iniciado sesión
  final int loggedUserId;

  const UserDetailScreen({
    super.key,
    required this.userId,
    required this.isAdmin,
    required this.loggedUserId,
  });

  @override
  State<UserDetailScreen> createState() => UserDetailScreenState();
}

/// Estado para la pantalla de detalles de usuario.
class UserDetailScreenState extends State<UserDetailScreen> {
  final AdminService _adminService = AdminService();
  final PlayerService _playerService = PlayerService();
  User? user;
  PlayerStats? playerStats;
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController ticketsController = TextEditingController();
  TextEditingController coinsController = TextEditingController();
  TextEditingController game2TicketsController = TextEditingController();
  String selectedRole = 'user';

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      final userData = await _adminService.getUserById(widget.userId);
      PlayerStats? stats;
      
      try {
        if (userData.role == 'admin' || userData.role == 'subadmin') {
          stats = await _adminService.getAdminStats(widget.userId);
        } else {
          stats = await _playerService.getPlayerStats(widget.userId);
        }
      } catch (e) {
        developer.log('Error al cargar estadísticas: $e');
        // Crear estadísticas por defecto si hay error
        stats = PlayerStats(
          userId: widget.userId,
          coins: 0,
          renameTickets: 0,
          ticketsGame2: 0,
          currentAvatar: 'assets/avatar/defecto.png',
          hasUsedFreeRename: false,
        );
      }

      if (!mounted) return;

      setState(() {
        user = userData;
        playerStats = stats;
        usernameController.text = userData.username;
        emailController.text = userData.email;
        selectedRole = userData.role;
        ticketsController.text = stats?.renameTickets.toString() ?? '0';
        coinsController.text = stats?.coins.toString() ?? '0';
        game2TicketsController.text = stats?.ticketsGame2.toString() ?? '0';
      });
    } catch (e, stackTrace) {
      developer.log('Error en _loadUserDetails: $e');
      developer.log('StackTrace: $stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los datos: $e')),
      );
    }
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required void Function(int) onIncrease,
    required void Function(int) onDecrease,
    bool allowNegative = false,
    bool allowManualEdit = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
            ),
            keyboardType: TextInputType.number,
            readOnly: !allowManualEdit,
            onChanged: allowManualEdit ? (value) async {
              if (value.isNotEmpty) {
                try {
                  final newValue = int.parse(value);
                  await _playerService.updateCoins(widget.userId, newValue);
                  _loadUserDetails();
                } catch (e) {
                  
                }
              }
            } : null,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () {
            int currentValue = int.parse(controller.text);
            if (allowNegative || currentValue > 0) {
              onDecrease(currentValue - 1);
              controller.text = (currentValue - 1).toString();
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
            int currentValue = int.parse(controller.text);
            onIncrease(currentValue + 1);
            controller.text = (currentValue + 1).toString();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null || playerStats == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Determinar si el usuario actual puede editar este usuario
    bool canEdit = false;
    bool canBlock = false;
    bool canDelete = false;
    
    // Si es superadmin (ID 8), puede editar, bloquear y eliminar a cualquier usuario
    if (widget.loggedUserId == 8) {
      canEdit = true;
      canBlock = true;
      canDelete = true;
    } 
    // Si es admin normal
    else if (widget.isAdmin && user!.role == 'admin') {
      // Un admin normal no puede modificar a otros admins
      canEdit = widget.loggedUserId == widget.userId; // Solo su propio perfil
      canBlock = false; // No puede bloquear a otros admins
      canDelete = false; // No puede eliminar a otros admins
    }
    // Si es admin y el usuario es subadmin o usuario normal
    else if (widget.isAdmin && (user!.role == 'subadmin' || user!.role == 'user')) {
      canEdit = true;
      canBlock = true;
      canDelete = true;
    }
    // Si es subadmin
    else if (!widget.isAdmin) {
      // Un subadmin no puede modificar a admins
      if (user!.role == 'admin') {
        canEdit = false;
        canBlock = false;
        canDelete = false;
      }
      // Un subadmin puede editar y bloquear a otros subadmins
      else if (user!.role == 'subadmin') {
        canEdit = true;
        canBlock = true;
        canDelete = false; // No puede eliminar a otros subadmins
      }
      // Un subadmin puede editar, bloquear y eliminar a usuarios normales
      else {
        canEdit = true;
        canBlock = true;
        canDelete = true;
      }
    }
    // Si es subadmin, solo puede editar usuarios normales y otros subadmins
    (!widget.isAdmin && (user!.role == 'user' || user!.role == 'subadmin'));

    return Scaffold(
      appBar: AppBar(title: Text('Detalles de ${user!.username}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (canEdit)
              Column(
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(playerStats!.currentAvatar),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Avatar actual',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de usuario',
                    ),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    items:
                        ['user', 'subadmin', if (widget.isAdmin) 'admin']
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Rol'),
                  ),
                  const SizedBox(height: 20),
                  _buildNumberField(
                    label: 'Tickets de cambio de nombre',
                    controller: ticketsController,
                    onIncrease: (value) async {
                      await _playerService.updateRenameTickets(widget.userId, value);
                      _loadUserDetails();
                    },
                    onDecrease: (value) async {
                      await _playerService.updateRenameTickets(widget.userId, value);
                      _loadUserDetails();
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildNumberField(
                    label: 'Monedas',
                    controller: coinsController,
                    onIncrease: (value) async {
                      await _playerService.updateCoins(widget.userId, value);
                      _loadUserDetails();
                    },
                    onDecrease: (value) async {
                      await _playerService.updateCoins(widget.userId, value);
                      _loadUserDetails();
                    },
                    allowNegative: true,
                    allowManualEdit: true,  // Permitir edición manual para las monedas
                  ),
                  const SizedBox(height: 10),
                  _buildNumberField(
                    label: 'Tickets Juego 2',
                    controller: game2TicketsController,
                    onIncrease: (value) async {
                      await _playerService.updateTicketsGame2(widget.userId, value);
                      _loadUserDetails();
                    },
                    onDecrease: (value) async {
                      await _playerService.updateTicketsGame2(widget.userId, value);
                      _loadUserDetails();
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: canBlock ? () async {
                          await _adminService.blockUser(
                            widget.userId,
                            !user!.isBlocked,
                            loggedUserId: widget.loggedUserId,
                            loggedUserRole: widget.isAdmin ? 'admin' : 'subadmin',
                          );
                          _loadUserDetails();
                        } : null,
                        child: Text(
                          user!.isBlocked ? 'Desbloquear' : 'Bloquear',
                        ),
                      ),
                      if (canDelete)
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              // Verificar si el usuario es admin o subadmin
                              if (user!.role == 'admin' || user!.role == 'subadmin') {
                                // Para admins y subadmins, necesitamos usar updateUserRole para eliminar correctamente
                                await _adminService.updateUserRole(
                                  widget.userId,
                                  'user', // Cambiamos temporalmente a usuario normal
                                  loggedUserId: widget.loggedUserId,
                                  loggedUserRole: widget.isAdmin ? 'admin' : 'subadmin',
                                );
                                // Ahora eliminamos el usuario normal
                                await _playerService.deletePlayerStats(widget.userId);
                                await _adminService.deleteUser(widget.userId);
                              } else {
                                // Para usuarios normales, el proceso actual es correcto
                                await _playerService.deletePlayerStats(widget.userId);
                                await _adminService.deleteUser(widget.userId);
                              }
                              
                              if (!mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Usuario eliminado correctamente'),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al eliminar usuario: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Eliminar'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Verificar si el nombre de usuario o email han cambiado
                        if (usernameController.text != user!.username || 
                            emailController.text != user!.email) {
                          await _adminService.updateUserInfo(
                            widget.userId,
                            usernameController.text,
                            emailController.text,
                          );
                        }

                        // Verificar si el rol ha cambiado
                        if (selectedRole != user!.role) {
                          await _adminService.updateUserRole(
                            widget.userId,
                            selectedRole,
                            loggedUserId: widget.loggedUserId,
                            loggedUserRole: widget.isAdmin ? 'admin' : 'subadmin',
                          );
                        }

                        // Verificar si los tickets han cambiado
                        if (int.parse(ticketsController.text) != playerStats!.renameTickets) {
                          await _playerService.updateRenameTickets(
                            widget.userId,
                            int.parse(ticketsController.text),
                          );
                        }

                        // Actualizar la vista solo si se realizó algún cambio
                        _loadUserDetails();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cambios guardados correctamente'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (!mounted) return;
                        String errorMessage = 'Error al guardar los cambios';
                        
                        if (e.toString().contains('Duplicate entry') && 
                            e.toString().contains('username')) {
                          errorMessage = 'El nombre de usuario ya existe. Por favor, elige otro.';
                        } else {
                          errorMessage = 'Error: ${e.toString()}';
                        }
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text('Guardar Cambios'),
                  ),
                ],
              )
            else
              Center(
                child: Text(
                  'No tienes permisos para editar este usuario',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
