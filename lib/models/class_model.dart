class SchoolClass {
  final String id;
  final String name;
  final String section;
  final int capacity;
  final String teacherId;

  SchoolClass({
    required this.id,
    required this.name,
    required this.section,
    required this.capacity,
    required this.teacherId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'section': section,
      'capacity': capacity,
      'teacherId': teacherId,
    };
  }

  factory SchoolClass.fromMap(Map<String, dynamic> map) {
    return SchoolClass(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      section: map['section'] ?? '',
      capacity: map['capacity'] ?? 0,
      teacherId: map['teacherId'] ?? '',
    );
  }

  SchoolClass copyWith({
    String? id,
    String? name,
    String? section,
    int? capacity,
    String? teacherId,
  }) {
    return SchoolClass(
      id: id ?? this.id,
      name: name ?? this.name,
      section: section ?? this.section,
      capacity: capacity ?? this.capacity,
      teacherId: teacherId ?? this.teacherId,
    );
  }
}
