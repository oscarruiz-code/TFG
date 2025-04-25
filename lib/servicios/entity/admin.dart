class Admin {
  final int? id;
  final String username;
  final String email;
  final String password;
  bool isActive;

  Admin({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.isActive = true,
  });

  bool canManageAll() => true;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'is_active': isActive ? 1 : 0,
      'role': 'admin'
    };
  }

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      isActive: map['is_active'] == 1,
    );
  }
}