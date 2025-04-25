import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class UserListScreen extends StatefulWidget {
  final bool isAdmin;
  final List<User> initialUsers;

  const UserListScreen({
    super.key,
    required this.isAdmin,
    required this.initialUsers,
  });

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final AdminService _adminService = AdminService();
  late Stream<List<User>> _usersStream;

  @override
  void initState() {
    super.initState();
    _usersStream = Stream.periodic(const Duration(seconds: 1))
      .asyncMap((_) => _adminService.getAllUsers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Usuarios'),
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminRegisterScreen()),
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

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final user = snapshot.data![index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(user.username),
                subtitle: Text(user.email),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailScreen(
                          userId: user.id!,
                          isAdmin: widget.isAdmin,  // Usar widget.isAdmin
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}