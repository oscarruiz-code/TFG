import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class UserListScreen extends StatefulWidget {
  final bool isAdmin;
  final int loggedUserId;
  final List<User> initialUsers;

  const UserListScreen({
    super.key,
    required this.isAdmin,
    required this.loggedUserId,
    required this.initialUsers,
  });

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  late Stream<List<User>> _usersStream;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _usersStream = Stream.periodic(const Duration(seconds: 1))
      .asyncMap((_) => _adminService.getAllUsers());
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildUserList(List<User> users, String role) {
    final filteredUsers = users.where((user) => user.role == role).toList();

    if (filteredUsers.isEmpty) {
      return const Center(child: Text('No hay usuarios disponibles.'));
    }

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        
        // Lógica de permisos de edición
        bool canEdit = false;
        if (widget.isAdmin) {
          // Si es admin, puede editar a todos excepto otros admins
          canEdit = user.role != 'admin' || user.id == widget.loggedUserId;
        } else {
          // Si es subadmin, puede editar usuarios normales y otros subadmins
          canEdit = user.role == 'user' || user.role == 'subadmin';
        }

        return ListTile(
          leading: Icon(
            Icons.person,
            color: _getRoleColor(user.role),
          ),
          title: Text(
            user.username,
            style: TextStyle(
              fontWeight: user.id == widget.loggedUserId 
                  ? FontWeight.bold 
                  : FontWeight.normal,
            ),
          ),
          subtitle: Text(user.email),
          trailing: canEdit
              ? IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailScreen(
                          userId: user.id!,
                          isAdmin: widget.isAdmin,
                          loggedUserId: widget.loggedUserId,
                        ),
                      ),
                    );
                  },
                )
              : null,
          onTap: () {
            if (!canEdit && !widget.isAdmin) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No tienes permisos para editar este usuario'),
                ),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserDetailScreen(
                  userId: user.id!,
                  isAdmin: widget.isAdmin,
                  loggedUserId: widget.loggedUserId,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'subadmin':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Usuarios'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Usuarios'),
            Tab(text: 'Subadmins'),
            Tab(text: 'Admins'),
          ],
        ),
        actions: [
          if (widget.isAdmin)  // Esto ahora dependerá del rol real 'admin'
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminRegisterScreen(
                      isAdmin: widget.isAdmin,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<List<User>>(
        stream: _usersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay usuarios disponibles.'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildUserList(snapshot.data!, 'user'),
              _buildUserList(snapshot.data!, 'subadmin'),
              _buildUserList(snapshot.data!, 'admin'),
            ],
          );
        },
      ),
    );
  }
}