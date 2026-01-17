class TimetableEntry {
  final String id;
  final String classId;
  final String subject;
  final String teacherId;
  final String dayOfWeek; // Monday, Tuesday, etc.
  final String timeSlot; // e.g., "09:00-10:00"
  final String room;

  TimetableEntry({
    required this.id,
    required this.classId,
    required this.subject,
    required this.teacherId,
    required this.dayOfWeek,
    required this.timeSlot,
    required this.room,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'subject': subject,
      'teacherId': teacherId,
      'dayOfWeek': dayOfWeek,
      'timeSlot': timeSlot,
      'room': room,
    };
  }

  factory TimetableEntry.fromMap(Map<String, dynamic> map) {
    return TimetableEntry(
      id: map['id'] ?? '',
      classId: map['classId'] ?? '',
      subject: map['subject'] ?? '',
      teacherId: map['teacherId'] ?? '',
      dayOfWeek: map['dayOfWeek'] ?? '',
      timeSlot: map['timeSlot'] ?? '',
      room: map['room'] ?? '',
    );
  }

  TimetableEntry copyWith({
    String? id,
    String? classId,
    String? subject,
    String? teacherId,
    String? dayOfWeek,
    String? timeSlot,
    String? room,
  }) {
    return TimetableEntry(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      subject: subject ?? this.subject,
      teacherId: teacherId ?? this.teacherId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      timeSlot: timeSlot ?? this.timeSlot,
      room: room ?? this.room,
    );
  }
}

