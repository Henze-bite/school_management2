class Grade {
  final String id;
  final String studentId;
  final String subject;
  final double marks;
  final double maxMarks;
  final String semester;
  final DateTime date;

  Grade({
    required this.id,
    required this.studentId,
    required this.subject,
    required this.marks,
    required this.maxMarks,
    required this.semester,
    required this.date,
  });

  double get percentage => (marks / maxMarks) * 100;

  String get grade {
    final percentage = this.percentage;
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'subject': subject,
      'marks': marks,
      'maxMarks': maxMarks,
      'semester': semester,
      'date': date.toIso8601String(),
    };
  }

  factory Grade.fromMap(Map<String, dynamic> map) {
    return Grade(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      subject: map['subject'] ?? '',
      marks: (map['marks'] ?? 0).toDouble(),
      maxMarks: (map['maxMarks'] ?? 100).toDouble(),
      semester: map['semester'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Grade copyWith({
    String? id,
    String? studentId,
    String? subject,
    double? marks,
    double? maxMarks,
    String? semester,
    DateTime? date,
  }) {
    return Grade(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      subject: subject ?? this.subject,
      marks: marks ?? this.marks,
      maxMarks: maxMarks ?? this.maxMarks,
      semester: semester ?? this.semester,
      date: date ?? this.date,
    );
  }
}
