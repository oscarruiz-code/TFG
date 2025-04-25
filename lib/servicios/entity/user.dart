class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  bool isBlocked;
  bool isActive;
  String role;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.isBlocked = false,
    this.isActive = true,
    this.role = 'user',  // Valor por defecto
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'is_blocked': isBlocked ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'role': role
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: int.parse(map['id'].toString()),
      username: map['username'].toString(),
      email: map['email'].toString(),
      password: map['password'].toString(),
      isBlocked: map['is_blocked'] == 1,
      isActive: map['is_active'] == 1,
      role: map['role'].toString(),
    );
}
}