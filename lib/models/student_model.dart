class Student {
  final String id;
  final String name;
  final String rollNumber;
  final String classId;
  final String email;
  final String phone;
  final String? profileImagePath;
  final String dateOfBirth;
  final String address;
  final String parentName;
  final String parentPhone;

  Student({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.classId,
    required this.email,
    required this.phone,
    this.profileImagePath,
    required this.dateOfBirth,
    required this.address,
    required this.parentName,
    required this.parentPhone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rollNumber': rollNumber,
      'classId': classId,
      'email': email,
      'phone': phone,
      'profileImagePath': profileImagePath,
      'dateOfBirth': dateOfBirth,
      'address': address,
      'parentName': parentName,
      'parentPhone': parentPhone,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      classId: map['classId'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profileImagePath: map['profileImagePath'],
      dateOfBirth: map['dateOfBirth'] ?? '',
      address: map['address'] ?? '',
      parentName: map['parentName'] ?? '',
      parentPhone: map['parentPhone'] ?? '',
    );
  }

  Student copyWith({
    String? id,
    String? name,
    String? rollNumber,
    String? classId,
    String? email,
    String? phone,
    String? profileImagePath,
    String? dateOfBirth,
    String? address,
    String? parentName,
    String? parentPhone,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      rollNumber: rollNumber ?? this.rollNumber,
      classId: classId ?? this.classId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
    );
  }
}
