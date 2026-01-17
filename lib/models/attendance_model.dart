class Attendance {
  final String id;
  final String studentId;
  final String classId;
  final String date;
  final String status; // 'present', 'absent', 'leave'
  final String? remarks;

  Attendance({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.date,
    required this.status,
    this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'classId': classId,
      'date': date,
      'status': status,
      'remarks': remarks,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      classId: map['classId'] ?? '',
      date: map['date'] ?? '',
      status: map['status'] ?? 'absent',
      remarks: map['remarks'],
    );
  }

  Attendance copyWith({
    String? id,
    String? studentId,
    String? classId,
    String? date,
    String? status,
    String? remarks,
  }) {
    return Attendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      date: date ?? this.date,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
    );
  }
}
