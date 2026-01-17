class User {
  final String id;
  final String username;
  final String email;
  final String role; // 'admin' or 'teacher'
  final String? profileImagePath;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.profileImagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'profileImagePath': profileImagePath,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'teacher',
      profileImagePath: map['profileImagePath'],
    );
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? role,
    String? profileImagePath,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
